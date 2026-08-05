<#
  claude-code-dotfiles セットアップスクリプト
  新しいWindows PCでこのリポジトリをcloneした後、このスクリプトを実行してください。
    cd $HOME\claude-code-dotfiles
    .\install.ps1
#>

$ErrorActionPreference = "Stop"
$RepoDir = $PSScriptRoot
$ClaudeDir = Join-Path $HOME ".claude"

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

Write-Host "=== 1. 必要なツールを確認・導入します ===" -ForegroundColor Cyan

if (-not (Test-Command "git")) {
    Write-Host "Git を導入します..."
    winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Git: OK"
}

if (-not (Test-Command "node")) {
    Write-Host "Node.js を導入します..."
    winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Node.js: OK"
}

if (-not (Test-Command "gh")) {
    Write-Host "GitHub CLI を導入します..."
    winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "GitHub CLI: OK"
}

# winget直後はPATHが未反映のことがあるため、このプロセスのPATHを更新
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

if (-not (Test-Command "claude")) {
    Write-Host "Claude Code CLI を導入します..."
    npm install -g @anthropic-ai/claude-code
} else {
    Write-Host "Claude Code CLI: OK"
}

Write-Host ""
Write-Host "=== 2. GitHub認証 ===" -ForegroundColor Cyan
$ghStatus = & gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHubにログインしていません。次のコマンドを実行してログインしてください:" -ForegroundColor Yellow
    Write-Host "  gh auth login" -ForegroundColor Yellow
    Write-Host "ログイン後、このスクリプトをもう一度実行してください。"
    exit 1
} else {
    Write-Host "GitHub認証: OK"
}

Write-Host ""
Write-Host "=== 3. Claude Code設定をこのリポジトリにリンクします ===" -ForegroundColor Cyan

if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

function Link-ConfigFile($fileName) {
    $target = Join-Path $RepoDir $fileName
    $linkPath = Join-Path $ClaudeDir $fileName

    if (Test-Path $linkPath) {
        $existing = Get-Item $linkPath -Force
        if ($existing.LinkType -eq "SymbolicLink") {
            Write-Host "$fileName : 既にリンク済みです"
            return
        }
        $backupPath = "$linkPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Write-Host "$fileName の既存ファイルを $backupPath にバックアップします"
        Move-Item -Path $linkPath -Destination $backupPath
    }

    try {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $target | Out-Null
        Write-Host "$fileName : リンク完了" -ForegroundColor Green
    } catch {
        Write-Host "$fileName のシンボリックリンク作成に失敗しました。" -ForegroundColor Red
        Write-Host "Windowsの「開発者モード」を有効にしてから再実行してください:" -ForegroundColor Yellow
        Write-Host "  設定 > プライバシーとセキュリティ > 開発者向け > 開発者モード を ON"
    }
}

Link-ConfigFile "CLAUDE.md"
Link-ConfigFile "settings.json"

Write-Host ""
Write-Host "=== セットアップ完了 ===" -ForegroundColor Cyan
Write-Host "claude --version / gh --version で導入を確認できます。"
Write-Host "claude と入力してClaude Codeを起動してみてください。"
