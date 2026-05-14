#Requires -Version 5.1
# CreateDispatch — triggers a dispatch for a device.
# Sends a push notification to end-users and fires any enabled integration events.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 20008447
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Creating dispatch for device $DeviceId..."
New-OtoDataDispatch -Id $DeviceId
Write-Output "Dispatch created for device $DeviceId."

# Target a specific sensor
# New-OtoDataDispatch -Id $DeviceId -Sensor 1

Disconnect-OtoData
Write-Verbose "Disconnected."
