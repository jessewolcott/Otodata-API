#Requires -Version 5.1
# GetReturnRequest — retrieves a single return request with all its line items.
# ItemStatus: 0=Pending 1=Accepted 2=Refused

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

# Discover a real return request number from the sandbox
$all = Get-OtoDataReturnRequests -IsOpen $true
if ($all.Count -eq 0) { $all = Get-OtoDataReturnRequests -IsOpen $false }
if ($all.Count -eq 0) {
    Write-Output "No return requests found in this environment — replace 'RR00001' with a real return request number."
    Disconnect-OtoData
    return
}
$RequestId = $all[0].ReturnRequestNumber

Write-Verbose "Fetching return request $RequestId..."
$rr = Get-OtoDataReturnRequest -Id $RequestId
$rr | Format-List ReturnRequestNumber, RmaNumber, Status, Comment,
                  RequesterName, RequesterEmail, CreatedDate,
                  StreetAddress, City, Region, PostalCode, Country

$rr.ReturnRequestItems | Format-Table SerialNumber, Status, SensorStatus,
                                      SensorTrouble, WarrantyStatus, LastActivityDate -AutoSize
Write-Output "Line items: $($rr.ReturnRequestItems.Count)"

Disconnect-OtoData
Write-Verbose "Disconnected."
