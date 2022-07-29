﻿$versionofDeployScript = "1.0.1"

function creatingLoading {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $createType,
        [Parameter(Mandatory = $true, Position = 0)] [string] $createpath,
        [Parameter(Mandatory = $false, Position = 0)] [string] $createname,
        [Parameter(Mandatory = $false, Position = 0)] [string] $shortcutDestPath,
        [Parameter(Mandatory = $true, Position = 0)] [string] $lang
    )

    $enlangmap = @{
        1 = "Creating"
        2 = "Done !"
        3 = "Failed"
        4 = "already exists"
        'directory' = "directory"
        'shortcut' = "shortcut"
        'file' = "file"
    }

    $frlangmap = @{
        1 = "Creation"
        2 = "Terminé !"
        3 = "Erreur"
        4 = "existe déjà"
        "directory" = "répertoire"
        "shortcut" = "raccourci"
        "file" = "fichier"

    }
    
    if ($lang -eq "FR"){
        $langmap = $frlangmap
    } elseif ($lang -eq "EN"){
        $langmap = $enlangmap
    }

    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] $($langmap.1) $createType : $createpath ..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.1) $createType : $createpath..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)

    if ($createType -eq "file"){
        $pathtype = "Leaf"
    } elseif ($createType -eq "directory"){
        $pathtype = "Container"
    } elseif ($createType -eq "shortcut") {
        $pathtype = "Leaf"
    }
    $createExists = (Test-Path -Path $createpath -PathType $pathtype)
    
    if ($createExists -eq $false) {
        if (($createType -eq "file") -or ($createType -eq "directory")){
            $null = New-Item -Path "$createpath" -Value "$foldername" -ItemType "directory"
            Write-Host "`r[✓] $($langmap.1) $($langmap["$createType"]) : $createpath... $($langmap.2)"
        } elseif ($createType -eq "shortcut"){
            $WScriptObj = New-Object -ComObject ("WScript.Shell")
            $shortcut = $WscriptObj.CreateShortcut($createpath)
            $shortcut.TargetPath = $shortcutDestPath
            $shortcut.Save()
        }
    } else {
        Write-Host "`r[✗] $($langmap.1) $($langmap["$createType"]) : $createpath... $($langmap.3) ($createType $($langmap.4))"
    }
}

function dlGitHub {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $repo,
        [Parameter(Mandatory = $true, Position = 0)] [string] $endLocation,
        [Parameter(Mandatory = $true, Position = 0)] [string] $file,
        [Parameter(Mandatory = $true, Position = 0)] [string] $lang
    )
    #language setup
    $enlangmap = @{
        1 = "Determining latest release"
        2 = "Done !"
        3 = "Downloading latest release"
        4 = "Extracting archive (zip)"
        5 = "Cleaning up"
    }

    $frlangmap = @{
        1 = "Détermination de la dernière version"
        2 = "Terminé !"
        3 = "Téléchargement de la dernière version"
        4 = "Extraction de l'archive (zip)"
        5 = "Nettoyage"
    }
    
    if ($lang -eq "FR"){
        $langmap = $frlangmap
    } elseif ($lang -eq "EN"){
        $langmap = $enlangmap
    }

    #variable setup
    $credentials="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"
    $repo = "silloky/$repo"
    $headers = @{
        'Authorization' = "token $credentials"
        'Accept' = 'application/vnd.github+json'
    }
    $releases = "https://api.github.com/repos/$repo/releases"

    #determine latest release
    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] $($langmap.1)..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.1)..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    $id = ((Invoke-WebRequest $releases -Headers $headers | ConvertFrom-Json)[0].assets | Where-Object { $_.name -eq $file })[0].id
    $versionCode = (Invoke-WebRequest $releases -Headers $headers | ConvertFrom-Json)[0].tag_name
    Write-Host "`r[✓] $($langmap.1)... $($langmap.2) ($versionCode)"

    #download
    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] $($langmap.3)..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.3)..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    $headers = @{
        'Authorization' = "token $credentials"
        'Accept' = 'application/octet-stream'
    }
    $downloadPath = $([System.IO.Path]::GetTempPath()) + "$file"
    $download = "https://" + $credentials + ":@api.github.com/repos/$repo/releases/assets/$id"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "$download" -Headers $headers -OutFile $downloadPath
    Write-Host "`r[✓] $($langmap.3)... $($langmap.2) ($versionCode)"


    #extract archive or move file
    if ($file.Contains(".zip")){
        $timesofpoint = 0
        do {
            Start-Sleep -Milliseconds 400
            Write-Host -NoNewline "`r[.] $($langmap.4)..."
            Start-Sleep -Milliseconds 400
            Write-Host -NoNewline "`r[ ] $($langmap.4)..."
            $timesofpoint = $timesofpoint + 1
        } until ($timesofpoint -eq 2)
        Expand-Archive $downloadPath -DestinationPath $endLocation -Force
        Write-Host "`r[✓] $($langmap.4)... $($langmap.2)"
    } else {
        Copy-Item -Path "$downloadPath" -Destination "$endLocation"
    }
    

    #clean up TEMP
    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] $($langmap.5)..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.6)..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    Remove-Item "$downloadPath" -Force
    Write-Host "`r[✓] $($langmap.6)... $($langmap.2)"

    #format version number
    $versionNumber = $versionCode.replace('v','')

    $versionNumber
}

