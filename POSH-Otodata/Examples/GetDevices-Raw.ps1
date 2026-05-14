#Requires -Version 5.1
# GetDevices (Raw) — returns all modules using direct Invoke-RestMethod. No module required.

$VerbosePreference = 'Continue'

$BaseUrl = 'https://telematics.otodatanetwork.com:4431'
$ApiPath = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }

$headers = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }

Write-Verbose "Fetching all devices..."
# All devices
$devices = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices" -Method GET -Headers $headers
$devices | Select-Object Id, Name, Status, LastLevel, Inventory, Capacity, Product | Format-Table -AutoSize
Write-Output "Total: $($devices.Count) device(s)"

# Filter by last-modified date
# $devices = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices?lastDateUtc=2026-01-01T00:00:00Z" -Method GET -Headers $headers
