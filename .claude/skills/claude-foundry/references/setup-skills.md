# Skills セットアップガイド

## Skills とは

`/skill-name`で呼び出せるカスタムスラッシュコマンド。再利用可能なワークフロー・手順を定義して、いつでも同じ操作を実行できるようにする。スクリプトとClaude AIの両方の長所を組み合わせられる。

## ファイル配置

```
~/.claude/skills/<name>/SKILL.md    ← グローバル（全プロジェクトで使える）
.claude/skills/<name>/SKILL.md      ← プロジェクト固有
```

各スキルは独自ディレクトリを持ち、SKILL.mdが必須エントリーポイント。

## SKILL.md フロントマター全フィールド

```yaml
---
name: my-skill                    # スキル名（/my-skill で呼び出す）
description: >                    # Claudeが自動発火するかの判断基準になる説明
  何をするスキルか。どんな状況で使うべきか。
  ユーザーが「XXしたい」と言ったら発火させる。
argument-hint: [arg1] [arg2]      # 引数のヒント（省略可）
allowed-tools: Read, Bash, Write  # 事前承認するツール（省略可）
model: claude-sonnet-4-6         # モデル上書き（省略可）
effort: high                      # 思考量: low/medium/high/xhigh/max（省略可）
context: fork                     # 独立サブエージェントとして実行（省略可）
disable-model-invocation: true    # ユーザーのみ呼び出し可（省略可）
user-invocable: false             # Claudeのみ自動発火（省略可）
shell: bash                       # シェル指定: bash/powershell（省略可）
paths:                            # パス限定で自動発火（省略可）
  - "src/**/*.ts"
---
```

## 呼び出し制御の選択ガイド

| ユースケース | 設定 |
|---|---|
| ユーザーとClaude両方が呼べる（デフォルト） | 何も指定しない |
| ユーザーだけが呼べる（副作用のある操作） | `disable-model-invocation: true` |
| Claudeが自動発火するだけ（内部フック的な使い方） | `user-invocable: false` |
| 重い並行タスクを独立して実行 | `context: fork` |

## 文字列置換

| 変数 | 内容 |
|---|---|
| `$ARGUMENTS` | 渡されたすべての引数 |
| `$ARGUMENTS[0]`または`$1` | 1番目の引数 |
| `${CLAUDE_SKILL_DIR}` | このSKILL.mdがあるディレクトリ |
| `${CLAUDE_SESSION_ID}` | 現在のセッションID |

## シェルコマンドの動的実行

スキル実行前にシェルコマンドを実行してコンテキストを注入できる。

```markdown
# スキル本文

現在のgitステータス:
!`git status`

最新のエラーログ:
!`tail -n 50 logs/error.log`
```

複数行コマンド:
````markdown
```!
git log --oneline -10
git diff HEAD~1
```
````

## よくあるユースケース別テンプレート

### コードレビュースキル
```markdown
---
name: review
description: コードレビューを行う。PRの差分を確認してフィードバックを提供する。
allowed-tools: Read, Bash, Grep
---

# コードレビュー

以下の観点でコードをレビューしてください:

1. バグ・セキュリティの問題
2. パフォーマンスの問題
3. 可読性・保守性
4. テストの網羅性

現在の変更:
!`git diff HEAD`
```

### テンプレート生成スキル
```markdown
---
name: new-component
description: Reactコンポーネントのテンプレートを生成する。「コンポーネントを作りたい」「新しいUIを追加したい」時に使う。
argument-hint: [component-name]
allowed-tools: Read, Write, Bash
---

# 新規コンポーネント生成

`$ARGUMENTS` という名前のReactコンポーネントを作成してください。

プロジェクトの規約:
!`cat ${CLAUDE_SKILL_DIR}/../../.claude/rules/frontend-conventions.md 2>/dev/null || echo "規約ファイルなし"`
```

### デプロイスキル（ユーザーのみ呼び出し可）
```markdown
---
name: deploy
description: 本番環境へのデプロイを実行する。
disable-model-invocation: true
allowed-tools: Bash
---

# デプロイ

対象環境: $ARGUMENTS（省略時: staging）

以下の手順でデプロイを実行してください:
1. テストを実行して全て通過することを確認
2. ビルド
3. デプロイ
4. ヘルスチェック
```

## 確認すべき質問

1. どんな操作を`/skill-name`で呼び出したいですか？
2. ユーザーだけが呼べるようにしますか？それともClaudeが自動判断して発火してもいいですか？
3. 引数は必要ですか？（例: コンポーネント名、対象ファイル等）
4. どのツールが必要ですか？（ファイル読み書き・シェル実行・Web検索等）

## ベストプラクティス

- **SKILL.mdは500行以内**に収める（長い場合は`references/`ディレクトリに分割）
- descriptionは1,536文字上限。Claudeの自動発火に使われるので具体的に書く
- よく使うスキルは`~/.claude/skills/`（グローバル）に置く

## 作成後のアクション

- `/help`でスキル一覧に表示されることを確認
- `/skill-name`で実際に呼び出してテスト
- 引数ありなら`/skill-name arg1`でテスト
