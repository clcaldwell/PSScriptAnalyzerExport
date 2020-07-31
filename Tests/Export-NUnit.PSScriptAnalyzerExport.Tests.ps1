. $PSScriptRoot\Mock_Functions.ps1
$PSCommandPath
$ScriptName

#mock -CommandName Invoke-ScriptAnalyzer -MockWith {New-DiagnosticRecord}

It "Should work" {
    Mock -CommandName Invoke-ScriptAnalyzer -MockWith {Mock-Invoke-PSScriptAnalyzer}
    (Invoke-ScriptAnalyzer -Path .).Message | Should -Be "This is a rule with a suggested correction"
}
