#Requires -Version 5.1
# GetDevice (Raw) — returns a single module by serial number. No module required.

$VerbosePreference = 'Continue'

$BaseUrl  = 'https://telematics.otodatanetwork.com:4431'
$ApiPath  = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 123456

$headers = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }

Write-Verbose "Fetching device $DeviceId..."
$device = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices/$DeviceId" -Method GET -Headers $headers
$device | Format-List Id, Name, Status, LastLevel, Inventory, Capacity, Product,
                      BatteryAlarm, BatteryLevel, SignalStrength, Temperature,
                      LastRead, LastFill, Route, LocationName, LocationNumber

# With a specific sensor index
# $device = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices/$DeviceId?sensor=1" -Method GET -Headers $headers
