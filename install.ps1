<#
  claude-code-dotfiles setup script
  After cloning this repo on a new Windows PC, run:
    cd $HOME\claude-code-dotfiles
    .\install.ps1
#>

$ErrorActionPreference = "Stop"
$RepoDir = $PSScriptRoot
$ClaudeDir = Join-Path $HOME ".claude"

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

Write-Host "=== 1. Checking required tools ===" -ForegroundColor Cyan

if (-not (Test-Command "git")) {
    Write-Host "Installing Git..."
    winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Git: OK"
}

if (-not (Test-Command "node")) {
    Write-Host "Installing Node.js..."
    winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Node.js: OK"
}

if (-not (Test-Command "gh")) {
    Write-Host "Installing GitHub CLI..."
    winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "GitHub CLI: OK"
}

# Refresh PATH for this process (winget/npm may not be visible yet)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

if (-not (Test-Command "claude")) {
    Write-Host "Installing Claude Code CLI..."
    npm install -g @anthropic-ai/claude-code
} else {
    Write-Host "Claude Code CLI: OK"
}

Write-Host ""
Write-Host "=== 2. GitHub authentication ===" -ForegroundColor Cyan
$null = & gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not logged in to GitHub. Please run:" -ForegroundColor Yellow
    Write-Host "  gh auth login" -ForegroundColor Yellow
    Write-Host "Then run this script again."
    exit 1
} else {
    Write-Host "GitHub auth: OK"
}

Write-Host ""
Write-Host "=== 3. Linking Claude Code config to this repo ===" -ForegroundColor Cyan

if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

function Link-ConfigFile($fileName) {
    $target = Join-Path $RepoDir $fileName
    $linkPath = Join-Path $ClaudeDir $fileName

    if (Test-Path $linkPath) {
        $existing = Get-Item $linkPath -Force
        if ($existing.LinkType -eq "SymbolicLink") {
            Write-Host "$fileName : already linked"
            return
        }
        $backupPath = "$linkPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Write-Host "$fileName : backing up existing file to $backupPath"
        Move-Item -Path $linkPath -Destination $backupPath
    }

    # PowerShell's New-Item -ItemType SymbolicLink requires elevation even with
    # Developer Mode on; cmd's mklink respects the unprivileged-create flag, so use that.
    $mklinkOutput = cmd /c mklink "`"$linkPath`"" "`"$target`"" 2>&1
    if (Test-Path $linkPath) {
        Write-Host "$fileName : linked" -ForegroundColor Green
    } else {
        Write-Host "$fileName : failed to create symbolic link" -ForegroundColor Red
        Write-Host $mklinkOutput
        Write-Host "Enable Windows Developer Mode (Settings > Privacy & security > For developers) and sign out/in, then re-run this script." -ForegroundColor Yellow
    }
}

Link-ConfigFile "CLAUDE.md"
Link-ConfigFile "settings.json"

Write-Host ""
Write-Host "=== Setup complete ===" -ForegroundColor Cyan
Write-Host "Run 'claude --version' / 'gh --version' to verify."
Write-Host "Run 'claude' to start Claude Code."
