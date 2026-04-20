# Agents セットアップガイド

## Agents とは

特定タスクに特化した専門エージェント。通常のClaude Codeと別のシステムプロンプトで動作し、より専門的・自律的に動く。コードレビュー専用、セキュリティ監査専用、ドキュメント生成専用など役割特化型AIを作れる。

## ファイル配置

```
.claude/agents/<name>.md       ← プロジェクト固有
~/.claude/agents/<name>.md     ← グローバル（全プロジェクト）
```

## ファイルフォーマット

```markdown
---
name: code-reviewer
description: >
  PRのコードをレビューする専門エージェント。
  <use_cases>
  <use_case>コードレビューを依頼された時</use_case>
  <use_case>「レビューして」と言われた時</use_case>
  <use_case>PRの品質確認をしたい時</use_case>
  </use_cases>
model: claude-sonnet-4-6
color: blue
tools: Read, Glob, Grep, Bash
---

# コードレビュー専門エージェント

あなたはシニアソフトウェアエンジニアとして、提出されたコードを以下の観点でレビューします。

## レビュー観点

1. **正確性**: バグ、エッジケース、エラーハンドリング
2. **セキュリティ**: OWASP Top 10、インジェクション、認証の問題
3. **パフォーマンス**: N+1クエリ、不要なループ、メモリリーク
4. **可読性**: 命名規則、複雑度、コメントの適切さ
5. **テスト**: カバレッジ、エッジケースのテスト

## 出力形式

レビュー結果は以下の形式でまとめてください:
- 🔴 **必須修正**: セキュリティやバグに関わる問題
- 🟡 **推奨修正**: 品質向上のための提案
- 🟢 **良い点**: 特に良かったコード
```

## 必須フロントマターフィールド

| フィールド | 説明 |
|---|---|
| `name` | エージェント名（ファイル名と一致させる） |
| `description` | 自動発火のトリガーになる説明。`<use_cases>`タグで具体例を書く |
| `model` | 使用モデル（claude-sonnet-4-6 推奨） |
| `color` | UIで表示される色（blue/green/red/purple/orange/yellow） |

## オプションフィールド

| フィールド | 説明 |
|---|---|
| `tools` | 使用可能なツールを制限（最小権限の原則） |
| `effort` | 思考量レベル（low/medium/high/xhigh/max） |

## descriptionの書き方

descriptionがエージェントの自動発火条件になる。`<use_cases>`タグを使って具体的なシナリオを書く。

```yaml
description: >
  セキュリティ監査を行う専門エージェント。
  <use_cases>
  <use_case>「セキュリティをチェックして」と言われた時</use_case>
  <use_case>新しいAPIエンドポイントを追加した時</use_case>
  <use_case>認証・認可のコードを変更した時</use_case>
  </use_cases>
```

## よくあるユースケース別テンプレート

### ドキュメント生成エージェント

```markdown
---
name: doc-writer
description: >
  コードからドキュメントを生成する専門エージェント。
  <use_cases>
  <use_case>「ドキュメントを書いて」と言われた時</use_case>
  <use_case>READMEの更新を求められた時</use_case>
  </use_cases>
model: claude-sonnet-4-6
color: green
tools: Read, Glob, Write, Bash
---

# ドキュメント生成エージェント

コードを分析して、開発者向けのドキュメントを生成します。

## 生成するドキュメントの種類
- README.md（プロジェクト概要、セットアップ手順、使い方）
- APIリファレンス（エンドポイント、パラメータ、レスポンス例）
- アーキテクチャドキュメント（構成図の説明）
```

### テスト生成エージェント

```markdown
---
name: test-writer
description: >
  テストコードを自動生成する専門エージェント。
  <use_cases>
  <use_case>「テストを書いて」と言われた時</use_case>
  <use_case>新しい関数・クラスを実装した後</use_case>
  <use_case>カバレッジを上げたい時</use_case>
  </use_cases>
model: claude-sonnet-4-6
color: purple
tools: Read, Glob, Grep, Write, Bash
---

# テスト生成エージェント

実装コードを分析して、包括的なテストを生成します。

## テスト方針
- ハッピーパスと異常系の両方をテストする
- エッジケース（null、空配列、境界値）を考慮する
- モックは最小限にして統合テストを優先する
```

## 確認すべき質問

1. どんな専門タスクを自律的にこなすエージェントを作りたいですか？
2. このエージェントをどんな状況でClaudeに自動発火させたいですか？（descriptionの設計に使う）
3. このプロジェクト専用ですか？全プロジェクトで使いますか？
4. どのツールが必要ですか？（最小権限にすることを推奨）

## 作成後のアクション

1. `claude agents list`でエージェント一覧を確認
2. 「〇〇して」と関連タスクをClaudeに頼む → 自動的にエージェントが発火する
3. または `/agent:<name>` で明示的に呼び出すこともできる
