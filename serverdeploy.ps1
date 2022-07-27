$shareoptionequivalencemap = @{
    '1' = 'partageseliasgerard'
    '2' = 'partagesmarianneautres'
    '3' = 'partageseliasjames'
    '4' = 'partagesmarianneelias'
    '5' = 'partagesgerardautres'
    '6' = 'partagesmariannegerard'
    '7' = 'partagesgerardjames'
    '8' = 'partagesalanjames'
    '9' = 'partagesjuliettemarianne'
    '10' = 'partagesjuliettemarianne'
    '11' = 'partagesjulietteautres'
    '12' = 'partagesalanautres'
    '13' = 'partagesjulietteelias'
    '14' = 'partagesalanelias'
    '15' = 'partagesjuliettegerard'
    '16' = 'partagesalangerard'
    '17' = 'partagesjuliettejames'
    '18' = 'partagesjamesautres'
    '19' = 'partageseliasautres'
    '20' = 'partagesmariannealan'
}

$sharenameequivalencemap = @{
    'partageseliasgerard' = "$shareORpartage Elias-Gérard"
    'partagesmarianneautres' = "$shareORpartage Marianne-Autres"
}



Write-Output " ____                             ____             _             "
Write-Output "/ ___|  ___ _ ____   _____ _ __  |  _ \  ___ _ __ | | ___  _   _ "
Write-Output "\___ \ / _ \ '__\ \ / / _ \ '__| | | | |/ _ \ '_ \| |/ _ \| | | |"
Write-Output " ___) |  __/ |   \ V /  __/ |    | |_| |  __/ |_) | | (_) | |_| |"
Write-Output "|____/ \___|_|    \_/ \___|_|    |____/ \___| .__/|_|\___/ \__, |"
Write-Output "                                            |_|            |___/ "
Write-Output " "
Write-Output "================================================================="
Write-Output "================================================================="



#create necesary directories
Write-Output "Setting up the directory structure :"
$timesOfFolderCreate = 0
do {
    if ($timesOfFolderCreate -eq 0){
        $folderpath = "D:\programs"
        $foldername = "programs"
    } elseif ($timesOfFolderCreate -eq 1){
        $folderpath = "D:\programs\Server"
        $foldername = "Server"
    } elseif ($timesOfFolderCreate -eq 2){
        $folderpath = "D:\programs\Server\submounts"
        $foldername = "submounts"
    }
    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] Creating directory : $folderpath..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] Creating directory : $folderpath..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    $folderexists = (Test-Path -Path $folderpath)
    if ($folderexists -eq $false) {
        $null = New-Item -Path "$folderpath" -Value "$foldername" -ItemType "directory"
        Write-Host "`r[✓] Creating directory : $folderpath... Done !"
    }
    else {
        Write-Host "`r[✗] Creating directory : $folderpath... Failed (directory already exists)"
    }
    $timesOfFolderCreate = $timesOfFolderCreate + 1
} until (
    $timesOfFolderCreate -eq 3
)

Write-Output " "
Write-Output "-----------------------------------------------------------------"
Write-Output "Installing main code :"
$timesofpoint = 0
do {
    Start-Sleep -Milliseconds 400
    Write-Host -NoNewline "`r[.] Creating file : mount.vbs..."
    Start-Sleep -Milliseconds 400
    Write-Host -NoNewline "`r[ ] Creating file : mount.vbs..."
    $timesofpoint = $timesofpoint + 1
} until ($timesofpoint -eq 2)
$fileexists = (Test-Path -Path "D:\programs\Server\mount.vbs" -PathType Leaf)
if ($fileexists -eq $false){
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value 'Set objFSO = Createobject("Scripting.FileSystemObject")'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value 'Set oFolder = objFSO.GetFolder("C:\programs\Server\submounts")'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value 'For Each oFile in oFolder.Files'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value '    Dim WinScriptHost'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value '    Set WinScriptHost = CreateObject("WScript.Shell")'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value '    WinScriptHost.Run Chr(34) & oFolder & Chr(92) & oFile.Name & Chr(34), 0'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value '    Set WinScriptHost = Nothing'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value 'Next'
    Write-Host "`r[✓] Creating file : mount.vbs... Done !"
}else{
    Write-Host "`r[✗] Creating file : mount.vbs... Failed (file already exists)"
}

Write-Output " "

Write-Output "-----------------------------------------------------------------"
Write-Output "Shared folders selection :"
Write-Output "1. Partages Elias-Gérard                     11. Partages Juliette-Autres"
Write-Output "2. Partages Marianne-Autres                  12. Partages Alan-Autres"
Write-Output "3. Partages Elias-James                      13. Partages Juliette-Elias"
Write-Output "4. Partages Marianne-Elias                   14. Partages Alan-Elias"
Write-Output "5. Partages Gérard-Autres                    15. Partages Juliette-Gérard"
Write-Output "6. Partages Marianne-Gérard                  16. Partages Alan-Gérard"
Write-Output "7. Partages Gérard-James                     17. Partages Juliette-James"
Write-Output "8. Partages Alan-James                       18. Partages James-Autres"
Write-Output "9. Partages Juliette-Marianne                19. Partages Elias-Autres"
Write-Output "10. Partages Juliette-Alan                   20. Partages Marianne-Alan"
Write-Output " "

Read-Host $shareoptions = "Please type in the numbers of the options, separarted by spaces "

$shareoptionsarray = $shareoptions.split(" ")
$outshareoptionsarray = $shareoptionsarray | ForEach-Object {
    $selectedshareoption = $_;
    Write-Output $shareoptionequivalencemap[$selectedshareoption]
}

foreach ($i in $outshareoptionsarray) {
    Add-Content -Path "D:\programs\Server\submounts\$i" -Value "rclone mount sftp-nas:/$i "D:\Partages\$shareORpartage Elias-Gérard""
}