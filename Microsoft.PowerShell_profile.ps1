# Set the encoding to UTF-8 for the console output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Set the folder path
$Env:HOME = "E:\Users\Francois.LT-Taur"
$Env:DATA = "D:\"
$GitBranch = ""
# Import Terminal-Icons module
Import-Module Terminal-Icons

# Verify if PowerShell is executed as an administrator
function Test-Admin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

#Is a git repository if .git folder exists retune true or false
function IsGitRepository {
    param (
        [string]$path = $(Get-Location)
    )
    return Test-Path "$path\.git"
}

#function get git branch name if exists
function Get-GitBranchName {
    param (
        [string]$path = $(Get-Location)
    )
    if (IsGitRepository) {
        $gitBranch = & git -C $path rev-parse --abbrev-ref HEAD 2>$null
        return $gitBranch
    } else {
        return $null
    }
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


#Higlight name of current directory in the prompt
function pathPrompt {
    # Get current location
    $currentDirectory = (Get-Location).Path

    # Use regex to extract parts of the path
    $regex = "^([A-Z]):\\(.*\\)?([^\\]+)$"
    $match = [regex]::Match($currentDirectory, $regex)

    if ($match.Success) {
        $driveLetter = $match.Groups[1].Value
        $directoryPath = $match.Groups[2].Value
        $folderName = $match.Groups[3].Value

        # Print with colors
        Write-Host "| 💾 $driveLetter " -ForegroundColor DarkBlue -NoNewline
        # Write-Host "$directoryPath" -ForegroundColor DarkGreen -NoNewline
        Write-Host "→ $folderName" -ForegroundColor DarkBlue -NoNewline
    } else {
        # If regex fails (e.g., root of drive), fallback formatting
        Write-Host "$currentDirectory" -ForegroundColor Cyan
    }
}


# Get the current date and time
$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Custom prompt function
function prompt {
    

    $currentDirectory = $(Get-Location)
    $UncRoot = $currentDirectory.Drive.DisplayRoot

    write-host "📅 $dateTime " -NoNewline -ForegroundColor DarkGray
    pathPrompt -NoNewline
    if (IsGitRepository) {
        $GitBranch = Get-GitBranchName
        write-host "| 📁 git branch: *" -NoNewline -ForegroundColor White
        write-host $GitBranch -NoNewline -ForegroundColor Green
    } else {
        write-host "$UncRoot" -NoNewline -ForegroundColor Yellow
    }
    write-host " $UncRoot"
    # Convert-Path needed for pure UNC-locations
    if (Test-Admin) {
        write-host "#👾 ▶ $(Convert-Path $currentDirectory)`n" -nonewline -ForegroundColor DarkGray
    } else {
        write-host "👽 ▶ $(Convert-Path $currentDirectory)`n" -nonewline -ForegroundColor DarkGray
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
