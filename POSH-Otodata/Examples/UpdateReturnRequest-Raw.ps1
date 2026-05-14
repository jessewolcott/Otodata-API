#Requires -Version 5.1
# UpdateReturnRequest (Raw) — updates the comment on a return request. No module required.

$VerbosePreference = 'Continue'

$BaseUrl   = 'https://telematics.otodatanetwork.com:4431'
$ApiPath   = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$RequestId = 'RR00001'   # Replace with a real return request number

$headers = @{
    Authorization  = "Bearer $ApiKey"
    Accept         = 'application/json; charset=utf-8'
    'Content-Type' = 'application/json'
}
$body = @{ Comment = "Reviewed on $(Get-Date -Format 'yyyy-MM-dd') via direct API" } | ConvertTo-Json

Write-Verbose "Updating comment on return request $RequestId..."
$result = Invoke-RestMethod `
    -Uri     "$BaseUrl$ApiPath/returnRequests/$RequestId" `
    -Method  POST `
    -Headers $headers `
    -Body    $body

if ($result.Errors.Count -eq 0) {
    Write-Output "Return request $RequestId updated."
} else {
    $result.Errors | ForEach-Object { Write-Warning "$($_.Property): $($_.Message)" }
}
