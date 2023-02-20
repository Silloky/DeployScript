$versionofDeployScript = "1.0.1"

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
        Write-Host -NoNewline "`r[.] $($langmap.1) $($langmap["$createType"]) : $createpath ..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.1) $($langmap["$createType"]) : $createpath..."
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
        [Parameter(Mandatory = $true, Position = 0)] [string] $lang,
        [Parameter(Mandatory = $true, Position = 0)] [string] $token,
        [Parameter(Mandatory = $true, Position = 0)] [string] $key
    )
    #language setup
    $enlangmap = @{
        1 = "Determining latest release"
        2 = "Done !"
        3 = "Downloading latest release"
        4 = "Extracting archive (zip)"
        5 = "Cleaning up"
        6 = "of"
    }

    $frlangmap = @{
        1 = "Détermination de la dernière version"
        2 = "Terminé !"
        3 = "Téléchargement de la dernière version"
        4 = "Extraction de l'archive (zip)"
        5 = "Nettoyage"
        6 = "de"
    }
    
    if ($lang -eq "FR"){
        $langmap = $frlangmap
    } elseif ($lang -eq "EN"){
        $langmap = $enlangmap
    }

    #variable setup
    $enc = [system.Text.Encoding]::UTF8
    [byte[]]$byteKey = $enc.GetBytes($key)
    $credentials = Decrypt -EncryptedString "$token" -EncryptionKey $byteKey
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
        Write-Host -NoNewline "`r[.] $($langmap.3) ($versionCode) $($langmap.6) $file..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.3) ($versionCode) $($langmap.6) $file..."
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
    Write-Host "`r[✓] $($langmap.3) ($versionCode) of $file... $($langmap.2) "


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
        Write-Host -NoNewline "`r[ ] $($langmap.5)..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    Remove-Item "$downloadPath" -Force
    Write-Host "`r[✓] $($langmap.5)... $($langmap.2)"

    #format version number
    $versionNumber = $versionCode.replace('v','')
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
    '7' = "Alors ? Où ? [système | utilisateur]"
    '8' = "L'installation va maintenant commencer..."
    '9' = "Création des répertoires principaux :"
    '10' = "Création des répertoires de logiciels :"
    '11' = "Téléchargement du logiciel :"
    '12' = "Tous les téléchargements sont terminés !"
    '13' = "Vous avez décidé d'installer ServerDeploy, qui est, comme son nom l'indique, un programme de déploiement."
    '14' = "Allons-nous le configurer maintenant (recommandé) ? [o | n] "
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
    '25' = " 1. Mettre à jour (conserver la configuration)         2. Désinstaller (supprime les binairies et en option la configuration)"
    '27' = "Veuillez taper UN chiffre après les 2 points "
    '28' = "Veuillez saisir les numéros des programmes que vous souhaitez installer séparés par des espaces (par exemple : 2 3 5)"
    '29' = "Aller voir le code source et nos autres produits sur GitHub"
    '30' = "Envoyer un e-mail aux développeurs"
    '31' = "Configuration du programme de mise-à-jour"
    '32' = "Les applications que vous venez d'installer vont changer souvent. Bour bénéficier de ces changements, vous devez les mettre-à-jour."
    '33' = "Vérifier vous-même si une nouvelle version est disponible peut être ennuyant, c'est la raison pour laquelle nous avons un petit programme qui fait cela une fois par semaine."
    '34' = "Il vous dira si une mise-à-jour est disponible."
    '35' = "Voulez-vous l'installer (recommandé) ? [o | n]"
    '36' = "Veuillez saisir la clé de sécurité qui vous a été donnée lors de la formation  "
    '37' = "Planification de la tâche"
    '38' = "Configuration de la tâche planifiée"
    '39' = "(action)"
    '40' = "Terminé !"
    '41' = "(conditions de démarrage)"
    '42' = "(paramètres)"
    '43' = "Création de la tâche planifiée"
    '44' = "Résumé :"
    '45' = "Vous avez installé"
    '46' = "applications de Kirkwood Soft"
    '47' = "Vous pouvez accéder à vos programmes de"
    '48' = "différentes façons"
    '49' = "Avec un dossier sur le Bureau"
    '50' = "Avec un dossier du menu Démarrer : vous pouvez y accéder en cliquant sur 🪟 (ou la touche Windows de votre clavier)"
    '51' = "Désinstaller signifie supprimer un ou des application(s) Kirkwood Soft de votre appareil."
    '52' = "Êtes-vous sûr de vouloir désinsatller ? [o | n] "
    '53' = "Fermeture dans"
    '54' = "secondes"
    '55' = "Voulez-vous désinstaller tous les programmes de Kirkwood ou seulement certains ? [tous | certains]"
    '56' = "Êtes-vous sûr de vouloir désinsatller ? [o | n] "
    '57' = "Suppression du/des logiciel(s)"
    '58' = "AppData est l'endroit où votre configuration (mots de passe, sélection des dossiers partagés...) est stockée. Merci de garder en tête que vous devrez tout reconfigurer si vous décidez un jour de réinstaller."
    '59' = "Donc, voulez-vous supprimer AppData ? [o | n] "
    '60' = "Suppression d'AppData"
    '61' = "Il est recommandé de redémarrer votre ordinateur après la manipulation de nos programmes."
    '62' = "Merci d'enregistrer votre travail avant de continuer."
    '63' = "Installtion du gestionnaire de notification"
    '64' = "[✓] BurnToast a bien été installé !"
}

