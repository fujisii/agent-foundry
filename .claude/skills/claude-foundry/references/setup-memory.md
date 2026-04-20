# Memory セットアップガイド

## Memory とは

Claudeがセッション間で学習・記憶を保持するシステム。二種類ある。

| 種類 | 特徴 |
|---|---|
| **自動メモリ（Auto Memory）** | ClaudeがNoteWriteツールで自動保存。ユーザーは「覚えておいて」と言うだけ |
| **CLAUDE.md** | 人間が書く恒久的な指示。コードと一緒にgit管理できる |

## 保存場所

```
~/.claude/projects/<encoded-project-path>/memory/
├── MEMORY.md          ← インデックス（セッション開始時に最初の200行をロード）
├── debugging.md       ← トピック別の詳細ファイル
├── api-conventions.md
└── ...
```

## 自動メモリの使い方

### Claudeに覚えさせる
会話の中で「これを覚えておいて」と言うだけで自動保存される。

```
ユーザー: このプロジェクトでは npm test ではなく vitest で実行してください。覚えておいて。
Claude: 了解です。記録しました。今後は vitest を使います。
```

### メモリを確認する
- `/memory` コマンドでメモリブラウザを開ける
- または直接ファイルを読む: `~/.claude/projects/<project>/memory/MEMORY.md`

### メモリを削除する
- `/memory` から削除、または直接ファイルを編集・削除

## メモリを手動で作成する

重要なことを手動でメモリファイルに書き込むことも可能。

```markdown
<!-- ~/.claude/projects/<project>/memory/MEMORY.md -->
# プロジェクトメモリインデックス

- [ビルド設定](build-config.md) — vitest使用、ESMモジュール
- [デバッグパターン](debugging.md) — N+1問題の検出方法
```

```markdown
<!-- ~/.claude/projects/<project>/memory/build-config.md -->
---
name: ビルド設定
description: テスト実行・ビルド手順の記憶
type: project
---

## テスト
npm test ではなく vitest を使う。`npx vitest run`で実行。

## ビルド
`npm run build`は使わず`vite build`を直接実行する。
```

## CLAUDE.md と Memory の使い分け

| ケース | 推奨 |
|---|---|
| チームで共有すべき情報 | **CLAUDE.md**（git管理） |
| 個人の作業メモ・発見した知識 | **Memory**（自動管理） |
| プロジェクトの基本情報 | **CLAUDE.md** |
| デバッグ中に発見したパターン | **Memory** |
| コーディング規約 | **CLAUDE.md** or **Rules** |
| 「この関数のバグはXXが原因だった」 | **Memory** |

## 自動メモリの無効化

```json
// settings.json
{
  "autoMemoryEnabled": false
}
```

またはセッション中に `/memory` から無効化できる。

## 確認すべき質問

ほとんどの場合、メモリは自動管理なので「セットアップ」は不要。以下を確認する。

1. 今すぐ何か特定のことを記録させたいですか？
2. それはプロジェクト固有（Memory）ですか？全員と共有（CLAUDE.md）ですか？

→ チーム共有ならCLAUDE.mdのセットアップを勧める（`/claude-foundry claude-md`）

## 作成後のアクション

- 次のセッションを開始してClaudeに「前回何を覚えたか教えて」と聞くと確認できる
- メモリファイルは普通のMarkdownなので直接編集可能
