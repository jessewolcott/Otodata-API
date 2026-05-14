#Requires -Version 5.1
# CancelDispatch (Raw) — cancels an active dispatch. No module required.
# Fires integration events but does NOT send a push notification.

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

Write-Verbose "Cancelling dispatch for device $DeviceId..."
Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices/$DeviceId/canceldispatch" -Method POST -Headers $headers
Write-Output "Dispatch cancelled for device $DeviceId."

# Target a specific sensor
# Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices/$DeviceId/canceldispatch?sensor=1" -Method POST -Headers $headers
