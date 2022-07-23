function creatingLoading {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $fileORdir,
        [Parameter(Mandatory = $true, Position = 0)] [string] $createpath,
        [Parameter(Mandatory = $true, Position = 0)] [string] $createname
    )
    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] Creating $fileORdir : $createpath..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] Creating $fileORdir : $createpath..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    if ($fileORdir -eq "file"){
        $pathtype = "Leaf"
    } elseif ($fileORdir -eq "directory"){
        $pathtype = "Container"
    }
    $createExists = (Test-Path -Path $createpath -PathType $pathtype)
    if ($createExists -eq $false) {
        $null = New-Item -Path "$createpath" -Value "$foldername" -ItemType "directory"
        Write-Host "`r[✓] Creating $fileORdir : $createpath... Done !"
    } else {
        Write-Host "`r[✗] Creating $fileORdir : $createpath... Failed ($fileORdir already exists)"
    }
}

function dlGitHub {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $repo,
        [Parameter(Mandatory = $true, Position = 0)] [bool] $innerDirectory,
        [Parameter(Mandatory = $true, Position = 0)] [string] $filenamePattern,
        [Parameter(Mandatory = $true, Position = 0)] [string] $pathExtract,
        [Parameter(Mandatory = $true, Position = 0)] [bool] $preRelease
    )
    if ($preRelease) {
        $releasesUri = "https://api.github.com/repos/$repo/releases"
        $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri)[0].assets | Where-Object name -like $filenamePattern ).browser_download_url
    } else {
        $releasesUri = "https://api.github.com/repos/$repo/releases/latest"
        $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -like $filenamePattern ).browser_download_url
    }

    $pathZip = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $(Split-Path -Path $downloadUri -Leaf)

    Invoke-WebRequest -Uri $downloadUri -Out $pathZip

    Remove-Item -Path $pathExtract -Recurse -Force -ErrorAction SilentlyContinue

    if ($innerDirectory) {
        $tempExtract = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $((New-Guid).Guid)
        Expand-Archive -Path $pathZip -DestinationPath $tempExtract -Force
        Move-Item -Path "$tempExtract\*" -Destination $pathExtract -Force
        #Move-Item -Path "$tempExtract\*\*" -Destination $location -Force
        Remove-Item -Path $tempExtract -Force -Recurse -ErrorAction SilentlyContinue
    } else {
        Expand-Archive -Path $pathZip -DestinationPath $pathExtract -Force
    }

    Remove-Item $pathZip -Force
}


$newInstallOptions_currentOptionName = @{
    '1' = 'CodeChecker'
    '2' = 'ShoppingLister'
    '3' = 'MorseCode'
    '4' = 'ServerDeploy'
    '5' = 'BackupDeploy'
}


Write-Output " _  ___      _                            _     _____        __ _                          "
Write-Output "| |/ (_)    | |                          | |   / ____|      / _| |                         "
Write-Output "| ' / _ _ __| | ___      _____   ___   __| |  | (___   ___ | |_| |___      ____ _ _ __ ___ "
Write-Output "|  < | | '__| |/ \ \ /\ / / _ \ / _ \ / _` |   \___ \ / _ \|  _| __\ \ /\ / / _` | '__/ _ \"
Write-Output "| . \| | |  |   < \ V  V | (_) | (_) | (_| |   ____) | (_) | | | |_ \ V  V | (_| | | |  __/"
Write-Output "|_|\_|_|_|  |_|\_\ \_/\_/_\___/ \___/ \__,_|  |_____/ \___/|_|  \__| \_/\_/ \__,_|_|  \___|"
Write-Output "                         |  __ \           | |                                             "
Write-Output "                         | |  | | ___ _ __ | | ___  _   _                                  "
Write-Output "                         | |  | |/ _ | '_ \| |/ _ \| | | |                                 "
Write-Output "                         | |__| |  __| |_) | | (_) | |_| |                                 "
Write-Output "                         |_____/ \___| .__/|_|\___/ \__, |                                 "
Write-Output "                                     | |             __/ |                                 "
Write-Output "                                     |_|            |___/                                  "
Write-Output "==========================================================================================="
Write-Output "==========================================================================================="
Write-Output " "
Write-Output "Welcome ! This utility allows you to install and configure all - or only some, you can choose - programs developed by Kirkwood Software"

if ((Test-Path -Path "$env:APPDATA\Kirkwood Soft.") -eq $false){
    $new = $true
    Write-Output "As this is your first time installing Kirkwood Soft. products, we will be going through the installation step-by-step."
    Write-Output "------------------------------------------------------------------------------------------"
    Write-Output "First of all, let's select the programs you want to install :"
    Write-Output "      1. CodeChecker                  4. ServerDeploy"
    Write-Output "      2. ShoppingLister               5. BackupDeploy"
    Write-Output "      3. MorseCodeTranscoder"
    Write-Output " "
    $newInstallOptions_List = Read-Host  "Please type in the numbers of programs you want to install separated by spaces (i.e. 2 3 5) "
    $newInstallOptions_Array = $newInstallOptions_List.Split(" ")
    Write-Output " "
    Write-Output "Great ! Now one last question : where do you want to install the programs ?"
    Write-Output "  - System-wide (any user can access, installed in the program files directory"
    Write-Output "  - User-limited (only you have access to the programs, installed in the AppData directory"
    $installLocation = Read-Host "So ? Where ? [S | U] " 
    Write-Output " "
    Write-Output "The installation will now begin..."
    Start-Sleep 2
} else {
    $new = $false
    Write-Output "As you already have some of our products installed, what do you wish to do :"
    Write-Output " "
    Write-Output "  1. Update (keep config)             3. Reinstall same version (fresh, reconfigure)"
    Write-Output "  2. Update (fresh, reconfigure)      4. Uninstall (removes config and binaries)"
    $alreadyInstalledActionNumber = Read-Host "Please type ONE number after the 2 dots "
}


if ($new -eq $true){
    Write-Output " "
    Write-Output "=========================================================================================="
    Write-Output "Creating main directories :"
    if ($installLocation -eq "S"){
        $binairiesDir = "$env:programfiles\Kirkwood Soft"
        $pathname = "Kirkwood Soft"
        $userDataDir = "$env:appdata\Kirkwood Soft"
    } elseif ($installLocation -eq "U"){
        $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
        $pathname = "kirkwood Soft"
        $userDataDir = "$env:appdata\Kirkwood Soft\data"
    }
    creatingLoading -fileORdir "directory" -createpath "$binairiesDir" -createname "$pathname"
    creatingLoading -fileORdir "directory" -createpath "$userDataDir" -createname "$pathname"
    Write-Output " "
    Write-Output "=========================================================================================="
    Write-Output "Creating software directories :"
    foreach ($newInstallOptions_currentOption in $newInstallOptions_Array){
        $currentProgramName = $newInstallOptions_currentOptionName["$newInstallOptions_currentOption"]
        creatingLoading -fileORdir "directory" -createpath "$binairiesDir\$currentProgramName" -createname "$currentProgramName"
        creatingLoading -fileORdir "directory" -createpath "$userDataDir\$currentProgramName" -createname "$currentProgramName"
    }
}elseif ($new -eq $false){

}

Pause




