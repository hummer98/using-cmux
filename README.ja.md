日本語 | **[English](README.md)**

![using-cmux](banner.jpeg)

# using-cmux

AI が cmux を操作するための Claude Code スキルパッケージ。

## モチベーション

Claude Code の組み込み `Agent` ツールは便利だが、内部で何が起きているかが見えない。サブエージェントの出力を確認したり、途中で介入したりすることが困難で、デバッグや品質管理が難しい。

**cmux を使えば、すべてが見える。** ターミナルマルチプレクサとして動作する cmux 上でサブエージェントを起動すれば、各エージェントの入出力をリアルタイムに確認でき、いつでも介入・修正できる。

既存の [hashangit/cmux-skill](https://github.com/hashangit/cmux-skill) はブラウザ自動化の記述が全体の約50%を占めており、サブエージェント操作という本来最も重要なユースケースが埋もれていた。本パッケージはその構成を見直し、**サブエージェント操作パターンを中核に据え直した**代替スキルである。

## 概要

このスキルは以下の内容をカバーする:

| カテゴリ | 内容 |
|---------|------|
| **基本操作** | ペイン分割、ワークスペース管理、コマンド送信、画面読み取り |
| **send の改行ルール** | 最も重要なルール。単一行の `\n` と複数行の `send-key return` の使い分け |
| **サブエージェント起動パターン** | 起動 → Trust検出 → プロンプト送信 → 完了検出 → 結果回収の一連の手順 |
| **read-screen トラブルシューティング** | 出力が空・古い場合の `refresh-surfaces` 等の対処法 |
| **通知** | `cmux notify`（アプリ内）と `osascript`（macOS通知センター）の使い分け |
| **ステータス・プログレス表示** | サイドバーステータスとプログレスバーの制御 |

## cmux-team との関係

![アーキテクチャ図](architecture.jpeg)

- **using-cmux**: cmux CLI の汎用操作スキル。1体のサブエージェントの起動から結果回収までをカバー
- **cmux-team**: 複数エージェントのオーケストレーション。チーム構成・タスク分配・同期を担当。using-cmux の操作パターンを基盤として利用する

## 前提条件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) がインストール済みであること
- [cmux](https://cmux.dev) がインストール済みで、cmux セッション内で Claude Code を実行すること
- macOS / Linux 環境。Windows は未サポート（`bin/` 配下は POSIX シェルスクリプトで、`jq` および macOS/Linux 上の `cmux` CLI 挙動に依存）

## インストール

### 方法1: Plugin（推奨）

```
/plugin marketplace add hummer98/using-cmux
/plugin install using-cmux
```

スキル・コマンド・フックがまとめてインストールされる。

**アップデート:**

```
/plugin update using-cmux
/reload-plugins
```

> 注: `bin/` 配下のラッパースクリプト（`cmux-read` など）の更新を反映するには、cmux セッションの再起動が必要。Plugin の `bin/` パスがセッション開始時に PATH に焼き込まれるため。

### 方法2: Agent Skills（スキルのみ）

```bash
npx skills add hummer98/using-cmux
```

> 注: Agent Skills ではコマンド（`/cmux`）やラッパースクリプト（`cmux-read` など）は含まれない。フル機能を使う場合は方法1を推奨。

## 使い方

### スキルの自動トリガー

cmux セッション内で Claude Code を起動すると、環境変数 `CMUX_SOCKET_PATH` の存在を検出してスキルが自動的にロードされる。特別な操作は不要。

Claude Code が cmux 操作の指示を受けると、SKILL.md に記述されたパターンに従って、ペイン分割・コマンド送信・サブエージェント起動などを実行する。

### `/cmux` コマンド

クイックリファレンスを表示する:

```
/cmux
```

コマンド一覧・基本的な使い方を手早く確認したいときに使う。

## セキュリティ

`bin/` 配下のラッパースクリプト (`cmux-send` / `cmux-send-key` / `cmux-read`) は `cmux` CLI への薄いラッパー:

- `--surface` 参照を受け取り、`cmux tree --json` から対応する workspace を解決して `cmux send` / `cmux read` / `cmux send-key` に転送するだけ
- ユーザー入力の評価・補間・書き換えは一切行わず、文字列は `cmux` にそのまま渡す
- 実行権限はユーザー自身のもの。権限昇格や `cmux` 外への書き込みはしない
- スクリプト自体はネットワークアクセスを行わない

ただしこれらのラッパーは指定された cmux surface にキー入力を送る性質上、`cmux-send` を呼べるエージェントは対象 surface 内で任意コマンドを実行できる（これは cmux 本来の仕様）。本 plugin の導入は、ユーザーがターミナルペインに直接タイプするのと同等の権限をエージェントに与えることに相当する点に注意。

## ライセンス

[MIT](LICENSE)
