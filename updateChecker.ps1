$enlangmap = @{
    '1' = "Kirkwood Software Updater"
    '2' = "must be updated"
    '3' = "newer version is"
    '4' = "Please launch the main Deploy Script when you have time."
    '5' = "-------------------------"
    '6' = "Press any key to close..."
}

$frlangmap = @{
    '1' = "Assistant de Mise-à-Jour des produits Kirkwood Software"
    '2' = "doivent être mis-à-jour"
    '3' = "la dernière version est"
    '4' = "Merci de lancer le DeployScript principal quand vous avez du temps"
    '5' = "-------------------------------------------------------"
    '6' = "Appuyez sur n'importe quelle touche pour fermer..."
}

Write-Output $langmap['1']
Write-Output $langmap['5']
Write-Output " "

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


$credentials="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"
$headers = @{
    'Authorization' = "token $credentials"
    'Accept' = 'application/vnd.github+json'
}


foreach ($repo in $versionsOnPC.Keys){
    $repo = "silloky/$repo"
    $releases = "https://api.github.com/repos/$repo/releases"
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