$newInstallOptions_currentOptionName = @{
    '1' = 'CodeChecker'
    '2' = 'ShoppingLister'
    '3' = 'MorseCode'
    '4' = 'ServerDeploy'
    '5' = 'BackupDeploy'
}

$frlangmap = @{
    '1' = "Salut ! Cet utilitaire vous permet d'installer et de configurer tous - ou seulement certains, vous pouvez choisir - les programmes développés par Kirkwood Software"
    '2' = "Comme c'est la première fois que vous installez les produits Kirkwood Soft., nous allons suivre l'installation étape par étape."
    '3' = "Tout d'abord, sélectionnons les programmes que vous souhaitez installer :"
    '4' = "Génial ! Maintenant une dernière question : où voulez-vous installer les programmes ?"
    '5' = " - À l'échelle du système (tout utilisateur peut y accéder, installés dans le répertoire des fichiers du programme)"
    '6' = " - Limité par l'utilisateur (vous seul avez accès aux programmes, installés dans le répertoire AppData)"
    '7' = "Alors ? Où ? [S | U]"
    '8' = "L'installation va maintenant commencer..."
    '9' = "Création des répertoires principaux :"
    '10' = "Création des répertoires de logiciels :"
    '11' = "Téléchargement du logiciel :"
    '12' = "Tous les téléchargements sont terminés !"
    '13' = "Vous avez décidé d'installer ServerDeploy, qui est, comme son nom l'indique, un programme de déploiement."
    '14' = "Allons-nous le configurer maintenant (recommandé) ? [o | n] :"
    '15' = "Super, commençons !"
    '16' = "D'accord, comme vous le souhaitez. Les options d'accès à ServerDeploy seront affichées à la fin"
    '17' = "Configuration des références :"
    '18' = "Le référencement consiste à mettre en place des raccourcis à divers endroits de votre PC afin d'accéder facilement aux programmes Kirkwood Soft."
    '19' = "Voici les différentes options :"
    '20' = " 1. Dans un dossier sur le Bureau (encombre votre bureau)"
    '21' = " 2. Dans un dossier du menu Démarrer (recommandé)"
    '22' = " 3. Dans system32, vous pouvez donc lancer depuis le terminal (NE PAS SELECTIONNER, PAS ENCORE STABLE)"
    '23' = "Veuillez saisir le nombre d'options que vous souhaitez installer en les séparant par des espaces (par exemple : 2 3)"
    '24' = "Comme vous avez déjà installé certains de nos produits, que souhaitez-vous faire :"
    '25' = " 1. Mettre à jour (conserver la configuration)         3. Réinstaller la même version (nouvelle version, reconfigurer)"
    '26' = " 2. Mettre à jour (fraîchement, reconfigurer)          4. Désinstaller (supprime la configuration et les binaires)"
    '27' = "Veuillez taper UN chiffre après les 2 points "
    '28' = "Veuillez saisir les numéros des programmes que vous souhaitez installer séparés par des espaces (par exemple : 2 3 5)"
    '29' = "Aller voir le code source et nos autres produits sur GitHub"
    '30' = "Envoyer un e-mail aux développeurs"
}

