[CmdletBinding(DefaultParametersetName = "Single")]

Param (
    [Parameter(
        Mandatory = $True
    )]
    [ValidateSet("Encrypt", "Decrypt")]
    [String] $Task,

    [Parameter(
        Mandatory = $True,
        ParameterSetName = "Single"
    )]
    [ValidateRange(1, 25)]
    [Int] $Door,

    [Parameter(
        Mandatory = $True,
        ParameterSetName = "Single"
    )]
    [ValidateSet("A", "B")]
    [String] $Part,

    [Parameter(
        Mandatory = $True,
        ParameterSetName = "Single"
    )]
    [String] $Solution,

    [Parameter(
        Mandatory = $True,
        ParameterSetName = "All"
    )]
    [Switch] $All
)

.".\EncryptDecryptString.ps1"

Function Invoke-Crypt($Path, $Passphrase) {
    $Content = Get-Content -Path $Path
    $BaseName = (Get-Item -Path $Path).BaseName
    $Out = ""

    If ($Content) {
        $ContentRaw = (Get-Content -Path $Path -Raw) -replace ("(`r|`n|`r`n)ENCRYPTED", "")

        If ($Task -Eq "Encrypt") {
            If ($Content[1] -Ne "ENCRYPTED") {
                $Out = @"
$(Encrypt-String -String $ContentRaw -Passphrase $Passphrase)
ENCRYPTED
"@
            } Else {
                Write-Warning "`"$BaseName`" is already encrypted."
            }
        } Else {
            If ($Content[1] -Eq "ENCRYPTED") {
                $Out = Decrypt-String -Encrypted $ContentRaw -Passphrase $Passphrase
            } Else {
                Write-Warning "`"$BaseName`" is already decrypted."
            }
        }

        If ($Out) {
            [System.IO.File]::WriteAllLines($Path, $Out)
            Write-Host "${Task}ed $BaseName." -ForegroundColor "Green"
        }
    }
}

If ($All) {
    $Env = New-Object PSCustomObject

    Get-Content "$PSScriptRoot\.env" | Where-Object {
        $PSItem -Ne ""
    } |
        ForEach-Object {
        $EnvParts = $PSItem.Split("=")

        If ($EnvParts[1]) {
            $Env | Add-Member -MemberType "NoteProperty" -Name $EnvParts[0] -Value $EnvParts[1]
        }
    }

    Get-ChildItem -Path "Door *.js" -File -Recurse | ForEach-Object {
        $EnvValue = $Env.PSObject.Properties[$PSItem.BaseName.Replace("Door ", "")].Value

        If ($EnvValue) {
            Invoke-Crypt -Path $PSItem.FullName -Passphrase $EnvValue
        }
    }
} Else {
    $LeadingDoor = ""

    If ($Door.length -Lt 10) {
        $LeadingDoor = "0"
    }

    $Path = Join-Path -Path $PSScriptRoot -ChildPath "Door $LeadingDoor$Door" | Join-Path -ChildPath "Door $Door$Part.js"

    Invoke-Crypt -Path $Path -Passphrase $Solution
}
