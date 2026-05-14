#Requires -Version 5.1
# GetTankLevels (Raw) — historical level readings for all devices. No module required.
# Paginated at 10,000 readings per page.

$VerbosePreference = 'Continue'

$BaseUrl = 'https://telematics.otodatanetwork.com:4431'
$ApiPath = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }

$headers    = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }
$startDate  = '2026-04-01T00:00:00Z'
$endDate    = '2026-04-30T23:59:59Z'

Write-Verbose "Fetching tank level readings for April 2026..."
$levels = Invoke-RestMethod `
    -Uri     "$BaseUrl$ApiPath/tanklevels?startDateUtc=$startDate&endDateUtc=$endDate" `
    -Method  GET `
    -Headers $headers

Write-Output "Total readings: $($levels.Count)"
$levels.Logs | Select-Object -First 20 |
    Format-Table Id, Level, LogDateUtc, Temperature, BatteryLevel, SignalStrength -AutoSize

# Page 2
# $page2 = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/tanklevels?startDateUtc=$startDate&endDateUtc=$endDate&page=1" -Method GET -Headers $headers
