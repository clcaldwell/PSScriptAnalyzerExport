Function Mock-Invoke-PSScriptAnalyzer {
param(
    [string]$scriptName = "scriptName",
    # Start
    [int]$startLineNumber = "1",
    [int]$startOffsetInLine = "1",
    [string]$startLine = "line",
    # End
    [int]$endLineNumber = "1",
    [int]$endOffsetInLine = "1",
    [string]$endLine = "line",
    #CorrectionExtent
    [int]$startColumnNumber = "10",
    [int]$endColumnNumber = 11,
    [string]$correctionText = "blah text",
    [string]$correctionFile = "file",
    [string]$correctionDescription = "description",
    # DiagRecord
    [string]$message = "This is a rule with a suggested correction",
    [string]$ruleName = "RuleName",
    [ValidateSet("Warning","Information","Error","ParseError")]
    [string]$severity = "Warning",
    [string]$scriptPath = "scriptPath"
)    
    
    $ExtentCollection = [System.Collections.ObjectModel.Collection[Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent]]::new()
    $ExtentCollection.Add(
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent]::new(
            [int]$startLineNumber,
            [int]$endLineNumber,
            [int]$startColumnNumber,
            [int]$endColumnNumber,
            [string]$correctionText,
            [string]$corruptionFile,
            [string]$corruptionDescription
        )
    )
    $Extent = [System.Management.Automation.Language.ScriptExtent]::new(
        [System.Management.Automation.Language.ScriptPosition]::new(
            # Start Extent
            [string]$scriptName,
            [int]$startLineNumber,
            [int]$startOffsetInLine,
            [string]$startLine
        ),
        [System.Management.Automation.Language.ScriptPosition]::new(
            # End Extent
            [string]$scriptName,
            [int]$endLineNumber,
            [int]$endOffsetInLine,
            [string]$endLine
        )
    )

    $DiagRecord = [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
        "Message" = $message
        "Extent" = $Extent
        "RuleName" = $ruleName
        "Severity" = $severity
        "scriptPath" = $scriptPath
        "SuggestedCorrections" = $ExtentCollection
    }
    #$DiagRecord | Add-Member -MemberType ScriptProperty -Name Column -Value {$This.Extent.StartColumnNumber}
    #$DiagRecord | Add-Member -MemberType ScriptProperty -Name Line -Value {$This.Extent.StartLineNumber}

    Return $DiagRecord
}