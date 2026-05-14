#Requires -Version 5.1
# GetRmas — lists RMAs for the company.
# Paginated at 100 per page. RmaItemStatus: 0=PendingAnalysis 1=BeingAnalyzed 2=Complete 3=PendingReceipt 4=NotReceived 5=Ignored

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Fetching open RMAs..."
$openRmas = Get-OtoDataRmas -IsOpen $true
$openRmas | Format-Table RmaNumber, IsComplete, CreatedDate -AutoSize
Write-Output "Open RMAs: $($openRmas.Count)"

# Completed RMAs
# $closedRmas = Get-OtoDataRmas -IsOpen $false

# Page 2
# $page2 = Get-OtoDataRmas -IsOpen $true -Page 1

Disconnect-OtoData
Write-Verbose "Disconnected."
