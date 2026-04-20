# MCP（Model Context Protocol）サーバー セットアップガイド

## MCP とは

外部ツール・データソースをClaudeから直接使えるようにする仕組み。GitHubのIssue確認、データベースクエリ、Slack投稿などをClaude Codeから実行できる。

## インストール方法

### 方法1: CLIコマンド（最も簡単）

```bash
claude mcp add <server-name>
```

例:
```bash
claude mcp add github
claude mcp add postgres
claude mcp add playwright
```

### 方法2: `.mcp.json`（チーム共有）

プロジェクトルートに`.mcp.json`を作成してgit管理する。

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "${DATABASE_URL}"]
    }
  }
}
```

### 方法3: settings.json（個人用）

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}"
      }
    }
  }
}
```

## 主要MCPサーバー一覧

| サーバー | 用途 | インストールコマンド |
|---|---|---|
| `github` | Issue・PR・コード管理 | `claude mcp add github` |
| `postgres` | PostgreSQLクエリ | `claude mcp add postgres` |
| `playwright` | ブラウザ自動化・テスト | `claude mcp add playwright` |
| `slack` | Slackメッセージ送受信 | `claude mcp add slack` |
| `notion` | Notionページ操作 | `claude mcp add notion` |
| `google-drive` | Googleドライブ操作 | `claude mcp add google-drive` |
| `memory` | 外部メモリストア | `claude mcp add memory` |
| `context7` | ライブラリドキュメント検索 | `claude mcp add context7` |
| `supabase` | Supabaseデータ操作 | `claude mcp add supabase` |

## 認証が必要なサーバー

多くのサーバーはAPIキーが必要。環境変数で渡す。

```bash
# .envファイルまたはシェルで設定
export GITHUB_TOKEN="ghp_xxx"
export SLACK_BOT_TOKEN="xoxb-xxx"
export DATABASE_URL="postgresql://user:pass@localhost/db"
```

`.mcp.json`では`${ENV_VAR}`構文で参照できる。

## トランスポートタイプ

| タイプ | 説明 | 使いどころ |
|---|---|---|
| `stdio` | サブプロセスとして起動（最一般的） | ローカルツール |
| `http` / `sse` | HTTPエンドポイントに接続 | リモートサービス |

### HTTPサーバーの設定例

```json
{
  "mcpServers": {
    "my-api": {
      "type": "http",
      "url": "https://my-mcp-server.example.com/mcp"
    }
  }
}
```

## カスタムMCPサーバーの作成

自分でMCPサーバーを作ることも可能。

```bash
# TypeScript SDKを使う場合
npm install @modelcontextprotocol/sdk
```

基本構造:
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";

const server = new Server({
  name: "my-server",
  version: "1.0.0",
}, {
  capabilities: { tools: {} }
});

// ツール定義・ハンドラを追加
```

## 確認すべき質問

1. どの外部サービスにアクセスしたいですか？（GitHub, DB, Slack等）
2. チーム全員で使いますか？（`.mcp.json`）それとも個人用ですか？（settings.json）
3. 該当サービスのAPIキーはありますか？

## 作成後のアクション

1. `claude mcp list`でインストール済みサーバーを確認
2. Claude Codeを再起動（MCPサーバーはセッション開始時に接続）
3. Claudeに「GitHubのXXリポジトリのIssue一覧を見せて」のように自然言語で指示するだけで使える
4. `claude mcp get <server-name>`でサーバーの状態確認