$enlangmap = @{
    '1' = "Hi ! This utility allows you to install and configure all - or only some, you can choose - programs developed by Kirkwood Software"
    '2' = "As this is your first time installing Kirkwood Soft. products, we will be going through the installation step-by-step."
    '3' = "First of all, let's select the programs you want to install :"
    '4' = "Great ! Now one last question : where do you want to install the programs ?"
    '5' = "  - System-wide (any user can access, installed in the program files directory)"
    '6' = "  - User-limited (only you have access to the programs, installed in the AppData directory)"
    '7' = "So ? Where ? [S | U] "
    '8' = "The installation will now begin..."
    '9' = "Creating main directories :"
    '10' = "Creating software directories :"
    '11' = "Downloading software :"
    '12' = "All downloads finsished !"
    '13' = "You have decided to install ServerDeploy, which is, as the name suggests, a deploying program."
    '14' = "Shall we set it up now (recommended) ? [y | n] :"
    '15' = "Great, let's start !"
    '16' = "Alright, as you wish. Options for accessing ServerDeploy will be displayed at the end"
    '17' = "Setting up references :"
    '18' = "Referencing consists in setting up shortcuts in various places of you PC so you can access the Kirkwood Soft programs easily."
    '19' = "Here are the different options :"
    '20' = "    1. In a Dektop folder (clutters your Desktop)"
    '21' = "    2. In a Start Menu folder (recommended)"
    '22' = "    3. In system32, so you can launch from the terminal (DO NOT SELECT, NOT STABLE YET)"
    '23' = "Please type in the numbers of options you want to install separated by spaces (i.e. 2 3) "
    '24' = "As you already have some of our products installed, what do you wish to do :"
    '25' = "  1. Update (keep config)             3. Reinstall same version (fresh, reconfigure)"
    '26' = "  2. Update (fresh, reconfigure)      4. Uninstall (removes config and binaries)"
    '27' = "Please type ONE number after the 2 dots "
    '28' = "Please type in the numbers of programs you want to install separated by spaces (i.e. 2 3 5) "
    '29' = "Check out the code and other products on GitHub"
    '30' = "Send an email to the developers"
}


# check if script is run as admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Clear-Host
    Write-Output "You do not have sufficient privilieges to run this script. Pease run it as administrator."
    Write-Output "Vous n'avez assez de privilèges pour démarrer ce script. Merci de le lancer en administrateur"
    $time = 5
    do {
        Write-Host -NoNewline "`rExiting in $time seconds, arrêt dans $time secondes..."
        $time = $time - 1
        Start-Sleep 1
    } until ($time -eq 0)
    exit 
}

#language selection
if ((Test-Path -Path "$env:APPDATA\Kirkwood Soft.\LANGUAGE.txt" -PathType Leaf) -eq $false){
    Clear-Host
    Write-Output "This script is available in 2 languages : French and English (United Kingdom)"
    Write-Output "Ce script est disponible en 2 langues : Français et Anaglais (britannique)"
    $lang = Read-Host "Which language do you wish to use ? Quelle langue souhaitez-vous utiliser ? [FR | EN] "
} else {
    $lang = Get-Content -LiteralPath "$env:APPDATA\Kirkwood Soft\LANGUAGE.txt"

}
if ($lang -eq "FR"){
    $langmap = $frlangmap
} elseif ($lang -eq "EN"){
    $langmap = $enlangmap
}

Clear-Host
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
Write-Output $langmap['1']

if ((Test-Path -Path "$env:APPDATA\Kirkwood Soft.") -eq $false){
    $new = $true
    Write-Output $langmap['2']
    Write-Output "------------------------------------------------------------------------------------------"
    Write-Output $langmap['3']
    Write-Output "      1. CodeChecker                  4. ServerDeploy"
    Write-Output "      2. ShoppingLister               5. BackupDeploy"
    Write-Output "      3. MorseCodeTranscoder"
    Write-Output " "
    $newInstallOptions_List = Read-Host $langmap['28']
    $newInstallOptions_Array = $newInstallOptions_List.Split(" ")
    Write-Output " "
    Write-Output $langmap['4']
    Write-Output $langmap['5']
    Write-Output $langmap['6']
    $installLocation = Read-Host $langmap['7'] 
    Write-Output " "
    Write-Output $langmap['8']
    Start-Sleep 2
} else {
    $new = $false
    Write-Output $langmap['24']
    Write-Output " "
    Write-Output $langmap['25']
    Write-Output $langmap['26']
    $alreadyInstalledActionNumber = Read-Host $langmap['27']
}


