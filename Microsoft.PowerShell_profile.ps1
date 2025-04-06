# Set the encoding to UTF-8 for the console output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Set the folder path
$Env:HOME = "E:\Users\Francois.LT-Taur"
$Env:DATA = "D:\"

# Import Terminal-Icons module
Import-Module Terminal-Icons

# Verify if PowerShell is executed as an administrator
function Test-Admin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function cd {
    if ($args[0] -eq "~") {
        Set-Location -Path "E:\Users\Francois.LT-Taur"
    } else {
        Set-Location $args
    }
}

function cd {
    if ($args[0] -eq "D") {
        Set-Location -Path "D:\"
    } else {
        Set-Location $args
    }
}

# Default location
# Set-Location -Path "D:\"

$host.ui.rawui.WindowTitle = "${Env:username}@${Env:computername}"

# Custom prompt function
function prompt {
    $dateTime = get-date -Format "dd.MM.yy HH:mm:ss"
    $currentDirectory = $(Get-Location)
    $UncRoot = $currentDirectory.Drive.DisplayRoot

    write-host "📅 $dateTime" -NoNewline -ForegroundColor blue
    write-host " $UncRoot"
    # Convert-Path needed for pure UNC-locations
    if (Test-Admin) {
        write-host "#👾 ▶ $(Convert-Path $currentDirectory)`n" -nonewline -ForegroundColor White
    } else {
        write-host "👽 ▶ $(Convert-Path $currentDirectory)`n" -nonewline -ForegroundColor White
    }
    Write-Host "↪" -nonewline -ForegroundColor white
    return " "
}

# Function to edit file with Notepad++
function edit {
    param (
        [string]$filePath = $(Get-Location)
    )
    & "C:\Program Files\Notepad++\notepad++.exe" $filePath
}