$enlangmap = @{
    '1' = "Hi ! This utility allows you to install and configure all - or only some, you can choose - programs developed by Kirkwood Software"
    '2' = "As this is your first time installing Kirkwood Soft. products, we will be going through the installation step-by-step."
    '3' = "First of all, let's select the programs you want to install :"
    '4' = "Great ! Now one last question : where do you want to install the programs ?"
    '5' = "  - System-wide (any user can access, installed in the program files directory)"
    '6' = "  - User-limited (only you have access to the programs, installed in the AppData directory)"
    '7' = "So ? Where ? [system | user] "
    '8' = "The installation will now begin..."
    '9' = "Creating main directories :"
    '10' = "Creating software directories :"
    '11' = "Downloading software :"
    '12' = "All downloads finsished !"
    '13' = "You have decided to install ServerDeploy, which is, as the name suggests, a deploying program."
    '14' = "Shall we set it up now (recommended) ? [y | n] "
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
    '25' = "  1. Check for updates              2. Uninstall (removes binaries optionally config)"
    '27' = "Please type ONE number after the 2 dots "
    '28' = "Please type in the numbers of programs you want to install separated by spaces (i.e. 2 3 5) "
    '29' = "Check out the code and other products on GitHub"
    '30' = "Send an email to the developers"
    '31' = "Configuring updater :"
    '32' = "The apps you just installed are going to change often. To benefit of these improvements, you have to update the apps."
    '33' = "Update checking yourself is tedious, so we created a little program to automatically check for updates when you start your computer"
    '34' = "It will let you know if a newer version is avilable"
    '35' = "Do you wish to install it (recommended) ? [y | n] "
    '36' = "Please type in the security key given to you during the training "
    '37' = "Scheduling task :"
    '38' = "Configuring scheduled task"
    '39' = "action"
    '40' = "Done !"
    '41' = "trigger"
    '42' = "settings"
    '43' = "Creating scheduled task"
    '44' = "Summary :"
    '45' = "You have installed"
    '46' = "Kirkwood Soft programs"
    '47' = "You can access the newly-installed programs through"
    '48' = "different ways"
    '49' = "With a Desktop folder"
    '50' = "With a Start Menu folder : you can access them through the menu that appears when you click on 🪟 (or Windows key)"
    '51' = "Uninstalling means deleting some or all programs developed by Kirkwood Soft."
    '52' = "Are you sure you want to uninstall ? [y | n]"
    '53' = "Exiting in"
    '54' = "seconds"
    '55' = "Do you wish to completely uninstall all Kirkwood Soft programs or only a set of them ? [all | set]"
    '56' = "Are you sure you want to uninstall ? [y | n]"
    '57' = "Removing software"
    '58' = "AppData is where your config (passwords, shared folders selection...) is stored. Please keep in mind you will need to reconfigure entirely if you ever reinstall our software."
    '59' = "So, do you want to delete AppData ? [y | n] "
    '60' = "Removing AppData"
    '61' = "It is recommended to restart after manipulating our software."
    '62' = "Please make sure you have saved your work before restarting..."
    '63' = "Installtion of the notification manager"
    '64' = "[✓] BurnToast successfully installed !"
}


