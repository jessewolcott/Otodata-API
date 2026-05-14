#Requires -Version 5.1
# GetTankLevels — historical level readings for ALL devices in the company.
# Paginated at 10,000 readings per page; use -Page to walk through pages.
# ValueType: 0=Percentage(/100) 1=Distance(mm) 2=Quantity 3=Temp(deciKelvin)

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Fetching tank levels for April 2026..."
$levels = Get-OtoDataTankLevels `
    -StartDateUtc '2026-04-01T00:00:00Z' `
    -EndDateUtc   '2026-04-30T23:59:59Z'

$levels.Logs | Select-Object -First 20 |
    Format-Table Id, Level, LogDateUtc, Temperature, BatteryLevel, SignalStrength -AutoSize

Write-Output "Total readings: $($levels.Count)"

# Fetch the next page
# $page2 = Get-OtoDataTankLevels -StartDateUtc '2026-04-01T00:00:00Z' -EndDateUtc '2026-04-30T23:59:59Z' -Page 1

Disconnect-OtoData
Write-Verbose "Disconnected."
