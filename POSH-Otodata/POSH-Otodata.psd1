@{
    RootModule        = 'POSH-Otodata.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a3c2f8e1-74b6-4d92-a015-3e8f60d1b7c4'
    Author            = 'Royal Farms App Support'
    CompanyName       = 'Royal Farms'
    Copyright         = '(c) 2026 Royal Farms. All rights reserved.'
    Description       = 'PowerShell module for the Otodata Nee-Vo API v29. Covers all 18 endpoints for RTLM device management, tank levels, reports, return requests, RMAs, and gas meters.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Connect-OtoData'
        'Disconnect-OtoData'
        'Get-OtoDataDevices'
        'Get-OtoDataDevice'
        'Get-OtoDataSampleDevice'
        'Get-OtoDataDeviceWarranties'
        'Update-OtoDataDevice'
        'Reset-OtoDataDevice'
        'New-OtoDataDispatch'
        'Stop-OtoDataDispatch'
        'Get-OtoDataTankLevels'
        'Get-OtoDataDeviceTankLevels'
        'Export-OtoDataReport'
        'Get-OtoDataReturnRequests'
        'Get-OtoDataReturnRequest'
        'Update-OtoDataReturnRequest'
        'Get-OtoDataRmas'
        'Get-OtoDataRma'
        'Update-OtoDataRmaItem'
        'Get-OtoDataGasMeters'
    )
    CmdletsToExport   = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('Otodata', 'NeeVo', 'RTLM', 'TankMonitor', 'IoT', 'API')
            ProjectUri   = 'https://neevo.otodata.ca'
            ReleaseNotes = 'Initial release covering Otodata Nee-Vo API v29 (all 18 endpoints).'
        }
    }
}
