#Requires -Version 5.1
# GetSampleDevice (Raw) — returns a dummy device for testing. No API key or module required.

$VerbosePreference = 'Continue'

$BaseUrl = 'https://telematics.otodatanetwork.com:4431'
$ApiPath = '/v1.0/DataService.svc'

Write-Verbose "Fetching sample device..."
$sample = Invoke-RestMethod `
    -Uri     "$BaseUrl$ApiPath/devices/sample" `
    -Method  GET `
    -Headers @{ Accept = 'application/json; charset=utf-8' }

$sample | Format-List
