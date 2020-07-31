Function Export-NUnit {
<#
.SYNOPSIS
    Export DiagnosticRecord objects generated from PSScriptAnalyzer as nUnit formatted xml.
#>
[CmdletBinding()]
Param (
    [Parameter(Mandatory,ValueFromPipeline)]
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]$ScriptAnalyzerResults,
    [Parameter(Mandatory=$True)]
        [string]$OutputFile
)

Begin {
    
    [xml]$xmlDoc = New-Object System.Xml.XmlDocument
    $xmlDoc.AppendChild(
        $xmlDoc.CreateXmlDeclaration("1.0", "utf-8", $null)
    )
    
    $nUnitRoot = $xmldoc.CreateNode("element", "test-results", $null)
        $nUnitRoot.SetAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
        $nUnitRoot.SetAttribute("xsi:noNamespaceSchemaLocation", "nunit_schema_2.5.xsd")
        $nUnitRoot.SetAttribute("name", "PSScriptAnalyzer")
        $nUnitRoot.SetAttribute("total", [string]$ScriptAnalyzerResult.Count)
        $nUnitRoot.SetAttribute("errors", [string]$ScriptAnalyzerResult.Where({$_.Severity -eq 'ParseError'}).Count)
        $nUnitRoot.SetAttribute("failures", [string]$ScriptAnalyzerResult.Count)
        $nUnitRoot.SetAttribute("date", $(get-date -f yyyy-MM-dd))
        $nUnitRoot.SetAttribute("time", $(get-date -f HH:mm:ss))
    
        $environmentNode = $nUnitRoot.AppendChild(
                $xmlDoc.CreateElement("environment")
        )
        $environmentNode.SetAttribute("platform", [System.Environment]::OSVersion.VersionString)
        $environmentNode.SetAttribute("machine-name", [System.Environment]::MachineName)
        $environmentNode.SetAttribute("cwd", $pwd.Path)
        $environmentNode.SetAttribute("user-domain", [System.Environment]::UserDomainName)
        $environmentNode.SetAttribute("nunit-version", "2.5.8.0")
        $environmentNode.SetAttribute("clr-version", "Unknown")
        $environmentNode.SetAttribute("os-version", $PSVersionTable.OS )
        $environmentNode.SetAttribute("user", [System.Environment]::UserName)

        $cultureNode = $nUnitRoot.AppendChild(
            $xmlDoc.CreateElement("culture-info")
        )
        $cultureNode.SetAttribute("current-culture", (Get-Culture).Name)
        $cultureNode.SetAttribute("current-uiculture", (Get-UICulture).Name)

} # Begin

Process {

    ForEach ($Result in $ScriptAnalyzerResults) {

        ForEach ($Property in $Result.PsObject.Properties) {
            If (-Not([System.Security.SecurityElement]::IsValidText($Property))) {
                $Result.$($Property.Name) = [System.Security.SecurityElement]::Escape($Property)
            }
        }

        $testsuiteNode = $nUnitRoot.AppendChild(
            $xmlDoc.CreateElement("test-suite")
        )
        $testsuiteNode.SetAttribute("type", "TestFixture")
        $testsuiteNode.SetAttribute("name", $Result.ScriptName)
        $testsuiteNode.SetAttribute("executed", "True")
        $testsuiteNode.SetAttribute("result", "Failure")
        $testsuiteNode.SetAttribute("success", "False")
        $testsuiteNode.SetAttribute("time", "0")
        $testsuiteNode.SetAttribute("asserts", "0")
        $testsuiteNode.SetAttribute("description", $Result.RuleName )
        
            $resultsNode = $testsuiteNode.AppendChild(
                $xmlDoc.CreateElement("results")
            )
            
                $testcaseNode = $resultsNode.AppendChild(
                    $xmlDoc.CreateElement("test-case")
                )
                $testcaseNode.SetAttribute("description", "$($Result.Severity) : $($Result.RuleName) : Violation occurred in $($Result.ScriptName)")
                $testcaseNode.SetAttribute("name", "$($Result.RuleName) in $($Result.ScriptName)")
                $testcaseNode.SetAttribute("time", "0")
                $testcaseNode.SetAttribute("asserts", "0") 
                $testcaseNode.SetAttribute("success", "False") 
                $testcaseNode.SetAttribute("result", "Failure") 
                $testcaseNode.SetAttribute("executed", "True")

                    $failureNode = $testcaseNode.AppendChild(
                        $xmlDoc.CreateElement("failure")
                    )
                        $messageNode = $failureNode.AppendChild(
                            $xmlDoc.CreateElement("message")
                        )
                        $messageNode.InnerText = $Result.Message

                        $stacktraceNode = $failureNode.AppendChild(
                            $xmlDoc.CreateElement("stack-trace")
                        )
                        $failureNode.InnerText = ("
                        File: $($Result.Extent.File.Trim())
                        StartLineNumber: $($Result.Extent.StartLineNumber)
                        StartColumnNumber: $($Result.Extent.StartColumnNumber)
                        EndLineNumber: $($Result.Extent.EndLineNumber)
                        EndColumnNumber: $($Result.Extent.EndColumnNumber)
                        Text: $($Result.Extent.Text.Trim())
                        Line: $($Result.Extent.StartScriptPosition.Line.Trim())
                        ")

    }
    
} # Process

End {

    $xmlDoc.AppendChild($nunitRoot)
    $xmlDoc.Save($OutputFile)

} # End

}