#Requires -Version 5.1
# DownloadReport — downloads a summary report to a local file.
# Supported formats: Excel (default), CSV, SuburbanSoftware

$VerbosePreference = 'Continue'

Import-Module (Join-Path $PSScriptRoot '..\POSH-Otodata.psd1') -Force

$_col   = Get-ChildItem -Path $PSScriptRoot -Filter '*.postman_collection.json' | Select-Object -First 1
$ApiKey = if ($_col) { (Get-Content $_col.FullName -Raw | ConvertFrom-Json).variable | Where-Object key -eq 'API_KEY' | Select-Object -ExpandProperty value } else { 'YOUR_API_KEY_HERE' }
Write-Verbose "Connecting to Otodata Nee-Vo API..."
Connect-OtoData -ApiKey $ApiKey

Write-Verbose "Downloading CSV report..."
$file = Export-OtoDataReport -Format CSV -OutPath ".\OtoData_$(Get-Date -Format 'yyyyMMdd').csv"
Write-Output "Saved: $($file.FullName)  ($($file.Length) bytes)"

# Excel (default)
# $file = Export-OtoDataReport

# Excel, exclude non-installed devices, include sub-companies
# $file = Export-OtoDataReport -Format Excel -ExcludeNonInstalled $true -IncludeSubCompanies $true

Disconnect-OtoData
Write-Verbose "Disconnected."
