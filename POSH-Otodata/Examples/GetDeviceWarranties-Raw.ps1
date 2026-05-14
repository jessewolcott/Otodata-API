#Requires -Version 5.1
# GetDeviceWarranties (Raw) — warranty history for a device. No module required.
# WarrantyStatus: 2=NotStarted 3=Expired 4=Active 6=Voided 7=Archived
# WarrantyType  : 0=Standard  1=Extended  2=BatteryPackOnly

$VerbosePreference = 'Continue'

$BaseUrl  = 'https://telematics.otodatanetwork.com:4431'
$ApiPath  = '/v1.0/DataService.svc'
$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 123456

$headers = @{ Authorization = "Bearer $ApiKey"; Accept = 'application/json; charset=utf-8' }

Write-Verbose "Fetching warranties for device $DeviceId..."
$warranties = Invoke-RestMethod `
    -Uri     "$BaseUrl$ApiPath/devices/$DeviceId/warranties" `
    -Method  GET `
    -Headers $headers

$warranties | Format-Table WarrantyType, WarrantyStatus, WarrantyStartDate, WarrantyEndDate -AutoSize
Write-Output "$($warranties.Count) warranty record(s)"
