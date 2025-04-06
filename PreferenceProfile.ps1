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
    "people"
    "phone"
    "skype"
)

try {
Get-AppxPackage -AllUsers     | Where-Object { $_.Name -notlike "*Microsoft*" } | Remove-AppxPackage -ErrorAction Stop
    if ($?) {
        Write-Output "Useless Windows packages removed successfully."
    } else {
        Write-Output "Failed to remove useless Windows packages."
    }
} catch {
    Write-Output "Error on removing useless Windows packages : $_"
}





Write-Output "Scrit done."