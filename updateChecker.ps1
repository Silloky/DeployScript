function Decrypt {
    Param(
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeLine=$true)] [Alias("String")] [String]$EncryptedString,
    
        [Parameter(Mandatory=$True, Position=1)] [Alias("Key")] [byte[]]$EncryptionKey
    )
    Try{
        $SecureString = ConvertTo-SecureString $EncryptedString -Key $EncryptionKey
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        [string]$String = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

        Return $String
    }
    Catch{Throw $_}
}

$enlangmap = @{
    '1' = "Kirkwood Software Updater"
    '2' = "must be updated"
    '3' = "newer version is"
    '4' = "Please launch the main Deploy Script when you have time."
    '5' = "-------------------------"
    '6' = "Press any key to close..."
    '7' = "Please enter the security key given to you during the training "
}

$frlangmap = @{
    '1' = "Assistant de Mise-à-Jour des produits Kirkwood Software"
    '2' = "doivent être mis-à-jour"
    '3' = "la dernière version est"
    '4' = "Merci de lancer le DeployScript principal quand vous avez du temps"
    '5' = "-------------------------------------------------------"
    '6' = "Appuyez sur n'importe quelle touche pour fermer..."
    '7' = "Veuillez entrer la clé de sécurité qui vous a été donnée lors de la formation "
}

if (Test-Path -Path "$env:programfiles\Kirkwood Soft"){
    $binairiesDir = "$env:programfiles\Kirkwood Soft"
} elseif (Test-Path -Path "$env:appdata\Kirkwood Soft\binairies") {
    $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
}

if ((Get-Content -Path "$binairiesDir\LANGUAGE.txt") -eq "FR"){
    $langmap = $frlangmap
} elseif ((Get-Content -Path "$binairiesDir\LANGUAGE.txt") -eq "EN"){
    $langmap = $enlangmap
}

Write-Output $langmap['1']
Write-Output $langmap['5']
Write-Output " "

$files = @(Get-ChildItem -Path "$binairiesDir\VERSION.txt" -Recurse -Force | ForEach-Object{$_.FullName})

$versionsOnPC = @{}
$versionsOnGitHub = @{}
$toBeUpdated = @{}

foreach ($i in $files){
    $text = (Get-Content -Path "$i")
    $text = $text.Replace(" ","")
    $things = $text.Split("=")
    $versionsOnPC.Add($things[0], $things[1])
}

$token = "76492d1116743f0423413b16050a5345MgB8AFgAUQBqAE8AcgA0AEgAaQBpAEgAQQBjAHYAagBTAHIARgBNADAALwA2AFEAPQA9AHwAZQBjADUAYQA2AGIAYwA2AGUANwBjADEANQA5ADAAOAA1ADgAOABlADEAMAAxADUAOQA2AGEAZQA1AGQANQAwADcANABmAGYAZgA3ADQAZAA4AGIAMQAyADgAYwBlADYAZgA1ADMAYwBhADMAMgAyADAANgA2ADIANAA4AGQAMwA0ADcAZgAyAGQAYwBlADgAYQA3ADIAZQA0AGEAOQAxADYAMAA1ADQAMgA2AGMAZQBhAGYANwA5ADIANgBhADQAOQA0ADMAMgBhAGQANQA1AGUAMgBjADgAYQA1ADUANABmADkAYgA4ADIAMAAxAGYANABhADIAZgAyAGEAOQA4ADcAMwAzADUAZAA1ADkAYwAyADQAOABlADUAOABlAGIANwAwADAAZABlADcAYgBkADMAYwA4ADMAZgBjAGUAMgBjADQAMABkADIAYwA3ADUAMwBhADgAOQAyADIAMgAwAGQAYwA1AGEAMgAyADkAZQAzADAAOQBlADYAMABkADEA"
$key = "Computer Science"
$enc = [system.Text.Encoding]::UTF8
[byte[]]$byteKey = $enc.GetBytes($key)
$credentials = Decrypt -EncryptedString "$token" -EncryptionKey $byteKey
$headers = @{
    'Authorization' = "token $credentials"
    'Accept' = 'application/vnd.github+json'
}
Remove-Variable -Name "key"


foreach ($repo in $versionsOnPC.Keys){
    $repoWithName = "silloky/$repo"
    $releases = "https://api.github.com/repos/$repoWithName/releases"
    $versionOnGitHubCode = (Invoke-WebRequest $releases -Headers $headers | ConvertFrom-Json)[0].tag_name
    $versionOnGitHubNumber = $versionOnGitHubCode.replace('v','')
    $versionsOnGitHub.Add($repo, $versionOnGitHubNumber)
}


foreach ($repo in $versionsOnPC.Keys){
    $currentPCValue = $versionsOnPC["$repo"]
    $currentGitHubValue = $versionsOnGitHub["$repo"]
    if ([System.Version]"$currentGitHubValue" -gt [System.Version]"$currentPCValue"){
        $toBeUpdated.Add($repo, $currentGitHubValue)
    }
}

if ($toBeUpdated -ne $null){
    Write-Output "$($toBeUpdated.Length) $($langmap['2']) :"
    foreach ($key in $toBeUpdated.Keys){
        Write-Output "      - $key : $($langmap['3']) v$($toBeUpdated["$key"])"
    }
    Write-Output $langmap['4']
    Write-Output $langmap['6']
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}
exit
