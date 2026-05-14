Set-StrictMode -Version Latest

$script:Config = @{
    BaseUrl = 'https://telematics.otodatanetwork.com:4431'
    ApiKey  = $null
}

#region Connection

function Connect-OtoData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ApiKey,
        [string]$BaseUrl = 'https://telematics.otodatanetwork.com:4431'
    )
    $script:Config.ApiKey  = $ApiKey
    $script:Config.BaseUrl = $BaseUrl.TrimEnd('/')
    Write-Verbose "Connected to $($script:Config.BaseUrl)"
}

function Disconnect-OtoData {
    [CmdletBinding()]
    param()
    $script:Config.ApiKey = $null
    Write-Verbose "Disconnected from Otodata Nee-Vo API"
}

#endregion

#region Internal helper

function Invoke-OtoDataApiRequest {
    param(
        [string]$Path,
        [string]$Method = 'GET',
        [hashtable]$Query = @{},
        [object]$Body    = $null,
        [string]$OutFile
    )

    if (-not $script:Config.ApiKey) {
        throw "Not connected. Run Connect-OtoData -ApiKey '<your_key>' first."
    }

    $queryParts = foreach ($kv in $Query.GetEnumerator()) {
        if ($null -ne $kv.Value) {
            "$($kv.Key)=$([System.Uri]::EscapeDataString($kv.Value.ToString()))"
        }
    }
    $qs  = if ($queryParts) { '?' + ($queryParts -join '&') } else { '' }
    $uri = "$($script:Config.BaseUrl)$Path$qs"

    $headers = @{
        'Authorization' = "Bearer $($script:Config.ApiKey)"
        'Accept'        = 'application/json; charset=utf-8'
    }

    $params = @{
        Uri     = $uri
        Method  = $Method
        Headers = $headers
    }

    if ($Body) {
        $params['Body']        = ($Body | ConvertTo-Json -Depth 10)
        $params['ContentType'] = 'application/json'
    }

    if ($OutFile) {
        $params['OutFile'] = $OutFile
        Invoke-RestMethod @params
        return
    }

    Invoke-RestMethod @params
}

#endregion

#region Devices

function Get-OtoDataDevices {
    <#
    .SYNOPSIS
        Returns all modules linked to the authenticated company.
    .PARAMETER LastDateUtc
        ISO8601 UTC date. Only return devices updated after this timestamp.
    .EXAMPLE
        Get-OtoDataDevices
    .EXAMPLE
        Get-OtoDataDevices -LastDateUtc '2025-01-01T00:00:00Z'
    #>
    [CmdletBinding()]
    param(
        [string]$LastDateUtc
    )
    $q = @{}
    if ($PSBoundParameters.ContainsKey('LastDateUtc')) { $q['lastDateUtc'] = $LastDateUtc }
    Invoke-OtoDataApiRequest -Path '/v1.0/DataService.svc/devices' -Query $q
}

function Get-OtoDataDevice {
    <#
    .SYNOPSIS
        Returns a single module by serial number.
    .PARAMETER Id
        Device serial number (integer).
    .PARAMETER Sensor
        Sensor index (0-based). Default: 0.
    .EXAMPLE
        Get-OtoDataDevice -Id 123456
    .EXAMPLE
        Get-OtoDataDevice -Id 123456 -Sensor 1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][long]$Id,
        [int]$Sensor
    )
    $q = @{}
    if ($PSBoundParameters.ContainsKey('Sensor')) { $q['sensor'] = $Sensor }
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/devices/$Id" -Query $q
}

function Get-OtoDataSampleDevice {
    <#
    .SYNOPSIS
        Returns a dummy module for testing. No authentication required.
    .EXAMPLE
        Get-OtoDataSampleDevice
    #>
    [CmdletBinding()]
    param()
    $uri = "$($script:Config.BaseUrl)/v1.0/DataService.svc/devices/sample"
    Invoke-RestMethod -Uri $uri -Method GET -Headers @{ 'Accept' = 'application/json; charset=utf-8' }
}

function Get-OtoDataDeviceWarranties {
    <#
    .SYNOPSIS
        Returns warranty history for a module, newest to oldest.
    .PARAMETER Id
        Device serial number (integer).
    .EXAMPLE
        Get-OtoDataDeviceWarranties -Id 123456
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][long]$Id
    )
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/devices/$Id/warranties"
}

