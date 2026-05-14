#Requires -Version 5.1
# UpdateReturnRequest — updates the comment on a return request.

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

# Discover a real return request number from the sandbox
$all = Get-OtoDataReturnRequests -IsOpen $true
if ($all.Count -eq 0) { $all = Get-OtoDataReturnRequests -IsOpen $false }
if ($all.Count -eq 0) {
    Write-Output "No return requests found in this environment — replace 'RR00001' with a real return request number."
    Disconnect-OtoData
    return
}
$RequestId = $all[0].ReturnRequestNumber

Write-Verbose "Updating comment on return request $RequestId..."
$result = Update-OtoDataReturnRequest `
    -Id      $RequestId `
    -Comment "Reviewed on $(Get-Date -Format 'yyyy-MM-dd') via POSH-Otodata"

if ($result.Errors.Count -eq 0) {
    Write-Output "Return request $RequestId comment updated."
} else {
    $result.Errors | ForEach-Object { Write-Warning "$($_.Property): $($_.Message)" }
}

Disconnect-OtoData
Write-Verbose "Disconnected."
