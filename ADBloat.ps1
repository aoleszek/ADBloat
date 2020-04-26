Write-Host "  ___  ______ ______  _                _   "
Write-Host " / _ \ |  _  \| ___ \| |              | |  "
Write-Host "/ /_\ \| | | || |_/ /| |  ___    __ _ | |_ "
Write-Host "|  _  || | | || ___ \| | / _ \  / _` || __|"
Write-Host "| | | || |/ / | |_/ /| || (_) || (_| || |_ "
Write-Host "\_| |_/|___/  \____/ |_| \___/  \__,_| \__|`n"

$AdbExecutable = "adb.exe"

while (-not (Test-Path -Path $AdbExecutable -PathType Leaf)) {
    Write-Host "Unable to find adb.exe in the current working directory." -foreground Red
    Write-Host "Please, move this script to the same directory as ADB and restart." -foreground Yellow
    Write-Host "You can also just enter the path of ADB below, including the filename (eg. C:\platform-tools\adb.exe)." -foreground Yellow
    $AdbExecutable = Read-Host "ADB path"
}

Write-Host "Starting ADB server... " -NoNewLine
$OutStart = [string](& $AdbExecutable start-server 2>&1)

# ADB daemon returned an error
if ($OutStart -and $OutStart -notlike "*success*") {
    Write-Host "ERROR" -foreground Red
    Write-Host "Unable to start ADB server, please try restarting the script." -foreground Yellow
    exit
}

Write-Host "OK" -foreground Green
Write-Host "Checking device status... " -NoNewLine

$OutDevices = (& $AdbExecutable devices 2>&1)

if ($OutDevices.count -eq 2) {
    Write-Host "ERROR" -foreground Red
    Write-Host "Please connect the device and enable 'USB Debugging' in system settings." -foreground Yellow
    exit
}

if ($OutDevices.count -ne 3) {
    Write-Host "ERROR" -foreground Red
    Write-Host "Too many devices connected." -foreground Yellow
    exit
}

Write-Host "OK" -foreground Green

if ($OutDevices -like "*unauthorized*") {
    while ($OutDevices -like "*unauthorized*") {
        Write-Host "Please authorize this computer on your phone." -foreground Yellow
        $Confirmation = Read-Host "Type [r] to retry or anything else to exit"

        if ($Confirmation.ToLower() -ne "r") { exit }
    
        $OutDevices = (& $AdbExecutable devices 2>&1)
    }
}

function Option-ListPackages {
    $OutPackages = (& $AdbExecutable shell pm list packages -f 2>&1)
    $Packages    = @{}

    $OutPackages | ForEach-Object -Process {
        $Data = $_.Split(":")[1]

        $Splitted = $Data.Split("/")
        $ApkName  = $Splitted[$Splitted.count - 1].Split("=")[0]

        $Splitted       = $Data.Split("=")
        $PackageName    = $Splitted[$Splitted.count - 1]

        $Packages.Add($PackageName, $ApkName)
    }

    Write-Host "Listing packages..."
    Write-Host "Package name => APK name" 

    $Packages.Keys | ForEach-Object -Process {
        $PackageName = $_
        $ApkName     = $Packages.Item($_)

        Write-Host $PackageName -foreground Blue -NoNewLine
        Write-Host " => $ApkName"
    }
}

function Option-UninstallPackage {
    Write-Host "You are about to uninstall an package.`nPlease keep in mind that uninstalling system-related packages may soft-brick your phone.`nEnter package name (marked as blue in the list) to uninstall below." -foreground Yellow
    $PackageName = Read-Host "Package"
    
    $OutUninstall = [string](& $AdbExecutable shell pm uninstall -k --user 0 $PackageName 2>&1)

    if ($OutUninstall.ToLower() -like "*success*") {
        Write-Host "This package got successfully uninstalled." -foreground Green
        Add-Content "ADBloat.log" "$(Get-Date): Uninstalled $PackageName"
    }
    else { Write-Host "An error occured while removing this package.`nIt may be already uninstalled or this package cannot be removed." -foreground Red }
}

function Option-InstallPackage {
    $PackageName = Read-Host "Package to install"
    
    $OutInstall = [string](& $AdbExecutable shell cmd package install-existing $PackageName 2>&1)

    if ($OutInstall.ToLower() -notlike "*NameNotFoundException*") {
        Write-Host "This package got successfully installed." -foreground Green
        Add-Content "ADBloat.log" "$(Get-Date): Re-installed $PackageName"
    }
    else { Write-Host "An error occured while installing this package." -foreground Red }
}

function Option-Exit {
    Write-Host "Exiting, stopping ADB server.`nPlease disable the USB Debugging option on your phone."
    (& $AdbExecutable kill-server 2>&1) | Out-Null
    exit
}

function Display-Menu {

    $MenuOptions = @(
        ("List installed packages", "Option-ListPackages"),
        ("Uninstall package", "Option-UninstallPackage"),
        ("Install package (revert)", "Option-InstallPackage"),
        ("Exit", "Option-Exit")
    )

    $MenuDecorator  = ("-" * 43)
    $Option         = $null;
    $OptionIndex    = 0

    Write-Host $MenuDecorator
    Write-Host "Available options:"

    $MenuOptions | ForEach-Object -Process {
        ++$OptionIndex;
        Write-Host ("[$OptionIndex] " + $_[0])
    }

    Write-Host $MenuDecorator

    while (-not ($Option) -or $Option -lt 1 -or $Option -gt $MenuOptions.count) {
        $Option = [int](Read-Host "Select an option")
    }

    Write-Host $MenuDecorator

    # Call selected option function
    (& $MenuOptions[$Option - 1][1])
}

while ($true) { Display-Menu }
