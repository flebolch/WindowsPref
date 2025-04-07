# 0 - Check user privileges & internet connection
# Ensure the script can run with elevated privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

# Function to test internet connectivity
function Test-InternetConnection {
    try {
        $testConnection = Test-Connection -ComputerName www.google.com -Count 1 -ErrorAction Stop
        return $true
    }
    catch {
        Write-Warning "Internet connection is required but not available. Please check your connection."
        return $false
    }
}



# 1 - Display hidden files and folders
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -ErrorAction Stop
    if ($?) {
        Write-Output "Hidden files and folders are now visible."
    } else {
        Write-Output "Failed to set hidden files and folders visibility."
    }
} catch {
    Write-Output "Error on hidden files and folders visibility : $_"
}

#  2  Display file extention
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -ErrorAction Stop
    if ($?) {
        Write-Output "File extensions are now visible."
    } else {
        Write-Output "Failed to set file extensions visibility."
    }
} catch {
    Write-Output "Error on file extention visibility : $_"
}

# 3 - back to windows context menu 
try {
    Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -ErrorAction Stop
    if ($?) {
        Write-Output "Contextual menu restored successfully."
    } else {
        Write-Output "Contextual menu restoration failed."
    }
} catch {
    Write-Output "Error on contextual menue display : $_"
}

# 4  Remove useless Windows packages
$appsToRemove = @(
    "windowsalarms"
    "Appconnector"
    "windowscalculator"
    "windowscommunicationsapps"
    "CandyCrushSaga"
    "officehub"
    "skypeapp"
    "getstarted"
    "zunemusic"
    "windowsmaps"
    "Messaging"
    "solitairecollection"
    "ConnectivityStore"
    "bingfinance"
    "zunevideo"
    "bingnews"
    "onenote"
    "people"
    "CommsPhone"
    "windowsphone"
    "WindowsScan"
    "bingsports"
    "Office.Sway"
    "Twitter"
    "soundrecorder"
    "bingweather"
    "xboxapp"
    "XboxOneSmartGlass"
    "qq"
    "Connect"
    "maps"
    "phone"
    "skype"
)

foreach ($app in $appsToRemove) {
    try {
        Get-AppxPackage -AllUsers | Where-Object { $_.Name -like "*$app*" } | Remove-AppxPackage -ErrorAction Stop
        if ($?) {
            Write-Output "$app removed successfully."
        } else {
            Write-Output "Failed to remove $app."
        }
    } catch {
        Write-Output "Error on removing $app : $_"
    }
}

# 5  Install Chocolatey 

try {
    if (-NOT (Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        $chocoInstallScript = "https://chocolatey.org/install.ps1"
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($chocoInstallScript))
        Write-Output "Chocolatey installed successfully."
    } else {
        Write-Output "Chocolatey is already installed."
    }
} catch {
    Write-Output "Error on installing Chocolatey : $_"
}


# 6 - Profile creation or update

$profilelnk = "https://raw.githubusercontent.com/flebolch/WindowsPref/refs/heads/main/Microsoft.PowerShell_profile.ps1"

if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of PowerShell & Create Profile directories if they do not exist.
        $profilePath = ""
        if ($PSVersionTable.PSEdition -eq "Core") {
            $profilePath = "$env:userprofile\Documents\Powershell"
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            $profilePath = "$env:userprofile\Documents\WindowsPowerShell"
        }

        if (!(Test-Path -Path $profilePath)) {
            New-Item -Path $profilePath -ItemType "directory"
        }

        Invoke-RestMethod $profilelnk -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
        Write-Host "If you want to make any personal changes or customizations, please do so at [$profilePath\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
        .$profile
    }
    catch {
        Write-Error "Failed to create or update the profile. Error: $_"
    }
}
else {
    try {
        Get-Item -Path $PROFILE | Move-Item -Destination "oldprofile.ps1" -Force
        Invoke-RestMethod $profilelnk -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
        Write-Host "Please back up any persistent components of your old profile to [$HOME\Documents\PowerShell\Profile.ps1] as there is an updater in the installed profile which uses the hash to update the profile and will lead to loss of changes"
    }
    catch {
        Write-Error "Failed to backup and update the profile. Error: $_"
    }
}


# - 7  Install favorites powershell modules 

$modulesToInstall = @(
    "Terminal-Icons -RequiredVersion 0.9.0"
    "PSReadLine -AllowPrerelease"
    "z -RequiredVersion 1.1.13"
)

foreach ($module in $modulesToInstall) {
    try {
        if (-NOT (Get-Module -ListAvailable -Name $module)) {
            Install-Module -Name $module
            Write-Output "$module installed successfully."
        } else {
            Write-Output "$module is already installed."
        }
    } catch {
        Write-Output "Error on installing $module : $_"
    }
}


Write-Output "Scrit done."