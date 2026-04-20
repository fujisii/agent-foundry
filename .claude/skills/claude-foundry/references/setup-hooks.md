# Hooks セットアップガイド

## Hooks とは

ツール実行やセッションのライフサイクルイベントに自動反応するシェルスクリプト・プロンプト・エージェント。ユーザーが何も言わなくても自動で実行される。

**重要: 設定変更後はClaude Codeを再起動する必要がある。**

## フックの種類

| 種類 | 動作 |
|---|---|
| `command` | シェルスクリプトを実行。決定論的な処理に向く |
| `prompt` | Claudeに判断を委ねる。「この操作は安全か？」等 |
| `http` | 外部HTTPエンドポイントにJSONを送信 |
| `agent` | サブエージェントを起動（複雑な条件チェック等） |

## 主要イベント一覧

| イベント | タイミング |
|---|---|
| `PreToolUse` | ツール実行の直前 |
| `PostToolUse` | ツール実行の直後 |
| `UserPromptSubmit` | ユーザーのメッセージ送信時 |
| `Stop` | Claudeの応答が完了した時 |
| `SessionStart` | セッション開始時 |
| `SessionEnd` | セッション終了時 |
| `Notification` | Claudeから通知が来た時 |
| `SubagentStop` | サブエージェントが完了した時 |
| `PreCompact` | コンテキスト圧縮の直前 |

## 設定場所

```json
// ~/.claude/settings.json（グローバル）
// .claude/settings.json（プロジェクト・チーム共有）
// .claude/settings.local.json（プロジェクト・個人用）
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run format -- $CLAUDE_TOOL_INPUT_FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

## マッチャー（matcher）

どのツールに反応するかを指定する。

```
"matcher": "Bash"        → Bashツールのみ
"matcher": "Write|Edit"  → WriteまたはEdit
"matcher": "*"           → すべてのツール
"matcher": ""            → （空文字）すべてのツール
```

## commandフックのJSON入力

commandフックはstdinでJSON入力を受け取る。

```bash
#!/bin/bash
# stdin からJSONを読み取る
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')
```

## commandフックの終了コード

| 終了コード | 意味 |
|---|---|
| `0` | 成功（処理続行） |
| `2` | ブロックエラー（ツール実行を中止） |
| その他 | 非ブロックエラー（警告として続行） |

## よくあるレシピ

### ファイル保存時に自動フォーマット
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "cd $CLAUDE_PROJECT_DIR && npx prettier --write \"$CLAUDE_TOOL_INPUT_FILE_PATH\" 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

### `.env`ファイルの書き込みをブロック
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "FILE=$(echo \"$CLAUDE_TOOL_INPUT\" | jq -r '.file_path // \"\"'); if echo \"$FILE\" | grep -q '\\.env'; then echo '⛔ .envファイルへの書き込みはブロックされました' >&2; exit 2; fi"
          }
        ]
      }
    ]
  }
}
```

### セッション開始時にコンテキストをロード
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"プロジェクト: $(basename $CLAUDE_PROJECT_DIR)\\n最終コミット: $(git log -1 --oneline 2>/dev/null || echo 'なし')\""
          }
        ]
      }
    ]
  }
}
```

### Claudeの応答後に完了チェック（promptフック）
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Claudeが今行った変更は完全ですか？TODO、未完成のコード、エラーハンドリングの欠落がないか確認してください。問題があれば日本語で指摘してください。"
          }
        ]
      }
    ]
  }
}
```

## フック種別の選択ガイド

```
処理は決定論的（フォーマット、ファイルチェック等）?
├─ YES → command フック
└─ NO（判断が必要）
    ├─ 簡単なYes/No判断 → prompt フック
    └─ 複雑な分析が必要 → agent フック
```

## 環境変数（commandフックで使える）

| 変数 | 内容 |
|---|---|
| `$CLAUDE_PROJECT_DIR` | プロジェクトディレクトリ |
| `$CLAUDE_SESSION_ID` | セッションID |
| `$CLAUDE_TOOL_INPUT` | ツールへの入力（JSON文字列） |
| `$CLAUDE_TOOL_INPUT_FILE_PATH` | ファイルパス（ファイル系ツール） |

## 確認すべき質問

1. どのタイミングで実行したいですか？（ファイル保存後・コマンド実行前・セッション開始時等）
2. 何をしたいですか？（フォーマット・バリデーション・ブロック・通知等）
3. 決定論的な処理ですか？それとも判断が必要ですか？（commandかpromptかの選択）
4. プロジェクト全体（`.claude/settings.json`）ですか？個人設定（`~/.claude/settings.json`）ですか？

## 作成後のアクション

1. Claude Codeを**再起動**する（フック設定は起動時にロードされる）
2. 対象の操作を実行してフックが動くか確認する
3. commandフックのデバッグは`echo "debug" >> /tmp/hook-debug.log`を使う
