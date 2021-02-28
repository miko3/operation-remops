@{
    RootModule = 'PSRemo.psm1'
    ModuleVersion = '0.0.1'
    GUID = '12b78712-992f-4ba8-9f33-54194bf45fb1'
    Author = 'Miko'
    CompanyName = ''
    Copyright = '(c) miko.info. All rights reserved.'
    Description = 'PowerShellでNature Remo Local APIを操作するやつ'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Add-RmOperation',
        'Remove-RmOperation',
        'Submit-RmCommand',
        'Get-RmCommand',
        'Set-RmIPAddress'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
PrivateData = @{
    PSData = @{
        # ReleaseNotes = ''
    }
}
}

