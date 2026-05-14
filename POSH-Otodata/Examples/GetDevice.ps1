#Requires -Version 5.1
# GetDevice — returns a single module by its serial number.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 20008447
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Fetching device $DeviceId..."
$device = Get-OtoDataDevice -Id $DeviceId
$device | Format-List Id, Name, Status, LastLevel, Inventory, Capacity, Product,
                      BatteryAlarm, BatteryLevel, SignalStrength, Temperature,
                      LastRead, LastFill, Route, LocationName, LocationNumber

# With a specific sensor index
# $device = Get-OtoDataDevice -Id $DeviceId -Sensor 1

Disconnect-OtoData
Write-Verbose "Disconnected."
