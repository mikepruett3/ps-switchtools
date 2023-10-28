function Get-SavesDir {
    <#
    .SYNOPSIS
        Returns a list of located Nintento Swtich Save Files, with additional
        information
    .DESCRIPTION
        Collects a list of Save Folders with Nintendo Switch Title information
        including the Name, Publisher, and Directory and returns as a list object
    .PARAMETER LocationCode
        Two letter Country Location code. Review codes from https://locode.info

        Default LocationCode is "US", for United States
    .PARAMETER LanguageCode
        Two letter SO 639-1 Language code. Review codes from https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

        Default LanguageCode is "en", for English
    .EXAMPLE
        > Get-SavesDir -LocationCode "GR" -LanguageCode "en"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [string]
        $LocationCode,
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [string]
        $LanguageCode
    )

    begin {
        # NAND Variable
        Write-Verbose "Removing existing SavesDir Global Variable"
        Remove-Variable -Name "SavesDir" -Scope Global -ErrorAction SilentlyContinue

        # Title Database Variable
        Write-Verbose "Checking for a Title Database Variable"
        if (!(Test-Path Variable:Global:TitleDB)) {
            Get-TitleDB -LocationCode ${LocationCode} -LanguageCode ${LanguageCode}
        }

        # Collect Title Database JSON file properties into $TitleDB Variable
        Write-Verbose "Collect Title Database JSON file properties into TitleDB Variable"
        $Database = (Get-Content -Raw -Path "${TitleDB}" | ConvertFrom-Json).PSObject.Properties.Value

        # NAND Variable
        Write-Verbose "Checking for a NAND Variable"
        if (!(Test-Path Variable:Global:NAND)) {
            Get-YuzuInfo
        }

        # Results
        $Results = @()
    }

    process {
        # Collect the list of Save Directores from $NAND directory
        Write-Verbose "Collect the list of Save Directores from $NAND directory..."
        $SaveDir = (Get-ChildItem -Path "$NAND").Name

        foreach ($Folder in $SaveDir) {
            # Handle Symbolic Link Folders
            if ((Get-Item -Path "$NAND\$Folder").LinkType -eq "SymbolicLink") {
                $Directory = (Get-Item -Path "$NAND\$Folder").Target
            } else {
                $Directory = "$NAND\$Folder"
            }

            $Item = [PSCustomObject]@{
                ID = $Folder
                Name = $Database | Where-Object {$_.id -contains $Folder} | Select-Object -ExpandProperty Name
                Publisher = $Database | Where-Object {$_.id -contains $Folder} | Select-Object -ExpandProperty Publisher
                Directory = $Directory
            }
            $Results += $Item
        }

        # Set $SavesDir Global Variable
        Write-Verbose "Setting the TitleDB Global Variable..."
        Set-Variable -Name "SavesDir" -Value $Results -Scope Global -ErrorAction SilentlyContinue
    }

    end {
        # Cleanup Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "LocationCode" -ErrorAction SilentlyContinue
        Remove-Variable -Name "LanguageCode" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Database" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Results" -ErrorAction SilentlyContinue
        Remove-Variable -Name "SaveDir" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Folder" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Directory" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Item" -ErrorAction SilentlyContinue
    }
}



