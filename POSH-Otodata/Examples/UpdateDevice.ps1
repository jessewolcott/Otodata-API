#Requires -Version 5.1
# UpdateDevice — modifies customer-configurable properties on a device.
# Only supply the fields you want to change; all others are left untouched.
# Setting TankFormatName auto-sets: Capacity, TankFormType, Depth, Height, Width, Offset, MaxUllage.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 20008447
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Updating device $DeviceId..."
$result = Update-OtoDataDevice -Id $DeviceId -Properties @{
    Name           = 'North Tank'
    Route          = 'Route A'
    Note           = 'Updated via POSH-Otodata'
    LocationName   = 'Site A'
    LocationNumber = 'LOC001'
}

if ($result.Errors.Count -eq 0) {
    Write-Output "Device $DeviceId updated successfully."
} else {
    $result.Errors | ForEach-Object { Write-Warning "$($_.Property): $($_.Message)" }
}

# Cancel all changes if any single field fails validation
# $result = Update-OtoDataDevice -Id $DeviceId -Properties @{ TankFormatName = 'Propane 1000 gal' } -EnforceValidation $true

Disconnect-OtoData
Write-Verbose "Disconnected."
