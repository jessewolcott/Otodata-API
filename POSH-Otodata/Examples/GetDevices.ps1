#Requires -Version 5.1
# GetDevices — returns all modules linked to the authenticated company.
# Optional: filter to devices updated after a specific UTC date.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Fetching all devices..."
$devices = Get-OtoDataDevices
$devices | Select-Object Id, Name, Status, LastLevel, Inventory, Capacity, Product | Format-Table -AutoSize

Write-Output "Total: $($devices.Count) device(s)"

# Only devices updated since a given date
# $devices = Get-OtoDataDevices -LastDateUtc '2026-01-01T00:00:00Z'

Disconnect-OtoData
Write-Verbose "Disconnected."
