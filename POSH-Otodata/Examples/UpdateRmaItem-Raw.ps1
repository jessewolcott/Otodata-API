#Requires -Version 5.1
# UpdateRmaItem (Raw) — marks an RMA item reconciled and/or adds a comment. No module required.

$VerbosePreference = 'Continue'

$BaseUrl  = 'https://telematics.otodatanetwork.com:4431'
$ApiPath  = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$RmaId    = 'RMA001'   # Replace with a real RMA number
$DeviceId = 123456     # Replace with the device serial number on that RMA

$headers = @{
    Authorization  = "Bearer $ApiKey"
    Accept         = 'application/json; charset=utf-8'
    'Content-Type' = 'application/json'
}
$body = @{
    IsReconciled    = $true
    CustomerComment = "Confirmed received on $(Get-Date -Format 'yyyy-MM-dd')"
} | ConvertTo-Json

Write-Verbose "Updating RMA item $RmaId / device $DeviceId..."
$result = Invoke-RestMethod `
    -Uri     "$BaseUrl$ApiPath/rmaItems/$RmaId/devices/$DeviceId" `
    -Method  POST `
    -Headers $headers `
    -Body    $body

if ($result.Errors.Count -eq 0) {
    Write-Output 'RMA item updated.'
} else {
    $result.Errors | ForEach-Object { Write-Warning "$($_.Property): $($_.Message)" }
}
