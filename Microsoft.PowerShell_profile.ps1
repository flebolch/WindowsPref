# Set the encoding to UTF-8 for console output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Set optional environment shortcuts only when not already defined
if (-not $env:HOME) { $env:HOME = 'E:\Users\Francois.LT-Taur' }
if (-not $env:DATA) { $env:DATA = 'D:\' }

# Import Terminal-Icons module if available
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}

function Test-Admin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function IsGitRepository {
    param (
        [string]$Path = (Get-Location).Path
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        return $false
    }

    $gitResult = git -C $Path rev-parse --is-inside-work-tree 2>$null
    return $gitResult -eq 'true'
}

function Get-GitBranchName {
    param (
        [string]$Path = (Get-Location).Path
    )

    if (IsGitRepository -Path $Path) {
        return git -C $Path rev-parse --abbrev-ref HEAD 2>$null
    }
    return $null
}

function cd {
    param (
        [string]$Path = $null
    )

    if (-not $Path -or $Path -eq '~') {
        Set-Location -Path $env:USERPROFILE
        return
    }

    if ($Path -eq 'D') {
        Set-Location -Path 'D:\'
        return
    }

    Set-Location -Path $Path
}

$host.UI.RawUI.WindowTitle = "$env:USERNAME@$env:COMPUTERNAME"

function Get-CurrentDirectorySegment {
    param ([string]$Path)

    if (-not $Path) { return '' }
    $leaf = Split-Path -Leaf $Path
    return if ($leaf) { $leaf } else { $Path }
}

function pathPrompt {
    $currentDirectory = (Get-Location).Path
    $folderName = Get-CurrentDirectorySegment -Path $currentDirectory

    Write-Host "| 💾 $($currentDirectory.Substring(0,1)) " -ForegroundColor DarkBlue -NoNewline
    Write-Host "→ $folderName" -ForegroundColor DarkBlue -NoNewline
}

function Get-LastCommandTime {
    if ((Get-History).Count -gt 0) {
        $lastEntry = (Get-History)[-1]
        if ($lastEntry.StartExecutionTime -and $lastEntry.EndExecutionTime) {
            return [math]::Round((($lastEntry.EndExecutionTime - $lastEntry.StartExecutionTime).TotalSeconds), 2)
        }
    }
    return 0
}

function prompt {
    $currentDirectory = Get-Location
    $uncRoot = $currentDirectory.Drive.DisplayRoot
    $dateTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    Write-Host "📅 $dateTime | ⏱ $(Get-LastCommandTime)s " -NoNewline -ForegroundColor DarkGray
    pathPrompt

    if (IsGitRepository -Path $currentDirectory.Path) {
        $gitBranch = Get-GitBranchName -Path $currentDirectory.Path
        Write-Host "| 📁 git branch: *" -NoNewline -ForegroundColor White
        Write-Host $gitBranch -NoNewline -ForegroundColor Green
    } else {
        Write-Host "$uncRoot" -NoNewline -ForegroundColor Yellow
    }

    Write-Host " $uncRoot"

    if (Test-Admin) {
        Write-Host "#👾 ▶ $(Convert-Path $currentDirectory)`n" -NoNewline -ForegroundColor DarkGray
    } else {
        Write-Host "👽 ▶ $(Convert-Path $currentDirectory)`n" -NoNewline -ForegroundColor DarkGray
    }

    Write-Host "↪" -NoNewline -ForegroundColor White
    return ' '
}

function edit {
    param (
        [string]$filePath = $(Get-Location)
    )

    & 'C:\Program Files\Notepad++\notepad++.exe' $filePath
}
