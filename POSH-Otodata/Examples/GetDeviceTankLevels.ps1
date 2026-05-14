#Requires -Version 5.1
# GetDeviceTankLevels — historical level readings for a single device.
# Paginated at 10,000 readings per page; use -Page to walk through pages.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 20008447
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Fetching tank levels for device $DeviceId..."
$levels = Get-OtoDataDeviceTankLevels `
    -Id           $DeviceId `
    -StartDateUtc '2026-04-01T00:00:00Z' `
    -EndDateUtc   '2026-04-30T23:59:59Z'

$levels.Logs | Select-Object -First 20 |
    Format-Table Level, LogDateUtc, Temperature, BatteryLevel, SignalStrength -AutoSize

Write-Output "Readings for device $DeviceId : $($levels.Count)"

# With sensor index
# $levels = Get-OtoDataDeviceTankLevels -Id $DeviceId -StartDateUtc '...' -EndDateUtc '...' -Sensor 1

Disconnect-OtoData
Write-Verbose "Disconnected."
