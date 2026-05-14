#Requires -Version 5.1
# ResetDevice — clears ALL customer data for a device from the Nee-Vo database.
# Use the -Exclude parameter to preserve specific fields.
# WARNING: This is destructive. Confirm the device ID before running.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
$DeviceId = 20008447
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

try {
    $confirm = Read-Host "Reset ALL customer data for device $DeviceId? Type YES to confirm"
} catch {
    Write-Output "ResetDevice requires an interactive session. Run this script in a terminal and type YES when prompted."
    Disconnect-OtoData
    return
}
if ($confirm -eq 'YES') {
    Write-Verbose "Resetting device $DeviceId (excluding Name, TankSerialNumber)..."
    Reset-OtoDataDevice -Id $DeviceId -Exclude @('Name', 'TankSerialNumber')
    Write-Output "Device $DeviceId reset complete."
} else {
    Write-Verbose "Reset cancelled by user."
}

# Reset with no exclusions (full wipe)
# Reset-OtoDataDevice -Id $DeviceId

Disconnect-OtoData
Write-Verbose "Disconnected."
