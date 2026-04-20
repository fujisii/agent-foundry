---
name: claude-foundry
description: Claude Codeの各種仕組み（CLAUDE.md、Rules、Skills、Hooks、Settings、Memory、MCP、Agents、Plugins）のセットアップを対話形式でガイドする。「Claude Codeをカスタマイズしたい」「スラッシュコマンドを作りたい」「フックで自動化したい」「外部ツールを連携したい」「ルールを追加したい」「設定を変えたい」「覚えさせたい」などの要望に応答する。ユーザーが「どれを使えばいいか分からない」場合は仕組み一覧を案内する。
argument-hint: [mechanism-name]
allowed-tools: Read, Glob, Grep, Bash, Write, Edit
---

# Claude Foundry スキル

Claude Codeの拡張機能セットアップを対話形式でガイドする。ユーザーが使いたい仕組みを特定し、ベストプラクティスに沿ったファイルを実際に生成する。

## 引数処理

### 引数あり（例: `/claude-foundry hooks`）

1. 引数を以下のエイリアス表で正規化する
2. 対応する `${CLAUDE_SKILL_DIR}/references/setup-<mechanism>.md` を Read する
3. セットアップ4ステップパターンを開始する（仕組み選択メニューは不要）

### 引数なし（`/claude-foundry`）

1. `${CLAUDE_SKILL_DIR}/references/mechanism-overview.md` を Read する
2. 比較表と選択フローをユーザーに提示する
3. 「どの仕組みをセットアップしますか？名前（例: 'hooks'）または目的（例: '保存時に自動フォーマットしたい'）で教えてください」と聞く
4. 回答を正規化して対応する references ファイルへルーティングする

## エイリアス正規化表

| ユーザー入力例 | 正規化後 | referencesファイル |
|---|---|---|
| claude.md, claudemd, instructions, project-memory | claude-md | setup-claude-md.md |
| rules, rule, path-rules, glob-rules | rules | setup-rules.md |
| skills, skill, slash-command, command, スラッシュコマンド | skills | setup-skills.md |
| hooks, hook, automation, event, 自動化, フック | hooks | setup-hooks.md |
| settings, settings.json, config, permissions, 設定, 権限 | settings | setup-settings.md |
| memory, auto-memory, session-memory, メモリ, 記憶 | memory | setup-memory.md |
| mcp, mcp-server, server, integration, 外部連携 | mcp | setup-mcp.md |
| agents, agent, subagent, エージェント | agents | setup-agents.md |
| plugins, plugin, プラグイン | plugins | setup-plugins.md |

## セットアップ4ステップパターン

すべての仕組みで以下の流れに従う。

### Step 1: 説明（3〜5文）

その仕組みが何をするか、どんな場合に選ぶべきかを簡潔に説明する。説明が長くなりすぎないようにする。

### Step 2: 確認（1〜3問）

ファイルを生成する前に、ユーザーのユースケースを把握するための質問をする。ただし、コードベースから読み取れる情報（プロジェクト言語、既存設定等）は先に Glob/Grep/Bash で調査してから質問する（聞かなくて済む情報は聞かない）。

### Step 3: 生成

生成するファイルの内容をユーザーに見せてから書き込む。「以下の内容で作成します。よろしいですか？」と確認を取る。承認後に Write または Edit で作成する。

### Step 4: 検証

作成したファイルを Read して確認する。「作成が完了しました。次のアクション（起動方法・テスト方法）」を伝える。

## スコープ判断

ファイル書き込み前にスコープが曖昧な場合は確認する。

| 仕組み | デフォルト推奨スコープ |
|---|---|
| CLAUDE.md | プロジェクトルート（git管理、チーム共有） |
| Rules | `.claude/rules/`（プロジェクト）または `~/.claude/rules/`（個人） |
| Skills | 汎用ツール → `~/.claude/skills/`（グローバル）、プロジェクト固有 → `.claude/skills/` |
| Hooks | チーム全体の自動化 → `.claude/settings.json`、個人用 → `~/.claude/settings.json` |
| Settings | 権限はプロジェクト、モデル設定はグローバル |
| Memory | 自動管理（設定不要、`~/.claude/projects/<project>/memory/`） |
| MCP | チーム共有 → `.mcp.json`、個人用 → `~/.claude/settings.json` |
| Agents | `.claude/agents/`（プロジェクト固有が多い） |
| Plugins | グローバル（`claude plugin install`） |

## 共通ルール

- 1回の返答で質問は1〜3問まで。まとめて聞かない
- ファイル書き込み前に必ず内容をユーザーに確認する
- 最後に「作成したもの・起動/テスト方法・次のステップ」を伝える
- 日本語でコミュニケーションする
