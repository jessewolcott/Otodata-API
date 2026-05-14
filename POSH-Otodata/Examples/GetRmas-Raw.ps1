#Requires -Version 5.1
# GetRmas (Raw) — lists RMAs. No module required.
# Paginated at 100 per page. RmaItemStatus: 0=PendingAnalysis 1=BeingAnalyzed 2=Complete 3=PendingReceipt 4=NotReceived 5=Ignored

$VerbosePreference = 'Continue'

$BaseUrl = 'https://telematics.otodatanetwork.com:4431'
$ApiPath = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }

$headers = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }

Write-Verbose "Fetching open RMAs..."
# Open RMAs
$openRmas = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/rmas?isOpen=true" -Method GET -Headers $headers
Write-Output "Open RMAs: $($openRmas.Count)"
$openRmas | Format-Table RmaNumber, IsComplete, CreatedDate -AutoSize

# Completed RMAs
# $closedRmas = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/rmas?isOpen=false" -Method GET -Headers $headers
