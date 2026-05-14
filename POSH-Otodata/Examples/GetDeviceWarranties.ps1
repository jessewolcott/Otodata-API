#Requires -Version 5.1
# GetDeviceWarranties — returns warranty history for a device, newest to oldest.
# WarrantyStatus: 2=NotStarted 3=Expired 4=Active 6=Voided 7=Archived
# WarrantyType  : 0=Standard  1=Extended  2=BatteryPackOnly

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 20008447
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Fetching warranties for device $DeviceId..."
$warranties = Get-OtoDataDeviceWarranties -Id $DeviceId
$warranties | Format-Table WarrantyType, WarrantyStatus, WarrantyStartDate, WarrantyEndDate -AutoSize

Write-Output "$($warranties.Count) warranty record(s) for device $DeviceId"

Disconnect-OtoData
Write-Verbose "Disconnected."
