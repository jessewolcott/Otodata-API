#Requires -Version 5.1
# CancelDispatch — cancels an active dispatch for a device.
# Fires integration events but does NOT send a push notification to the end-user.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 20008447
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Cancelling dispatch for device $DeviceId..."
Stop-OtoDataDispatch -Id $DeviceId
Write-Output "Dispatch cancelled for device $DeviceId."

# Target a specific sensor
# Stop-OtoDataDispatch -Id $DeviceId -Sensor 1

Disconnect-OtoData
Write-Verbose "Disconnected."
