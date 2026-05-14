#Requires -Version 5.1
# GetRma — retrieves a single RMA with all its line items.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

# Discover a real RMA number from the sandbox
$all = Get-OtoDataRmas -IsOpen $true
if ($all.Count -eq 0) { $all = Get-OtoDataRmas -IsOpen $false }
if ($all.Count -eq 0) {
    Write-Output "No RMAs found in this environment — replace 'RMA001' with a real RMA number."
    Disconnect-OtoData
    return
}
$RmaId = $all[0].RmaNumber

Write-Verbose "Fetching RMA $RmaId..."
$rma = Get-OtoDataRma -Id $RmaId
$rma | Format-List RmaNumber, IsComplete, CreatedDate

$rma.RmaItems | Format-Table SerialNumber, Status, IsReconciled, WarrantyStatus,
                              Conclusion, Trouble, Replacement, Route -AutoSize
Write-Output "RMA items: $($rma.RmaItems.Count)"

Disconnect-OtoData
Write-Verbose "Disconnected."