function Update-OtoDataDevice {
    <#
    .SYNOPSIS
        Modifies a module's customer-configurable properties.
    .PARAMETER Id
        Device serial number (integer).
    .PARAMETER Properties
        Hashtable of DeviceUpdate fields to change (e.g. @{ Name = 'Tank A'; Product = 'Propane' }).
    .PARAMETER Sensor
        Sensor index (0-based). Default: 0.
    .PARAMETER EnforceValidation
        When $true, cancels the whole update if any field fails; also returns error details.
    .EXAMPLE
        Update-OtoDataDevice -Id 123456 -Properties @{ Name = 'North Tank'; Route = 'Route 1' }
    .EXAMPLE
        Update-OtoDataDevice -Id 123456 -Properties @{ TankFormatName = 'Propane 1000 gal' } -EnforceValidation $true
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][long]$Id,
        [Parameter(Mandatory)][hashtable]$Properties,
        [int]$Sensor,
        [bool]$EnforceValidation
    )
    $q = @{}
    if ($PSBoundParameters.ContainsKey('Sensor'))            { $q['sensor']            = $Sensor }
    if ($PSBoundParameters.ContainsKey('EnforceValidation')) { $q['enforceValidation'] = $EnforceValidation.ToString().ToLower() }
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/devices/$Id" -Method POST -Query $q -Body $Properties
}

function Reset-OtoDataDevice {
    <#
    .SYNOPSIS
        Clears all customer data for a device from the Nee-Vo database.
    .PARAMETER Id
        Device serial number (integer).
    .PARAMETER Exclude
        Array of Device property names to preserve (not reset).
    .EXAMPLE
        Reset-OtoDataDevice -Id 123456
    .EXAMPLE
        Reset-OtoDataDevice -Id 123456 -Exclude @('Name', 'TankSerialNumber')
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][long]$Id,
        [string[]]$Exclude = @()
    )
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/devices/$Id/reset" -Method POST -Body @{ Exclude = $Exclude }
}

function New-OtoDataDispatch {
    <#
    .SYNOPSIS
        Creates a dispatch for a device. Sends push notifications and fires integration events.
    .PARAMETER Id
        Device serial number (integer).
    .PARAMETER Sensor
        Sensor index (0-based). Default: 0.
    .EXAMPLE
        New-OtoDataDispatch -Id 123456
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][long]$Id,
        [int]$Sensor
    )
    $q = @{}
    if ($PSBoundParameters.ContainsKey('Sensor')) { $q['sensor'] = $Sensor }
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/devices/$Id/createdispatch" -Method GET -Query $q
}

function Stop-OtoDataDispatch {
    <#
    .SYNOPSIS
        Cancels an active dispatch for a device. Fires integration events but no push notification.
    .PARAMETER Id
        Device serial number (integer).
    .PARAMETER Sensor
        Sensor index (0-based). Default: 0.
    .EXAMPLE
        Stop-OtoDataDispatch -Id 123456
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][long]$Id,
        [int]$Sensor
    )
    $q = @{}
    if ($PSBoundParameters.ContainsKey('Sensor')) { $q['sensor'] = $Sensor }
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/devices/$Id/canceldispatch" -Method GET -Query $q
}

#endregion

#region Tank Levels

function Get-OtoDataTankLevels {
    <#
    .SYNOPSIS
        Gets historical level readings for all modules. Paginated at 10,000 readings per page.
    .PARAMETER StartDateUtc
        ISO8601 UTC start date (required).
    .PARAMETER EndDateUtc
        ISO8601 UTC end date (required).
    .PARAMETER Page
        Page index (0-based). Default: 0.
    .EXAMPLE
        Get-OtoDataTankLevels -StartDateUtc '2025-01-01T00:00:00Z' -EndDateUtc '2025-01-31T23:59:59Z'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$StartDateUtc,
        [Parameter(Mandatory)][string]$EndDateUtc,
        [int]$Page
    )
    $q = @{ startDateUtc = $StartDateUtc; endDateUtc = $EndDateUtc }
    if ($PSBoundParameters.ContainsKey('Page')) { $q['page'] = $Page }
    Invoke-OtoDataApiRequest -Path '/v1.0/DataService.svc/tanklevels' -Query $q
}