if ($new -eq $true){
    Write-Output " "
    Write-Output "=========================================================================================="
    Write-Output $langmap['9']
    if ($installLocation -eq "S"){
        $binairiesDir = "$env:programfiles\Kirkwood Soft"
        $pathname = "Kirkwood Soft"
        $userDataDir = "$env:appdata\Kirkwood Soft"
    } elseif ($installLocation -eq "U"){
        $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
        $pathname = "kirkwood Soft"
        $userDataDir = "$env:appdata\Kirkwood Soft\data"
    }
    creatingLoading -createType "directory" -createpath "$binairiesDir" -createname "$pathname" -lang "$lang"
    Add-Content -Path "$binairiesDir\LANGUAGE.txt" -Value "$lang"
    Add-Content -Path "$binairiesDir\VERSION.txt" -Value "DeployScript = $versionofDeployScript"
    creatingLoading -createType "directory" -createpath "$userDataDir" -createname "$pathname" -lang "$lang"
    Write-Output " "
    Write-Output "=========================================================================================="
    Write-Output $langmap['10']
    foreach ($newInstallOptions_currentOption in $newInstallOptions_Array){
        $currentProgramName = $newInstallOptions_currentOptionName["$newInstallOptions_currentOption"]
        creatingLoading -createType "directory" -createpath "$binairiesDir\$currentProgramName" -createname "$currentProgramName" -lang "$lang"
        creatingLoading -createType "directory" -createpath "$userDataDir\$currentProgramName" -createname "$currentProgramName" -lang "$lang"
    }
    Write-Output " "
    Write-Output "=========================================================================================="
    Write-Output $langmap['11']
    foreach ($newInstallOptions_currentOption in $newInstallOptions_Array){
        $currentProgramName = $newInstallOptions_currentOptionName["$newInstallOptions_currentOption"]
        Write-Output "      - $currentProgramName"
        $versionNumber = dlGitHub -repo "$currentProgramName" -endLocation $binairiesDir\$currentProgramName -file "deploy.zip" -lang "$lang"
        Add-Content -Value "$currentProgramName = $versionNumber" -Path "$binairiesDir\$currentProgramName\VERSION.txt"
    }
    Write-Output "`n$($langmap['12'])"
    Write-Output " "
    Write-Output "=========================================================================================="
    if ("ServerDeploy" -in $newInstallOptions_Array){
        Write-Output $langmap['13']
        $runServerDeploy = (Read-Host $langmap['14'])
        if (($runServerDeploy -eq "y") -or ($runServerDeploy -eq "o")){
            Write-Output $langmap['15']
            & $binairiesDir\ServerDeploy\serverdeploy.ps1 -NewInstallation
        }else{
            Write-Output $langmap['16']
        }
        Write-Output " "
        Write-Output "=========================================================================================="
    }
    Write-Output $langmap['17']
    Write-Output $langmap['18']
    Write-Output $langmap['19']
    Write-Output $langmap['20']
    Write-Output $langmap['21']
    Write-Output $langmap['22']
    Write-Output " "
    $referencingOptions_List = Read-Host $langmap['23']
    Write-Output " "
    $referencingOptions_Array = $referencingOptions_List.Split(" ")
    foreach ($referencingOptions_currentOption in $referencingOptions_Array){
        if ($referencingOptions_currentOption -eq "1"){
            $folderPath = [Environment]::GetFolderPath("Desktop")
            if ((Test-Path "$folderPath\Kirkwood Soft") -eq $false){
                creatingLoading -createType "directory" -createpath "$folderPath\Kirkwood Soft" -createname "Kirkwood Soft" -lang "$lang"
            }
            foreach ($newInstallOptions_currentOption in $newInstallOptions_Array){
                $currentProgramName = $newInstallOptions_currentOptionName["$newInstallOptions_currentOption"]
                creatingLoading -createType "shortcut" -createpath "$folderPath\Kirkwood Soft\$currentProgramName.lnk" -shortcutDestPath "$binairiesDir\$currentProgramName\deploy.ps1" -lang "$lang"
            }
        }
        if ($referencingOptions_currentOption -eq "2"){
            if ($installLocation -eq "S"){
                $folderPath = [Environment]::GetFolderPath('CommonStartMenu')
            } elseif ($installLocation -eq "U"){
                $folderPath = [Environment]::GetFolderPath('StartMenu')
            }
            if ((Test-Path "$folderPath\Kirkwood Soft") -eq $false){
                creatingLoading -createType "directory" -createpath "$folderPath\Kirkwood Soft" -createname "Kirkwood Soft" -lang "$lang"
            }
            foreach ($newInstallOptions_currentOption in $newInstallOptions_Array){
                $currentProgramName = $newInstallOptions_currentOptionName["$newInstallOptions_currentOption"]
                creatingLoading -createType "shortcut" -createpath "$folderPath\Programs\Kirkwood Soft\$currentProgramName.lnk" -shortcutDestPath "$binairiesDir\$currentProgramName\deploy.ps1" -lang "$lang"
            }
            creatingLoading -createType "shortcut" -createpath "$folderPath\Kirkwood Soft\$($langmap['29']).url" -shortcutDestPath "https://github.com/silloky" -lang "$lang"
            creatingLoading -createType "shortcut" -createpath "$folderPath\Kirkwood Soft\$($langmap['30']).url" -shortcutDestPath "mailto:elias.kirkwood@gmail.com?subject=Kirkwood%20Soft%20products%20enquiry" -lang "$lang"
        }
        if ($referencingOptions_currentOption -eq "3"){
            $folderPath = [Environment]::GetFolderPath('System')
            #DO SOMETHING HERE FOR SYSTEM32
        }
    }
    Write-Output " "
    Write-Output "=========================================================================================="
    Write-Output "Configuring updater :"
    Write-Output " "
    Write-Output "The apps you just installed are going to change often. To benefit of these improvements, you have to update the apps."
    Write-Output "Update checking yourself is tedious, so we created a little program to automatically check for updates when you start your computer"
    Write-Output "It will let you know if a newer version is avilable"
    if ((Read-Host "Do you wish to install it (recommended) ? [y | n] ") -eq "y"){
        dlGitHub -repo "DeployScript" -endLocation $binairiesDir -file "updateChecker.ps1" -lang "$lang"
        Write-Output " "
        Write-Output "------------------------------------------------------------------------------------------"    
        Write-Output "Scheduling task :"
        $timesofpoint = 0
        do {
            Start-Sleep -Milliseconds 400
            Write-Host -NoNewline "`r[.] Configuring action..."
            Start-Sleep -Milliseconds 400
            Write-Host -NoNewline "`r[ ] Configuring action..."
            $timesofpoint = $timesofpoint + 1
        } until ($timesofpoint -eq 2)
        $scheduledAction = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument "-File "$binairiesDir\updateChecker.ps1""
        $scheduledTrigger = New-ScheduledTaskTrigger -AtStartup
        $scheduledSettings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable
        $scheduledTask = New-ScheduledTask -Action $scheduledAction -Trigger $scheduledTrigger -Settings $scheduledSettings
        Register-ScheduledTask -TaskName 'Kirkwood Soft update checker' -InputObject $scheduledTask -User "NT AUTHORITY\LOCALSERVICE" 
    }

    Write-Output " "
    Write-Output "=========================================================================================="
    Write-Output "Overview :"
    Write-Output " "
    Write-Output "You have installed $($newInstallOptions_Array.Length) Kirkwood Soft programs :"
    foreach ($newInstallOptions_currentOption in $newInstallOptions_Array){
        $currentProgramName = $newInstallOptions_currentOptionName["$newInstallOptions_currentOption"]
        Write-Output "      - $currentProgramName"
    }

    Write-Output "You can access the newly-installed programs through $($referencingOptions_Array.Length) different ways :"
    foreach ($referencingOptions_currentOption in $referencingOptions_Array){
        if ($referencingOptions_currentOption -eq "1"){
            Write-Output "      - With a Desktop folder : $([Environment]::GetFolderPath("Desktop"))\Kirkwood Soft"
        }
        if ($referencingOptions_currentOption -eq "2"){
            Write-Output "      - With a Start Menu folder : you can access them through the menu that appears when you click on 🪟 (or Windows key)"
        }
        if ($referencingOptions_currentOption -eq "3"){
            Write-Output "      - With a command in the Command Prompt : NOT STABLE"
        }
    }
}elseif ($new -eq $false){

}

Pause








