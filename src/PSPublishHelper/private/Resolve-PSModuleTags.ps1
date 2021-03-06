function Resolve-PSModuleTags {
    [CmdletBinding()]
    param (
        [PSModuleInfo]
        $Module,

        [String[]]
        $Tags
    )
    end {
        $TagsList = [System.Collections.Generic.HashSet[String]]::new()
        foreach($Tag in $Tags) {
            $null = $TagsList.Add($Tag)
        }

        $null = $TagsList.add('PSModule')

        foreach($Cmdlet in $Module.ExportedCmdlets.Keys) {
            $null = $TagsList.Add('PSIncludes_Cmdlet')
            $null = $TagsList.add(('PSCmdlet_{0}' -f $Cmdlet))
        }

        foreach($Func in $Module.ExportedFunctions.Keys) {
            $null = $TagsList.Add('PSIncludes_Function')
            $null = $TagsList.add(('PSFunction_{0}' -f $func))
        }

        foreach($Command in $Module.ExportedCommands.Keys) {
            $null = $TagsList.add(('PSCommand_{0}' -f $Command))
        }

        if(!$IsCoreCLR) {
          foreach ($DscResource in (Get-ExportedDscResources -Module $Module -ErrorAction SilentlyContinue)) {
              $null = $TagsList.Add('PSIncludes_DscResource')
              $null = $TagsList.add(('PSDscResource_{0}' -f $DscResource))
          }
        } else {
          Write-Verbose 'Skipping DSC resource enumeration as it is not supported on PS Core.'
          Write-Verbose 'Please use Windows PowerShell to build DSC modules.'
        }


        foreach ($Role in (Get-AvailableRoleCapabilityName -Module $Module)) {
            $null = $TagsList.Add('PSIncludes_RoleCapability')
            $null = $TagsList.add(('PSRoleCapability_{0}' -f $Role))
        }

        $TagsList -join ' '
    }
}
