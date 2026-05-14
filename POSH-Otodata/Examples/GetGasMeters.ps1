#Requires -Version 5.1
# GetGasMeters — historical readings for all gas meter modules in the company.
# Paginated at 10,000 meters per page. Units: cubic feet or cubic meters.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Fetching gas meter readings for April 2026..."
$gas = Get-OtoDataGasMeters `
    -StartDateUtc '2026-04-01T00:00:00Z' `
    -EndDateUtc   '2026-04-30T23:59:59Z'

$gas.Meters | Select-Object -First 20 |
    Format-Table SerialNumber, AccountNumber, TankNumber, Volume, Units,
                 IndexInitialValue, IndexFinalValue, PulseRate -AutoSize

Write-Output "Total gas meter records: $($gas.Count)"

# Page 2
# $page2 = Get-OtoDataGasMeters -StartDateUtc '...' -EndDateUtc '...' -Page 1

Disconnect-OtoData
Write-Verbose "Disconnected."
