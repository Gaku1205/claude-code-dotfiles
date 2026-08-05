# claude-code-dotfiles

家PC・外PCなど複数のWindows PCで、Claude Codeの設定(`CLAUDE.md` / `settings.json`)と
開発環境セットアップを共通化するためのリポジトリです。

## 中身
- `CLAUDE.md` — Claude Codeのグローバル指示ファイル。`~/.claude/CLAUDE.md` からシンボリックリンクされます。
- `settings.json` — Claude Codeのグローバル設定。`~/.claude/settings.json` からシンボリックリンクされます。
- `install.ps1` — 新しいPCで1回実行すると、必要なツールの導入とリンク設定までを行うセットアップスクリプト。

**注意:** `~/.claude.json` (MCPサーバー設定や認証トークンを含む) はこのリポジトリには含めません。PCごとに個別に管理してください。

## 使い方

### 初めてのPCでセットアップする場合
```powershell
gh auth login
git clone https://github.com/<your-username>/claude-code-dotfiles.git $HOME\claude-code-dotfiles
cd $HOME\claude-code-dotfiles
.\install.ps1
```

### 設定を変更したとき
1. `~/.claude/CLAUDE.md` や `~/.claude/settings.json` を直接編集する(シンボリックリンク経由でこのリポジトリのファイルが更新されます)
2. このフォルダで変更をコミット & push
   ```powershell
   cd $HOME\claude-code-dotfiles
   git add -A
   git commit -m "update settings"
   git push
   ```
3. もう一方のPCで `git pull` すれば反映されます(シンボリックリンクなので再起動不要、次にClaude Codeを開いたときから反映)
