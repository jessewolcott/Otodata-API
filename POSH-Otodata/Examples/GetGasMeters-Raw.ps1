#Requires -Version 5.1
# GetGasMeters (Raw) — historical readings for all gas meter modules. No module required.
# Paginated at 10,000 meters per page.

$VerbosePreference = 'Continue'

$BaseUrl = 'https://telematics.otodatanetwork.com:4431'
$ApiPath = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }

$headers   = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }
$startDate = '2026-04-01T00:00:00Z'
$endDate   = '2026-04-30T23:59:59Z'

Write-Verbose "Fetching gas meter readings for April 2026..."
$gas = Invoke-RestMethod `
    -Uri     "$BaseUrl$ApiPath/meters?startDateUtc=$startDate&endDateUtc=$endDate" `
    -Method  GET `
    -Headers $headers

Write-Output "Total gas meter records: $($gas.Count)"
$gas.Meters | Select-Object -First 20 |
    Format-Table SerialNumber, AccountNumber, TankNumber, Volume, Units,
                 IndexInitialValue, IndexFinalValue, PulseRate -AutoSize

# Page 2
# $page2 = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/meters?startDateUtc=$startDate&endDateUtc=$endDate&page=1" -Method GET -Headers $headers
