#Requires -Version 5.1
# UpdateRmaItem — marks an RMA item as reconciled and/or adds a customer comment.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

# Discover a real RMA and device from the sandbox
$all = Get-OtoDataRmas -IsOpen $true
if ($all.Count -eq 0) { $all = Get-OtoDataRmas -IsOpen $false }
if ($all.Count -eq 0) {
    Write-Output "No RMAs found in this environment — replace 'RMA001' and device ID with real values."
    Disconnect-OtoData
    return
}
$RmaId    = $all[0].RmaNumber
$rma      = Get-OtoDataRma -Id $RmaId
$DeviceId = $rma.RmaItems[0].SerialNumber

Write-Verbose "Updating RMA item $RmaId / device $DeviceId..."
$result = Update-OtoDataRmaItem `
    -RmaId           $RmaId `
    -DeviceId        $DeviceId `
    -IsReconciled    $true `
    -CustomerComment "Confirmed received on $(Get-Date -Format 'yyyy-MM-dd')"

if ($result.Errors.Count -eq 0) {
    Write-Output "RMA item $RmaId / $DeviceId updated."
} else {
    $result.Errors | ForEach-Object { Write-Warning "$($_.Property): $($_.Message)" }
}

# Comment only — leave reconciliation unchanged
# Update-OtoDataRmaItem -RmaId $RmaId -DeviceId $DeviceId -CustomerComment 'Needs further inspection'

Disconnect-OtoData
Write-Verbose "Disconnected."
