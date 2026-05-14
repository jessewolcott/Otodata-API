#Requires -Version 5.1
# GetReturnRequests — lists return requests for the company.
# Paginated at 100 per page. Status: 0=Pending 1=Analyzing 2=Completed 3=RmaReady

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Fetching open return requests..."
$openRRs = Get-OtoDataReturnRequests -IsOpen $true
$openRRs | Format-Table ReturnRequestNumber, Status, DeviceCount, RequesterName, CreatedDate -AutoSize
Write-Output "Open return requests: $($openRRs.Count)"

# Completed requests
# $closedRRs = Get-OtoDataReturnRequests -IsOpen $false

# Page 2
# $page2 = Get-OtoDataReturnRequests -IsOpen $true -Page 1

Disconnect-OtoData
Write-Verbose "Disconnected."
