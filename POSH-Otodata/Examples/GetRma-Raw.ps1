#Requires -Version 5.1
# GetRma (Raw) — retrieves a single RMA with all line items. No module required.

$VerbosePreference = 'Continue'

$BaseUrl = 'https://telematics.otodatanetwork.com:4431'
$ApiPath = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$RmaId   = 'RMA001'   # Replace with a real RMA number

$headers = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }

Write-Verbose "Fetching RMA $RmaId..."
$rma = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/rmas/$RmaId" -Method GET -Headers $headers
$rma | Format-List RmaNumber, IsComplete, CreatedDate

Write-Output "RMA items: $($rma.RmaItems.Count)"
$rma.RmaItems | Format-Table SerialNumber, Status, IsReconciled, WarrantyStatus,
                              Conclusion, Trouble, Replacement, Route -AutoSize