function Get-OtoDataDeviceTankLevels {
    <#
    .SYNOPSIS
        Gets historical level readings for a single module.
    .PARAMETER Id
        Device serial number (integer).
    .PARAMETER StartDateUtc
        ISO8601 UTC start date (required).
    .PARAMETER EndDateUtc
        ISO8601 UTC end date (required).
    .PARAMETER Sensor
        Sensor index (0-based). Default: 0.
    .EXAMPLE
        Get-OtoDataDeviceTankLevels -Id 123456 -StartDateUtc '2025-01-01T00:00:00Z' -EndDateUtc '2025-01-31T23:59:59Z'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][long]$Id,
        [Parameter(Mandatory)][string]$StartDateUtc,
        [Parameter(Mandatory)][string]$EndDateUtc,
        [int]$Sensor
    )
    $q = @{ startDateUtc = $StartDateUtc; endDateUtc = $EndDateUtc }
    if ($PSBoundParameters.ContainsKey('Sensor')) { $q['sensor'] = $Sensor }
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/devices/$Id/tanklevels" -Query $q
}

#endregion

#region Reports

function Export-OtoDataReport {
    <#
    .SYNOPSIS
        Downloads a summary report to a local file.
    .PARAMETER OutPath
        Destination file path. Defaults to .\OtoData_Report_YYYYMMDD.xlsx in the current directory.
    .PARAMETER Format
        File format: Excel (default), CSV, or SuburbanSoftware.
    .PARAMETER ExcludeNonInstalled
        Exclude non-installed devices from the report.
    .PARAMETER IncludeSubCompanies
        Include sub-company devices in the report.
    .EXAMPLE
        Export-OtoDataReport -Format CSV -OutPath C:\Reports\tank_report.csv
    #>
    [CmdletBinding()]
    param(
        [string]$OutPath = ".\OtoData_Report_$(Get-Date -Format 'yyyyMMdd').xlsx",
        [ValidateSet('Excel', 'CSV', 'SuburbanSoftware')][string]$Format = 'Excel',
        [bool]$ExcludeNonInstalled,
        [bool]$IncludeSubCompanies
    )

    if (-not $script:Config.ApiKey) {
        throw "Not connected. Run Connect-OtoData -ApiKey '<your_key>' first."
    }

    $q = @{ format = $Format }
    if ($PSBoundParameters.ContainsKey('ExcludeNonInstalled')) { $q['excludeNonInstalled'] = $ExcludeNonInstalled.ToString().ToLower() }
    if ($PSBoundParameters.ContainsKey('IncludeSubCompanies')) { $q['includeSubCompanies'] = $IncludeSubCompanies.ToString().ToLower() }

    $qs  = '?' + (($q.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&')
    $uri = "$($script:Config.BaseUrl)/v1.0/DataService.svc/downloadReport$qs"

    Invoke-RestMethod -Uri $uri -Method GET -Headers @{ 'Authorization' = "Bearer $($script:Config.ApiKey)" } -OutFile $OutPath
    Write-Verbose "Report saved to $OutPath"
    Get-Item $OutPath
}

#endregion

#region Return Requests

function Get-OtoDataReturnRequests {
    <#
    .SYNOPSIS
        Gets return requests linked to the company. Paginated at 100 per page.
    .PARAMETER IsOpen
        $true = open/pending requests; $false = completed requests.
    .PARAMETER Page
        Page index (0-based). Default: 0.
    .EXAMPLE
        Get-OtoDataReturnRequests -IsOpen $true
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][bool]$IsOpen,
        [int]$Page
    )
    $q = @{ isOpen = $IsOpen.ToString().ToLower() }
    if ($PSBoundParameters.ContainsKey('Page')) { $q['page'] = $Page }
    Invoke-OtoDataApiRequest -Path '/v1.0/DataService.svc/returnRequests' -Query $q
}

function Get-OtoDataReturnRequest {
    <#
    .SYNOPSIS
        Gets a single return request by ID.
    .PARAMETER Id
        Return request number (e.g. 'RR00001').
    .EXAMPLE
        Get-OtoDataReturnRequest -Id 'RR00001'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Id
    )
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/returnRequests/$Id"
}

function Update-OtoDataReturnRequest {
    <#
    .SYNOPSIS
        Updates the comment on a return request.
    .PARAMETER Id
        Return request number (e.g. 'RR00001').
    .PARAMETER Comment
        New comment text (max 2048 chars).
    .EXAMPLE
        Update-OtoDataReturnRequest -Id 'RR00001' -Comment 'Devices shipped 2026-05-14'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Comment
    )
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/returnRequests/$Id" -Method POST -Body @{ Comment = $Comment }
}

