function Get-TitleDB {
    <#
    .SYNOPSIS
        Download latest Nintendo Switch Title Database file
    .DESCRIPTION
        Downloads the latest appropriate Nintendo Switch Title Database file
        from blawar's Github Repository.

        Default download location is the Profile %TEMP% directory
    .NOTES
        Thanks to blawar for maintaining this treasure trove of information!
    .LINK
        blawar's Github Repository - https://github.com/blawar/titledb
    .PARAMETER LocationCode
        Two letter Country Location code. Review codes from https://locode.info

        Default LocationCode is "US", for United States
    .PARAMETER LanguageCode
        Two letter SO 639-1 Language code. Review codes from https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

        Default LanguageCode is "en", for English
    .EXAMPLE
        >Get-TitleDB -LocationCode "GR" -LanguageCode "en"
        OR
        >Get-TitleDB
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
        # Base URL
        $BaseURL = "https://github.com/blawar/titledb/raw/master"

        # Title Database
        Write-Verbose "Removing existing TitleDB Global Variable"
        Remove-Variable -Name "TitleDB" -Scope Global -ErrorAction SilentlyContinue
        Write-Verbose "Configuring TitleDB File Name - ${LocationCode}.${LanguageCode}.json"
        $TitleDB = "${LocationCode}.${LanguageCode}.json"

        # URL
        Write-Verbose "Configuring URL - ${BaseURL}/${TitleDB}"
        $URL = "${BaseURL}/${TitleDB}"

        # Destination
        Write-Verbose "Configuring Destination Path - ${Env:Temp}\${TitleDB}"
        $Destination = "${Env:Temp}\${TitleDB}"
    }

    process {
        # Collect Creation Date of existing Title Database JSON file
        if (Test-Path -Path ${Destination} -OlderThan (Get-Date).AddDays(-1)) {
            # Download the latest Title Database JSON file
            Write-Verbose "Downloading ${TitleDB} file from ${URL}..."
            Invoke-WebRequest -Uri ${URL} -OutFile ${Destination}
        }

        # Set $TitleDB Global Variable
        Write-Verbose "Setting the TitleDB Global Variable..."
        Set-Variable -Name "TitleDB" -Value ${Destination} -Scope Global -ErrorAction SilentlyContinue
    }

    end {
        # Cleanup Variables
        Write-Verbose "Cleaning up used Variables..."
        Remove-Variable -Name "LocationCode" -ErrorAction SilentlyContinue
        Remove-Variable -Name "LanguageCode" -ErrorAction SilentlyContinue
        Remove-Variable -Name "BaseURL" -ErrorAction SilentlyContinue
        Remove-Variable -Name "URL" -ErrorAction SilentlyContinue
        Remove-Variable -Name "Destination" -ErrorAction SilentlyContinue
    }
}