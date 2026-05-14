#Requires -Version 5.1
# GetReturnRequest (Raw) — retrieves a single return request with all line items. No module required.

$VerbosePreference = 'Continue'

$BaseUrl   = 'https://telematics.otodatanetwork.com:4431'
$ApiPath   = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$RequestId = 'RR00001'   # Replace with a real return request number

$headers = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }

Write-Verbose "Fetching return request $RequestId..."
$rr = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/returnRequests/$RequestId" -Method GET -Headers $headers
$rr | Format-List ReturnRequestNumber, RmaNumber, Status, Comment,
                  RequesterName, RequesterEmail, CreatedDate,
                  StreetAddress, City, Region, PostalCode, Country

Write-Output "Line items: $($rr.ReturnRequestItems.Count)"
$rr.ReturnRequestItems | Format-Table SerialNumber, Status, SensorStatus,
                                      SensorTrouble, WarrantyStatus, LastActivityDate -AutoSize