#endregion

#region RMAs

function Get-OtoDataRmas {
    <#
    .SYNOPSIS
        Gets RMAs linked to the company. Paginated at 100 per page.
    .PARAMETER IsOpen
        $true = open RMAs; $false = completed RMAs.
    .PARAMETER Page
        Page index (0-based). Default: 0.
    .EXAMPLE
        Get-OtoDataRmas -IsOpen $true
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][bool]$IsOpen,
        [int]$Page
    )
    $q = @{ isOpen = $IsOpen.ToString().ToLower() }
    if ($PSBoundParameters.ContainsKey('Page')) { $q['page'] = $Page }
    Invoke-OtoDataApiRequest -Path '/v1.0/DataService.svc/rmas' -Query $q
}

function Get-OtoDataRma {
    <#
    .SYNOPSIS
        Gets a single RMA and its items.
    .PARAMETER Id
        RMA number string (e.g. 'RMA123').
    .EXAMPLE
        Get-OtoDataRma -Id 'RMA123'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Id
    )
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/rmas/$Id"
}

function Update-OtoDataRmaItem {
    <#
    .SYNOPSIS
        Updates reconciliation status and/or customer comment on an RMA item.
    .PARAMETER RmaId
        RMA number string (e.g. 'RMA001').
    .PARAMETER DeviceId
        Device serial number (integer).
    .PARAMETER IsReconciled
        Mark the item as reconciled ($true) or not ($false).
    .PARAMETER CustomerComment
        Customer comment on the RMA item (max 2048 chars).
    .EXAMPLE
        Update-OtoDataRmaItem -RmaId 'RMA001' -DeviceId 123456 -IsReconciled $true -CustomerComment 'Received OK'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$RmaId,
        [Parameter(Mandatory)][long]$DeviceId,
        [bool]$IsReconciled,
        [string]$CustomerComment
    )
    $body = @{}
    if ($PSBoundParameters.ContainsKey('IsReconciled'))    { $body['IsReconciled']    = $IsReconciled }
    if ($PSBoundParameters.ContainsKey('CustomerComment')) { $body['CustomerComment'] = $CustomerComment }
    Invoke-OtoDataApiRequest -Path "/v1.0/DataService.svc/rmaItems/$RmaId/devices/$DeviceId" -Method POST -Body $body
}

#endregion

#region Gas Meters

function Get-OtoDataGasMeters {
    <#
    .SYNOPSIS
        Gets historical readings for all gas meter modules. Paginated at 10,000 per page.
    .PARAMETER StartDateUtc
        ISO8601 UTC start date (required).
    .PARAMETER EndDateUtc
        ISO8601 UTC end date (required).
    .PARAMETER Page
        Page index (0-based). Default: 0.
    .EXAMPLE
        Get-OtoDataGasMeters -StartDateUtc '2025-01-01T00:00:00Z' -EndDateUtc '2025-02-01T00:00:00Z'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$StartDateUtc,
        [Parameter(Mandatory)][string]$EndDateUtc,
        [int]$Page
    )
    $q = @{ startDateUtc = $StartDateUtc; endDateUtc = $EndDateUtc }
    if ($PSBoundParameters.ContainsKey('Page')) { $q['page'] = $Page }
    Invoke-OtoDataApiRequest -Path '/v1.0/DataService.svc/meters' -Query $q
}

#endregion

Export-ModuleMember -Function @(
    'Connect-OtoData', 'Disconnect-OtoData',
    'Get-OtoDataDevices', 'Get-OtoDataDevice', 'Get-OtoDataSampleDevice', 'Get-OtoDataDeviceWarranties',
    'Update-OtoDataDevice', 'Reset-OtoDataDevice', 'New-OtoDataDispatch', 'Stop-OtoDataDispatch',
    'Get-OtoDataTankLevels', 'Get-OtoDataDeviceTankLevels',
    'Export-OtoDataReport',
    'Get-OtoDataReturnRequests', 'Get-OtoDataReturnRequest', 'Update-OtoDataReturnRequest',
    'Get-OtoDataRmas', 'Get-OtoDataRma', 'Update-OtoDataRmaItem',
    'Get-OtoDataGasMeters'
)
