#Requires -Version 5.1
# GetSampleDevice — returns a dummy device for testing. No API key required.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

# No Connect-OtoData needed for this endpoint
Write-Verbose "Fetching sample device (no authentication required)..."
$sample = Get-OtoDataSampleDevice
$sample | Format-List