# check if script is run as admin
# if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
# [Security.Principal.WindowsBuiltInRole] "Administrator")) {
#     Clear-Host
#     Write-Output "You do not have sufficient privilieges to run this script. Pease run it as administrator."
#     Write-Output "Vous n'avez assez de privilèges pour démarrer ce script. Merci de le lancer en administrateur"
#     $time = 5
#     do {
#         Write-Host -NoNewline "`rExiting in $time seconds, arrêt dans $time secondes..."
#         $time = $time - 1
#         Start-Sleep 1
#     } until ($time -eq 0)
#     exit 
# }

#language selection
if ((Test-Path -Path "$env:APPDATA\Kirkwood Soft\LANGUAGE.txt" -PathType Leaf) -eq $false){
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
    $alreadyInstalledActionNumber = Read-Host $langmap['27']
}


if ($new -eq $true){
    if (!(Get-Module -ListAvailable -Name BurntToast)){
        Write-Output " "
        Write-Output "------------------------------------------------------------------------------------------"
        Write-Output $langmap['63']
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
        Install-Module -Name BurntToast -RequiredVersion 0.8.5
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
        Write-Output $langmap['64']
    }
    Write-Output " "
    Write-Output "=========================================================================================="
    Write-Output $langmap['9']
    if (($installLocation -eq "system") -or ($installLocation -eq "système") -or ($installLocation -eq "systeme")){
        $binairiesDir = "$env:programfiles\Kirkwood Soft"
        $pathname = "Kirkwood Soft"
        $userDataDir = "$env:appdata\Kirkwood Soft"
    } elseif (($installLocation -eq "user") -or ($installLocation -eq "utilisateur")){
        $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
        $pathname = "Kirkwood Soft"
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
        $key = Read-Host $langmap['36'] 
        $token = "76492d1116743f0423413b16050a5345MgB8AFMAaABOAE4AeQBOAHAAOQBEAHEANABFAGUANwBjAHoAeQBGAC8AVgBuAFEAPQA9AHwAOQBiAGQAZgBmAGUANwBmADgAYQBlAGYANwA2AGUAMwBiAGQAYQBiAGIANwAzAGYAZABhADQANABlADMAOQA2ADkAYQA0ADUAMABlADIAMABhADkAOQBiADMAOAAwAGIAMABmAGEAMwA2ADcANwAwADUANwBjAGYAMwAzADYANQBmADIAYQAxADMANQBkAGYAZgA1ADcAOQAwADcAYgBjADUAMgBjAGMAYwBhAGMAMQAwADAAMQBhADcAMgBlAGMAZgAxADQANQA2AGEANQBjADkAOABiAGUANQBmAGUAOABjADgANgA3AGIANwA4ADkAZgBhADcANgA5ADAAMwAxAGMAMgBlADAAZQBkADEAMAAwAGQAZgBhADgAOQA2AGQAOQAyAGMANAA3ADAAZgAxAGYAOQA2AGYAMwBmADUAYwA0ADcAYgAzAGUAMQA1AGYAMwAxADcAZAA1ADUAYgA3AGQAYwBjAGQANgAzAGEAMAA2ADQAMABmAGEAZgA4AGEA"
        $versionNumber = dlGitHub -repo "$currentProgramName" -endLocation $binairiesDir\$currentProgramName -file "main.ps1" -lang "$lang" -token "$token" -key $key
        Add-Content -Value "$currentProgramName = $versionNumber" -Path "$binairiesDir\$currentProgramName\VERSION.txt"
    }
    Write-Output "`n$($langmap['12'])"
    Write-Output " "
    Write-Output "=========================================================================================="
    if ("4" -in $newInstallOptions_Array){
        Write-Output $langmap['13']
        $runServerDeploy = (Read-Host $langmap['14'])
        if (($runServerDeploy -eq "y") -or ($runServerDeploy -eq "o")){
            Write-Output $langmap['15']
            & $binairiesDir\ServerDeploy\main.ps1 -NewInstallation
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
    Write-Output $langmap['31']
    Write-Output " "
    Write-Output $langmap['32']
    Write-Output $langmap['33']
    Write-Output $langmap['34']
    $installUpdater = Read-Host $langmap['35']
    if (($installUpdater -eq "y") -or ($installUpdater -eq "o")){
        $token = "76492d1116743f0423413b16050a5345MgB8AFgAUQBqAE8AcgA0AEgAaQBpAEgAQQBjAHYAagBTAHIARgBNADAALwA2AFEAPQA9AHwAZQBjADUAYQA2AGIAYwA2AGUANwBjADEANQA5ADAAOAA1ADgAOABlADEAMAAxADUAOQA2AGEAZQA1AGQANQAwADcANABmAGYAZgA3ADQAZAA4AGIAMQAyADgAYwBlADYAZgA1ADMAYwBhADMAMgAyADAANgA2ADIANAA4AGQAMwA0ADcAZgAyAGQAYwBlADgAYQA3ADIAZQA0AGEAOQAxADYAMAA1ADQAMgA2AGMAZQBhAGYANwA5ADIANgBhADQAOQA0ADMAMgBhAGQANQA1AGUAMgBjADgAYQA1ADUANABmADkAYgA4ADIAMAAxAGYANABhADIAZgAyAGEAOQA4ADcAMwAzADUAZAA1ADkAYwAyADQAOABlADUAOABlAGIANwAwADAAZABlADcAYgBkADMAYwA4ADMAZgBjAGUAMgBjADQAMABkADIAYwA3ADUAMwBhADgAOQAyADIAMgAwAGQAYwA1AGEAMgAyADkAZQAzADAAOQBlADYAMABkADEA"
        $key = Read-Host $langmap['36']
        dlGitHub -repo "DeployScript" -endLocation $binairiesDir -file "updateChecker.ps1" -lang "$lang" -token "$token" -key $key
        Write-Output " "
        Write-Output "------------------------------------------------------------------------------------------"    
        Write-Output $langmap['37']
        $timesofpoint = 0
        do {
            Start-Sleep -Milliseconds 300
            Write-Host -NoNewline "`r[.] $($langmap.'38') $($langmap.'39')..."
            Start-Sleep -Milliseconds 300
            Write-Host -NoNewline "`r[ ] $($langmap.'38') $($langmap.'39')..."
            $timesofpoint = $timesofpoint + 1
        } until ($timesofpoint -eq 2)
        $scheduledAction = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument "-File `"$binairiesDir\updateChecker.ps1`""
        Write-Host "`r[✓] $($langmap.'38') $($langmap.'39')... $($langmap.'40')"
        $timesofpoint = 0
        do {
            Start-Sleep -Milliseconds 300
            Write-Host -NoNewline "`r[.] $($langmap.'38') $($langmap.'41')..."
            Start-Sleep -Milliseconds 300
            Write-Host -NoNewline "`r[ ] $($langmap.'38') $($langmap.'41')..."
            $timesofpoint = $timesofpoint + 1
        } until ($timesofpoint -eq 2)
        $scheduledTrigger = New-ScheduledTaskTrigger -Weekly -At 01:00:00
        Write-Host "`r[✓] $($langmap.'38') $($langmap.'41')... $($langmap.'40')"
        $timesofpoint = 0
        do {
            Start-Sleep -Milliseconds 300
            Write-Host -NoNewline "`r[.] $($langmap.'38') $($langmap.'42')..."
            Start-Sleep -Milliseconds 300
            Write-Host -NoNewline "`r[ ] $($langmap.'38') $($langmap.'42')..."
            $timesofpoint = $timesofpoint + 1
        } until ($timesofpoint -eq 2)
        $scheduledSettings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable
        Write-Host "`r[✓] $($langmap.'38') $($langmap.'42')... $($langmap.'40')"
        $timesofpoint = 0
        do {
            Start-Sleep -Milliseconds 300
            Write-Host -NoNewline "`r[.] $($langmap.'43')..."
            Start-Sleep -Milliseconds 300
            Write-Host -NoNewline "`r[ ] $($langmap.'42')..."
            $timesofpoint = $timesofpoint + 1
        } until ($timesofpoint -eq 2)
        $scheduledTask = New-ScheduledTask -Action $scheduledAction -Trigger $scheduledTrigger -Settings $scheduledSettings
        Register-ScheduledTask -TaskName 'Kirkwood Soft update checker' -InputObject $scheduledTask -User "NT AUTHORITY\LOCALSERVICE" -Force
        Write-Host "`r[✓] $($langmap.'42')... $($langmap.'40')"
    }

    Write-Output " "
    Write-Output "=========================================================================================="
    Write-Output $langmap['44']
    Write-Output " "
    Write-Output "$($langmap.'45') $($newInstallOptions_Array.Length) $($langmap.'46') :"
    foreach ($newInstallOptions_currentOption in $newInstallOptions_Array){
        $currentProgramName = $newInstallOptions_currentOptionName["$newInstallOptions_currentOption"]
        Write-Output "      - $currentProgramName"
    }

    Write-Output "$($langmap.'47') $($referencingOptions_Array.Length) $($langmap.'48') :"
    foreach ($referencingOptions_currentOption in $referencingOptions_Array){
        if ($referencingOptions_currentOption -eq "1"){
            Write-Output "      - $($langmap.'49') : $([Environment]::GetFolderPath("Desktop"))\Kirkwood Soft"
        }
        if ($referencingOptions_currentOption -eq "2"){
            Write-Output "      - $($langmap.'50')"
        }
        if ($referencingOptions_currentOption -eq "3"){
            Write-Output "      - With a command in the Command Prompt : NOT STABLE"
        }
    }
} elseif ($new -eq $false){
    if ($alreadyInstalledActionNumber -eq "2"){
        Write-Output $langmap['51']
        $uninstallConfirmation = 
        if ((Read-Host $langmap['52']) -eq "n"){
            $time = 5
            do {
                Write-Host -NoNewline "`r$($langmap.'53') $time $($langmap.'54')..."
                $time = $time - 1
                Start-Sleep 1
            } until ($time -eq 0)
            exit 
        }
        if ($installLocation -eq "S"){
            $binairiesDir = "$env:programfiles\Kirkwood Soft"
            $pathname = "Kirkwood Soft"
            $userDataDir = "$env:appdata\Kirkwood Soft"
        } elseif ($installLocation -eq "U"){
            $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
            $pathname = "Kirkwood Soft"
            $userDataDir = "$env:appdata\Kirkwood Soft\data"
        }
        if (Test-Path -Path "$env:programfiles\Kirkwood Soft"){
            $binairiesDir = "$env:programfiles\Kirkwood Soft"
        }
        if (Test-Path -Path "$env:appdata\Kirkwood Soft\binairies"){
            $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
        }
        if (Test-Path -Path "$env:appdata\Kirkwood Soft"){
            $userDataDir = "$env:appdata\Kirkwood Soft"
        }
        if (Test-Path -Path "$env:appdata\Kirkwood Soft\data"){
            $userDataDir = "$env:appdata\Kirkwood Soft\data"
        }
        $uninstallOption = Read-Host $langmap['55']
        if (($uninstallOption -eq "all") -or ($uninstallOption -eq "tous")){
            if ((Read-Host $langmap['56']) -eq "n"){
                $time = 5
                do {
                    Write-Host -NoNewline "`r$($langmap.'53') $time $($langmap.'54')..."
                    $time = $time - 1
                    Start-Sleep 1
                } until ($time -eq 0)
                exit 
            }
            $timesofpoint = 0
            do {
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[.] $($langmap.'57')..."
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[ ] $($langmap.'57')..."
                $timesofpoint = $timesofpoint + 1
            } until ($timesofpoint -eq 3)
            Remove-Item -Recurse -Force $binairiesDir
            Write-Host "`r[✓] $($langmap.'57')... $($langmap.'40')"
            Write-Output $langmap['58']
            $removeAppData = Read-Host $langmap['59']
            if (($removeAppData -eq "y") -or ($removeAppData -eq "o")){
                $timesofpoint = 0
                do {
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[.] $($langmap.'60')..."
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[ ] $($langmap.'60')..."
                    $timesofpoint = $timesofpoint + 1
                } until ($timesofpoint -eq 3)
                Remove-Item -Recurse -Force "$env:appdata\Kirkwood Soft"
                Remove-Item -Path "$env:appdata\rclone" -Recurse -Confirm:$false -ErrorAction SilentlyContinue
                Write-Host "`r[✓] $($langmap.'60')... $($langmap.'40')"
            }
            New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
            Remove-Item -Path "HKCR:\Directory\shell\Kirkwood Soft" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.addToCache" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.RemoveFromCache" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
            Unregister-ScheduledTask -TaskName "Kirkwood Soft update checker" -Confirm:$false -ErrorAction SilentlyContinue
            Unregister-ScheduledTask -TaskName "SFTPmount" -Confirm:$false -ErrorAction SilentlyContinue
        }
        if (($uninstallOption -eq "set") -or ($uninstallOption -eq "certains")){
            Write-Output "Here are the different products that you have installed :"
            $times = 1
            $installedLocations = @()
            foreach ($folder in $(Get-ChildItem -Path "$binairiesDir" -Directory)){
                Write-Output "    $times. $folder"
                $times = $times + 1
                $installedLocations += "$($folder.FullName)"
            }
            $toUninstallList = Read-Host "Please type in the numbers of the products you want to delete separated by spaces (i.e. 1 3) "
            $toUninstallArray = $toUninstallList.Split(" ")
            foreach ($programToUninstall in $toUninstallArray){
                $programToUninstallLocation = $installedLocations[$($programToUninstall - 1)]
                $programToUninstallName = $programToUninstallLocation.Split("\")[-1]
                $uninstallConfirmation = Read-Host "Are you sure you want to uninstall ? [y | n]"
                if (($uninstallConfirmation -eq "y") -or ($uninstallConfirmation -eq "o")){
                    $timesofpoint = 0
                    do {
                        Start-Sleep -Milliseconds 400
                        Write-Host -NoNewline "`r[.] Removing $programToUninstallName..."
                        Start-Sleep -Milliseconds 400
                        Write-Host -NoNewline "`r[ ] Removing $programToUninstallName..."
                        $timesofpoint = $timesofpoint + 1
                    } until ($timesofpoint -eq 3)
                    Remove-Item -Recurse -Force $programToUninstallLocation
                    Write-Host "`r[✓] Removing $programToUninstallName... Done !"
                }
                Write-Output "AppData is where your config (passwords, shared folders selection...) is stored. If Kirkwood Soft support tells you to do a clean install, you must delete the AppData. Otherwise there is no other reason to delete it. If you really want to, keep in mind you will need to reconfigure entirely if you ever reinstall our software."
                $removeAppData = Read-Host "So, do you want to delete the AppData of the programs you selected above ? [y | n] "
                if (($removeAppData -eq "y") -or ($removeAppData -eq "o")){
                    $timesofpoint = 0
                    do {
                        Start-Sleep -Milliseconds 400
                        Write-Host -NoNewline "`r[.] Removing AppData..."
                        Start-Sleep -Milliseconds 400
                        Write-Host -NoNewline "`r[ ] Removing AppData..."
                        $timesofpoint = $timesofpoint + 1
                    } until ($timesofpoint -eq 3)
                    foreach ($programToUninstall in $toUninstallArray){
                        $programToUninstallLocation = $installedLocations[$programToUninstall]
                        Remove-Item -Recurse -Force $programToUninstallLocation
                    }
                    Write-Host "`r[✓] Removing AppData... Done !"
                }
            }
        }
    }
    if ($alreadyInstalledActionNumber -eq "1"){
        if (Test-Path -Path "$env:programfiles\Kirkwood Soft"){
            $binairiesDir = "$env:programfiles\Kirkwood Soft"
        } elseif (Test-Path -Path "$env:appdata\Kirkwood Soft\binairies") {
            $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
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
        
        $key = Read-Host "Please type in the security key given to you during the training "
        $token = "76492d1116743f0423413b16050a5345MgB8AFgAUQBqAE8AcgA0AEgAaQBpAEgAQQBjAHYAagBTAHIARgBNADAALwA2AFEAPQA9AHwAZQBjADUAYQA2AGIAYwA2AGUANwBjADEANQA5ADAAOAA1ADgAOABlADEAMAAxADUAOQA2AGEAZQA1AGQANQAwADcANABmAGYAZgA3ADQAZAA4AGIAMQAyADgAYwBlADYAZgA1ADMAYwBhADMAMgAyADAANgA2ADIANAA4AGQAMwA0ADcAZgAyAGQAYwBlADgAYQA3ADIAZQA0AGEAOQAxADYAMAA1ADQAMgA2AGMAZQBhAGYANwA5ADIANgBhADQAOQA0ADMAMgBhAGQANQA1AGUAMgBjADgAYQA1ADUANABmADkAYgA4ADIAMAAxAGYANABhADIAZgAyAGEAOQA4ADcAMwAzADUAZAA1ADkAYwAyADQAOABlADUAOABlAGIANwAwADAAZABlADcAYgBkADMAYwA4ADMAZgBjAGUAMgBjADQAMABkADIAYwA3ADUAMwBhADgAOQAyADIAMgAwAGQAYwA1AGEAMgAyADkAZQAzADAAOQBlADYAMABkADEA"
        $enc = [system.Text.Encoding]::UTF8
        $byteKey = $enc.GetBytes($key)
        $credentials = Decrypt -EncryptedString "$token" -EncryptionKey $byteKey
        $headers = @{
            'Authorization' = "token $credentials"
            'Accept' = 'application/vnd.github+json'
        }
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
        if ( $null -ne $toBeUpdated ){
            Write-Output "$($toBeUpdated.Length) $($langmap['2']) :"
            foreach ($key in $toBeUpdated.Keys){
                Write-Output "      - $key : $($langmap['3']) v$($toBeUpdated["$key"])"
            }
            Write-Output "BlaBla"
            Write-Output "BlaBla"
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        } else {
            Write-Output "No updates available : you already have the latest versions !"
            Write-Output "You can now close this window..."
        }
    }
    
}
Write-Output " "
Write-Output " "
Write-Output "================================================================================="
Write-Output " "
Write-Output $langmap['61']
Write-Output $langmap['62']
Write-Output " "
Pause
cmd.exe /c "shutdown /r /f"