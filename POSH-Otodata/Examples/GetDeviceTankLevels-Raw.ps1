#Requires -Version 5.1
# GetDeviceTankLevels (Raw) — historical level readings for one device. No module required.

$VerbosePreference = 'Continue'

$BaseUrl  = 'https://telematics.otodatanetwork.com:4431'
$ApiPath  = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 123456

$headers   = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }
$startDate = '2026-04-01T00:00:00Z'
$endDate   = '2026-04-30T23:59:59Z'

Write-Verbose "Fetching tank level readings for device $DeviceId..."
$levels = Invoke-RestMethod `
    -Uri     "$BaseUrl$ApiPath/devices/$DeviceId/tanklevels?startDateUtc=$startDate&endDateUtc=$endDate" `
    -Method  GET `
    -Headers $headers

Write-Output "Readings for device $DeviceId : $($levels.Count)"
$levels.Logs | Select-Object -First 20 |
    Format-Table Level, LogDateUtc, Temperature, BatteryLevel, SignalStrength -AutoSize

# With sensor index
# $levels = Invoke-RestMethod -Uri "...$DeviceId/tanklevels?startDateUtc=$startDate&endDateUtc=$endDate&sensor=1" -Method GET -Headers $headers
