function Invoke-SavesBackup {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [string]
        $LocationCode = "US",
        [Parameter(Mandatory=$False, ValueFromPipeline=$True)]
        [string]
        $LanguageCode = "en",
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string]
        $Target
    )

    begin {
        # Create Timestamp Variable
        $Timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }

        # Strip last "\" from $Target, if included
        $Target = $Target.TrimEnd('\')

        # SavesDir Variable
        Write-Verbose "Checking for a SavesDir Variable"
        if (!(Test-Path Variable:Global:SavesDir)) {
            Get-SavesDir -LocationCode ${LocationCode} -LanguageCode ${LanguageCode}
        }
    }

    process {
        Write-Verbose "Creating a backup for each Save found in the SavesDir..."
        foreach ($Title in $SavesDir) {
            $Name = $Title.Name | ForEach-Object { $_ -replace ":", " -" }
            #$ID = $Title.ID
            $Directory = $Title.Directory
            #$FileName = $Name + "_(" + $ID + ")_" + $Timestamp
            $FileName = $Name + "_ " + $Timestamp
            Write-Verbose "Creating archive of $Name Saves in $Target ..."
            Compress-Archive -Path "$Directory" -DestinationPath "$Target\$FileName.zip"
        }
    }

    end {
        # Cleanup Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "LocationCode" -ErrorAction SilentlyContinue
        Remove-Variable -Name "LanguageCode" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Target" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Timestamp" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Title" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Name" -ErrorAction SilentlyContinue
        Remove-Variable -Name "ID" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Directory" -ErrorAction SilentlyContinue
        Remove-Variable -Name "FileName" -ErrorAction SilentlyContinue
    }
}