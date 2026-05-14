#Requires -Version 5.1
# UpdateDevice (Raw) — modifies a device's properties. No module required.
# Only include fields you want to change.

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

$body = @{
    Name           = 'North Tank'
    Route          = 'Route A'
    Note           = 'Updated via direct Invoke-RestMethod'
    LocationName   = 'Site A'
    LocationNumber = 'LOC001'
} | ConvertTo-Json

Write-Verbose "Updating device $DeviceId..."
$result = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices/$DeviceId" -Method POST -Headers $headers -Body $body

if ($result.Errors.Count -eq 0) {
    Write-Output 'Device updated successfully.'
} else {
    $result.Errors | ForEach-Object { Write-Warning "$($_.Property): $($_.Message)" }
}

# With enforced validation
# $result = Invoke-RestMethod -Uri "$BaseUrl$ApiPath/devices/$DeviceId?enforceValidation=true" -Method POST -Headers $headers -Body $body
