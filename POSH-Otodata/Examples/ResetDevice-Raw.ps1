#Requires -Version 5.1
# ResetDevice (Raw) — clears ALL customer data for a device. No module required.
# WARNING: Destructive. Use -Exclude to preserve specific fields.

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

$confirm = Read-Host "Reset ALL customer data for device $DeviceId? Type YES to confirm"
if ($confirm -eq 'YES') {
    $body = @{ Exclude = @('Name', 'TankSerialNumber') } | ConvertTo-Json
    Write-Verbose "Resetting device $DeviceId..."
    Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices/$DeviceId/reset" -Method POST -Headers $headers -Body $body
    Write-Output 'Device reset complete.'
} else {
    Write-Verbose 'Reset cancelled.'
}

# Full wipe (no exclusions)
# $body = @{ Exclude = @() } | ConvertTo-Json
