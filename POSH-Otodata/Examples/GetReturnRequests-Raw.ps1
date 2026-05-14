#Requires -Version 5.1
# GetReturnRequests (Raw) — lists return requests. No module required.
# Paginated at 100 per page. Status: 0=Pending 1=Analyzing 2=Completed 3=RmaReady

$VerbosePreference = 'Continue'

$BaseUrl = 'https://telematics.otodatanetwork.com:4431'
$ApiPath = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }

$headers = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }

Write-Verbose "Fetching open return requests..."
# Open requests
$openRRs = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/returnRequests?isOpen=true" -Method GET -Headers $headers
Write-Output "Open return requests: $($openRRs.Count)"
$openRRs | Format-Table ReturnRequestNumber, Status, DeviceCount, RequesterName, CreatedDate -AutoSize

# Completed requests
# $closedRRs = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/returnRequests?isOpen=false" -Method GET -Headers $headers

# Page 2
# $page2 = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/returnRequests?isOpen=true&page=1" -Method GET -Headers $headers
