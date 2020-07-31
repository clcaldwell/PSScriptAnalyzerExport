Function Export-Checkstyle {
<#
.SYNOPSIS
    Export DiagnosticRecord objects generated from PSScriptAnalyzer as Checkstyle formatted xml.
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
    
    $checkstyleRoot = $xmldoc.CreateNode("element", "checkstyle", $null)
        $checkstyleRoot.SetAttribute("version", "4.3")

}

Process {
    
    ForEach ($Result in $ScriptAnalyzerResults) {

        ForEach ($Property in $Result.PsObject.Properties) {
            If ( -Not ([System.Security.SecurityElement]::IsValidText($Property) ) ) {
                $Result.$($Property.Name) = [System.Security.SecurityElement]::Escape($Property)
            }
        }

        $fileNode = $checkstyleRoot.SelectSingleNode("//file[@name='$($Result.Scriptname)']")
        If ( $Null -eq $fileNode ) {
            $fileNode = $checkstyleRoot.AppendChild(
                $xmlDoc.CreateElement("file")
            )
            $fileNode.SetAttribute("name", $Result.ScriptName)
        }
        
            $errorNode = $fileNode.AppendChild(
                $xmlDoc.CreateElement("error")
            )
            $errorNode.SetAttribute("line", $Result.Line)
            $errorNode.SetAttribute("column", $Result.Column)
            $errorNode.SetAttribute("severity", $Result.Severity)
            $errorNode.SetAttribute("message", $Result.Message)
            $errorNode.SetAttribute("source", $Result.RuleName)
    }
}

End {
    
    $xmlDoc.AppendChild($checkstyleRoot)
    $xmlDoc.Save($OutputFile)

}

}