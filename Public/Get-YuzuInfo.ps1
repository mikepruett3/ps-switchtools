function Get-YuzuInfo {
    <#
    .SYNOPSIS
        Set information about local Yuzu Saves directory
    .DESCRIPTION
        Checks for the existance of the default Yuzu Saves directory,
        and returns a $NAND variable
    .PARAMETER UserID
        Sixteen character (16) User ID code, default is 0000000000000000

        Refer https://yuzu-emu.org/wiki/user-directory/
    .EXAMPLE
        > Get-YuzuInfo -UserID "0000000000000000"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [string]
        $UserID = "0000000000000000"
    )

    begin {
        # NAND Variable
        Write-Verbose "Removing existing NAND Global Variable"
        Remove-Variable -Name "NAND" -Scope Global -ErrorAction SilentlyContinue

        # Yuzu Default Profile directory
        $Yuzu = "${Env:AppData}\yuzu"

        # Test if Yuzu Default Profile directory exists
        Write-Verbose "Test if Yuzu Default Profile directory exists..."
        if (!(Test-Path -Path ${Yuzu} -PathType Container)) {
            Write-Error "Cannot find Yuzu Default Profile directory!!!"
            Break
        }

        # Yuzu Default Saves directory
        $SavesDir = "${Yuzu}\nand\user\save"

        # Test if Yuzu Default Saves directory exists
        Write-Verbose "Test if Yuzu Default Saves directory exists..."
        if (!(Test-Path -Path ${SavesDir} -PathType Container)) {
            Write-Error "Cannot find Yuzu Default Saves directory!!!"
            Break
        }

        # Test if Yuzu Default User ID directory exists
        Write-Verbose "Test if Yuzu Default User ID directory exists..."
        if (!(Test-Path -Path ${SavesDir}\${UserID} -PathType Container)) {
            Write-Error "Cannot find Yuzu Default User ID directory!!!"
            Break
        }

        # Collect a list of Console ID directories
        $ConsoleIDDirs = (Get-ChildItem -Path ${SavesDir}\${UserID} -Directory).Name
        Write-Output "Found the following Console ID's..."
        Write-Output " "
        Write-Verbose "Setting the Console ID to use..."
        Write-Output $ConsoleIDDirs
        Write-Output " "
        $ConsoleID = Read-Host "Select a Console ID to use"

        # Test if Yuzu Default Console ID directory exists
        Write-Verbose "Test if Yuzu Default Console ID directory exists..."
        if (!(Test-Path -Path ${SavesDir}\${UserID}\${ConsoleID} -PathType Container)) {
            Write-Error "Cannot find Yuzu Default Console ID directory!!!"
            Break
        }
    }

    process {
        # Set $NAND Global Variable
        Write-Verbose "Setting the NAND Global Variable..."
        Set-Variable -Name "NAND" -Value ${SavesDir}\${UserID}\${ConsoleID} -Scope Global -ErrorAction SilentlyContinue
    }

    end {
        # Cleanup Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "UserID" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ConsoleIDDirs" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ConsoleID" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Yuzu" -ErrorAction SilentlyContinue
        Remove-Variable -Name "SavesDir" -ErrorAction SilentlyContinue
    }
}