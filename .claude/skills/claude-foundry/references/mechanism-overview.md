# Claude Code 拡張機能 一覧・選択ガイド

## 仕組み比較表

| 仕組み | 何をするか | スコープ | 複雑度 |
|---|---|---|---|
| **CLAUDE.md** | Claudeへの恒久的な指示・プロジェクト知識 | プロジェクト/ユーザー/企業 | 低 |
| **Rules** | パス条件付きの追加ルール | プロジェクト/ユーザー | 低 |
| **Skills** | カスタムスラッシュコマンド・再利用ワークフロー | プロジェクト/ユーザー | 中 |
| **Hooks** | ツールイベントへの自動反応 | プロジェクト/ユーザー | 高 |
| **Settings** | 権限・環境変数・モデル設定 | プロジェクト/ユーザー | 低 |
| **Memory** | セッション間の自動学習・記憶 | ユーザー（自動管理） | なし |
| **MCP** | 外部ツール・データソース連携 | プロジェクト/ユーザー | 中 |
| **Agents** | 特定タスク専門の自律エージェント | プロジェクト/ユーザー | 高 |
| **Plugins** | 複数仕組みのパッケージ配布 | ユーザー | 高 |

---

## 選択フローチャート

```
何をしたいですか？
│
├─ Claudeに「このプロジェクトのことを覚えていてほしい」
│   → CLAUDE.md
│
├─ 特定のファイル種別（*.tsなど）でだけルールを適用したい
│   → Rules
│
├─ よく使う手順をスラッシュコマンドにしたい
│   → Skills
│
├─ ファイル保存時・ツール実行前後に自動で何かしたい
│   → Hooks
│
├─ Claudeに使えるコマンドを絞りたい / 環境変数を渡したい
│   → Settings
│
├─ Claudeに学習したことを次のセッションでも覚えていてほしい
│   → Memory（自動）または CLAUDE.md（手動管理）
│
├─ GitHubやSlack、DBなど外部ツールをClaudeから使いたい
│   → MCP
│
├─ 特定タスクを自律的にこなす専門AIを作りたい
│   → Agents
│
└─ 複数の設定をまとめてチームに配布したい
    → Plugins
```

---

## 各仕組みの詳細

### CLAUDE.md
セッション開始時に自動ロードされる指示ファイル。ビルドコマンド、アーキテクチャの概要、コーディング規約、落とし穴など「Claudeが常に知っておくべきこと」を書く。

### Rules (`.claude/rules/`)
CLAUDE.mdのモジュール版。YAMLフロントマターで`paths`を指定すると、該当ファイルを編集するときだけロードされる。テスト規約は`*.test.ts`、API規約は`src/api/**`など。

### Skills (`.claude/skills/<name>/SKILL.md`)
`/skill-name`で呼び出せるカスタムコマンド。テンプレート生成、コードレビュー、デプロイ手順など再利用ワークフローに最適。

### Hooks (`settings.json`の`hooks`フィールド)
30種以上のイベント（`PreToolUse`、`PostToolUse`、`SessionStart`等）に反応するシェルスクリプト・プロンプト。保存時の自動フォーマット、`.env`ファイルの書き込みブロックなどに使う。**変更後はClaude Codeの再起動が必要。**

### Settings (`settings.json`)
権限（`permissions.allow/deny`）、環境変数（`env`）、モデル・effort設定。グローバル(`~/.claude/`)またはプロジェクト(`.claude/`)スコープ。

### Memory (`~/.claude/projects/<project>/memory/`)
Claudeが学習事項を自動保存。ユーザーが「覚えておいて」と言うだけでOK。手動でファイルを追加・編集することも可能。

### MCP Servers
`claude mcp add <server>`でインストール。GitHub、Slack、PostgreSQL、Notionなど多数の公式サーバーが利用可能。

### Agents (`.claude/agents/<name>.md`)
YAMLフロントマター + システムプロンプトで定義する専門エージェント。コードレビュー専用、セキュリティ監査専用など役割特化型AIを作れる。

### Plugins
Skills・Rules・Hooksをひとまとめにして配布できるパッケージ。`claude plugin install <name>`でインストール。チームへの設定配布に使う。
