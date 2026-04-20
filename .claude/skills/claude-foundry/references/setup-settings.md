# Settings.json セットアップガイド

## Settings.json とは

Claude Codeの動作を制御する設定ファイル。権限管理・環境変数・モデル設定・フック等を定義する。

## 設定ファイルの場所とスコープ

| ファイル | スコープ | git管理 |
|---|---|---|
| `~/.claude/settings.json` | グローバル（全プロジェクト） | 不要 |
| `.claude/settings.json` | プロジェクト（チーム共有） | 推奨 |
| `.claude/settings.local.json` | プロジェクト（個人用） | `.gitignore`推奨 |

**優先順位**: managed（企業管理） > local > project > user（グローバル）

## 主要設定フィールド

### 権限管理（permissions）

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(npx prettier *)",
      "Read(src/**)",
      "WebFetch(domain:docs.anthropic.com)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)"
    ]
  }
}
```

**パターン構文**:
- `Bash(git *)` → `git`で始まるBashコマンドを許可
- `Read(src/*)` → `src/`以下の読み取りを許可
- `WebFetch(domain:example.com)` → 特定ドメインへのフェッチを許可

### 環境変数（env）

```json
{
  "env": {
    "NODE_ENV": "development",
    "API_BASE_URL": "https://api.example.com",
    "DEBUG": "true"
  }
}
```

### モデル設定

```json
{
  "model": "claude-opus-4-7",
  "alwaysThinkingEnabled": true
}
```

### effortレベル

```json
{
  "effort": "high"
}
```

| レベル | 用途 |
|---|---|
| `low` | 単純な質問・素早い回答 |
| `medium` | 通常の開発作業 |
| `high` | 複雑な問題・バグ分析 |
| `xhigh` | 難しいアーキテクチャ設計 |
| `max` | 最大の思考力が必要な時 |

### APIキー補助コマンド

```json
{
  "apiKeyHelper": "cat ~/.secrets/anthropic-key"
}
```

## よく使う設定テンプレート

### 開発チーム向け（`.claude/settings.json`）
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm *)",
      "Bash(npx *)",
      "Bash(node *)"
    ],
    "deny": [
      "Bash(git push --force *)",
      "Bash(rm -rf *)"
    ]
  },
  "env": {
    "NODE_ENV": "development"
  }
}
```

### 個人グローバル設定（`~/.claude/settings.json`）
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6",
  "alwaysThinkingEnabled": true,
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(gh *)"
    ]
  }
}
```

## ツール名一覧（permissionsで使う）

```
Bash          - シェルコマンド実行
Read          - ファイル読み取り
Write         - ファイル書き込み
Edit          - ファイル編集
Glob          - ファイル検索
Grep          - テキスト検索
WebFetch      - URLフェッチ
WebSearch     - Web検索
```

## 確認すべき質問

1. 何を設定したいですか？（権限・環境変数・モデル・フック等）
2. プロジェクト全体（チーム共有）ですか？個人用（全プロジェクト共通）ですか？
3. 特定のコマンドだけを許可したいですか？それとも特定のコマンドをブロックしたいですか？

## 作成後のアクション

- 設定は次のセッションから有効（再起動不要の場合もあるが再起動が確実）
- `/update-config`スキルを使うとGUIで設定できる
- JSONスキーマに対応しているエディタでは補完が効く（`$schema`フィールドで有効化）
