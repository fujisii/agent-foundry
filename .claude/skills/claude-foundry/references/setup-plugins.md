# Plugins セットアップガイド

## Plugins とは

Skills・Rules・Hooks・Agentsをひとまとめにしてパッケージ化・配布できる仕組み。チームや組織内で設定セットを共有する際に使う。

## 既存プラグインのインストール

```bash
# プラグインをインストール
claude plugin install <plugin-name>

# インストール済みプラグイン一覧
claude plugin list

# プラグインを削除
claude plugin remove <plugin-name>
```

## プラグインの構造

```
my-plugin/
├── plugin.json          ← プラグイン定義（必須）
├── PLUGIN.md            ← プラグインの説明（推奨）
├── skills/
│   └── my-skill/
│       └── SKILL.md
├── agents/
│   └── my-agent.md
├── rules/
│   └── my-rules.md
└── hooks/
    └── hooks.json       ← フック定義（settings.jsonと別フォーマット）
```

## plugin.json の構造

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "プラグインの説明",
  "author": "作成者名",
  "skills": ["skills/my-skill"],
  "agents": ["agents/my-agent.md"],
  "rules": ["rules/my-rules.md"],
  "hooks": "hooks/hooks.json"
}
```

## hooks/hooks.json（プラグイン用フック定義）

プラグイン内のフックはsettings.jsonとは別フォーマット。

```json
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "npm run format -- $CLAUDE_TOOL_INPUT_FILE_PATH 2>/dev/null || true"
        }
      ]
    }
  ]
}
```

## カスタムプラグインの作成手順

1. ディレクトリを作成する
   ```bash
   mkdir -p my-plugin/skills/code-helper
   mkdir -p my-plugin/agents
   mkdir -p my-plugin/rules
   mkdir -p my-plugin/hooks
   ```

2. `plugin.json`を作成する

3. 各コンポーネントファイルを作成する（Skills/Agents/Rulesの各ガイド参照）

4. ローカルインストールする
   ```bash
   claude plugin install ./my-plugin
   ```

5. npmやGitHubで公開する（任意）

## いつプラグインを作るべきか

| ケース | 推奨 |
|---|---|
| 1つのスキルだけ追加 | Skills単体（プラグイン不要） |
| ルールだけ追加 | Rules単体 |
| スキル+ルール+フックをセットで配布 | **Plugin** |
| チーム全員に同じ設定を配布 | **Plugin** |
| 組織の標準ツールセットを作る | **Plugin** |

## 確認すべき質問

1. 既存のプラグインをインストールしたいですか？それとも自作したいですか？
2. 自作の場合: どのコンポーネントをまとめますか？（スキル・エージェント・ルール・フック）
3. このプラグインを誰と共有しますか？（npm公開 / ローカルディレクトリ / GitHub）

## 作成後のアクション

- ローカルプラグイン: `claude plugin install ./my-plugin` でインストール
- `claude plugin list` で確認
- 含まれるスキルは `/help` に表示される
- 含まれるエージェントは `claude agents list` で確認
