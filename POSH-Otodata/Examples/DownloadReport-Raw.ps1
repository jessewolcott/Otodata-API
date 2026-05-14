#Requires -Version 5.1
# DownloadReport (Raw) — downloads a summary report to a local file. No module required.
# Supported formats: Excel (default), CSV, SuburbanSoftware

$VerbosePreference = 'Continue'

$BaseUrl = 'https://telematics.otodatanetwork.com:4431'
$ApiPath = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }

$headers    = @{ Authorization = "Bearer $ApiKey" }
$outPath    = ".\OtoData_$(Get-Date -Format 'yyyyMMdd').csv"

Write-Verbose "Downloading CSV report to $outPath..."
Invoke-RestMethod `
    -Uri     "$BaseUrl$ApiPath/downloadReport?format=CSV" `
    -Method  GET `
    -Headers $headers `
    -OutFile $outPath

$file = Get-Item $outPath
Write-Output "Saved: $($file.FullName)  ($($file.Length) bytes)"

# Excel (default)
# Invoke-RestMethod -Uri "$BaseUrl$ApiPath/downloadReport" -Method GET -Headers $headers -OutFile '.\report.xlsx'
