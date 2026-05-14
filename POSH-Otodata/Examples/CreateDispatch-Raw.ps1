#Requires -Version 5.1
# CreateDispatch (Raw) — triggers a dispatch for a device. No module required.
# Sends a push notification to end-users and fires any enabled integration events.

$VerbosePreference = 'Continue'

$BaseUrl  = 'https://telematics.otodatanetwork.com:4431'
$ApiPath  = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 123456

$headers = @{
    Authorization  = "Bearer $ApiKey"
    Accept         = 'application/json; charset=utf-8'
    'Content-Type' = 'application/json'
}

Write-Verbose "Creating dispatch for device $DeviceId..."
Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices/$DeviceId/createdispatch" -Method POST -Headers $headers
Write-Output "Dispatch created for device $DeviceId."

# Target a specific sensor
# Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices/$DeviceId/createdispatch?sensor=1" -Method POST -Headers $headers
