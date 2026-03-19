---
name: using-cmux
description: "cmux ターミナル内での操作スキル。ペイン分割、サブエージェント起動・監視・結果回収、コマンド送信、画面読み取り、通知に使用。CMUX_* 環境変数が存在する場合にトリガーされる。"
---

# Using cmux

cmux はターミナルマルチプレクサ。ペイン分割、コマンド送信、画面読み取りを CLI 経由で操作する。
`CMUX_SOCKET_PATH` 環境変数が存在すれば cmux 内で動作している。

## Quick Orientation

```bash
cmux identify                    # 自分のワークスペース・サーフェスを確認
cmux list-workspaces             # 全ワークスペース一覧
cmux tree                        # トポロジー表示（階層構造）
```

リソースは短縮 refs で参照する: `window:1`, `workspace:2`, `pane:3`, `surface:4`。
`--id-format uuids` で UUID 形式の出力も可能。

> **注意**: `send` で複数行を送る場合は `send-key return` が必須。詳細は「send の改行ルール」を参照。

## 基本操作

| 操作 | コマンド |
|------|---------|
| ペイン分割 | `cmux new-split right` (left/up/down も可) |
| 新ワークスペース | `cmux new-workspace --cwd $(pwd)` |
| コマンド送信 | `cmux send --surface surface:N "command\n"` |
| キー送信 | `cmux send-key --surface surface:N return` |
| 画面読み取り | `cmux read-screen --surface surface:N [--scrollback]` |
| サーフェス/WS 終了 | `cmux close-surface` / `cmux close-workspace` |
| 一覧表示 | `cmux list-panes` / `cmux list-pane-surfaces` |

## send の改行ルール

**これは最も重要なルールである。**

### 単一行コマンド: `\n` で OK

```bash
cmux send --surface surface:1 "echo hello\n"
```

末尾の `\n` が Enter キーとして機能する。

### 複数行テキスト: `send-key return` が必須

`\n` は改行として送信されない。各行を個別に送り、行間で `send-key return` を使う。

```bash
# ✅ 正しい方法
cmux send --surface surface:1 "line 1"
cmux send-key --surface surface:1 return
cmux send --surface surface:1 "line 2"
cmux send-key --surface surface:1 return

# ❌ 間違い — \n は途中改行にならない
cmux send --surface surface:1 "line 1\nline 2\n"
```

**ルール**: 末尾の `\n` 1個だけは Enter として機能する。文字列の途中に `\n` を入れても改行にはならない。

## サブエージェント操作パターン

サブエージェントを起動し、タスクを委任し、結果を回収する一連の手順。

**重要**: サブエージェントはメインエージェントとは別のワークスペースに配置する。同一ワークスペースだとペインの相互干渉が起きる。

### Step 1: ペイン作成

```bash
cmux new-workspace --cwd $(pwd)   # 別ワークスペースに作成（推奨）
# → workspace:N, pane:M, surface:S が返る。surface refs を記録する
```

### Step 2: Claude Code 起動

```bash
cmux send --surface surface:S "claude --dangerously-skip-permissions\n"
```

> `--dangerously-skip-permissions` は信頼できるタスクにのみ使うこと。

### Step 3: Trust 検出 → 承認

起動直後に Trust 確認プロンプトが表示される場合がある。`read-screen` でポーリングし、"trust" や "Yes, I trust" を検出したら承認:

```bash
screen=$(cmux read-screen --surface surface:S)
# "trust" 検出 → 承認
cmux send-key --surface surface:S return
```

### Step 4: 起動完了の検出

`❯` プロンプトが表示されるまで `read-screen` でポーリング。

### Step 5: プロンプト送信

```bash
# 単一行
cmux send --surface surface:S "指示テキスト\n"

# 複数行（send-key return で改行）
cmux send --surface surface:S "1行目の指示"
cmux send-key --surface surface:S return
cmux send --surface surface:S "2行目の指示"
cmux send-key --surface surface:S return
```

### Step 6: 完了検出

`❯` プロンプトの再表示を `read-screen` でポーリングして検出。

### Step 7: 結果回収

```bash
result=$(cmux read-screen --surface surface:S --scrollback)  # 全出力取得
cmux close-surface --surface surface:S                        # 不要なら閉じる
```

## read-screen トラブルシューティング

| 問題 | 対処 |
|------|------|
| 出力が空 / 古い | `cmux refresh-surfaces` してから再読み取り |
| 長い出力が切れる | `--scrollback` を追加 |
| 特定行数だけ欲しい | `--lines N` で行数指定 |
| surface が見つからない | `cmux list-pane-surfaces` で refs を再確認 |

`read-screen` の結果がおかしい場合は `cmux refresh-surfaces` → 再読み取りの順で試す。

## ロングラン実行の監視

dev server やビルドなど長時間プロセスは専用ペインに分離し、`read-screen` で定期的に監視する。

```bash
cmux new-split right              # → surface:N
cmux send --surface surface:N "npm run dev\n"
# ポーリングで "ready" 等のキーワードを検出
screen=$(cmux read-screen --surface surface:N)
```

## 通知

```bash
# アプリ内通知（ペインハイライト、サイドバーバッジ。Cmd+Shift+U で移動）
cmux notify --title "完了" --body "ビルドが成功しました"

# macOS 通知センター（サウンド付き、別アプリ使用中でも表示）
osascript -e 'display notification "ビルド完了" with title "Claude" sound name "Glass"'
```

使い分け: cmux 内で注意を引く → `cmux notify`、ユーザーが別アプリにいる → `osascript`。

## ステータス・プログレス表示

```bash
cmux set-status mykey "作業中" --icon hammer --color "#0099ff"  # サイドバーに表示
cmux clear-status mykey
cmux set-progress 0.5 --label "ビルド中..."                     # プログレスバー（0.0〜1.0）
cmux clear-progress
```

## ブラウザ

cmux にはブラウザ自動化機能もある。詳細は `cmux browser --help` を参照。
`cmux new-pane --type browser --url <url>` でブラウザペインを作成できる。

## 環境変数

| 変数 | 説明 |
|------|------|
| `CMUX_SOCKET_PATH` | cmux ソケットのパス。存在すれば cmux 内で動作中 |
| `CMUX_WORKSPACE_ID` | 現在のワークスペース ID |
| `CMUX_SURFACE_ID` | 現在のサーフェス ID |

## よくあるミス

| ミス | 正しい方法 |
|------|-----------|
| `send "line1\nline2\n"` で複数行を送る | 各行を個別に `send` し、行間で `send-key return` を使う |
| UUID でサーフェスを指定する | 短縮 refs を使う: `surface:1`, `pane:2` |
| サブエージェントを同一ワークスペースに配置 | 別ワークスペース (`new-workspace`) に配置する |
| `read-screen` の結果が空で諦める | `refresh-surfaces` を実行してからリトライ |
| Trust プロンプトを見逃してハングする | 起動後に `read-screen` でポーリングして検出する |

## コマンドクイックリファレンス

| コマンド | 説明 |
|---------|------|
| `identify` / `tree` | 環境情報 / トポロジー表示 |
| `list-workspaces` / `list-panes` / `list-pane-surfaces` | 一覧表示 |
| `new-workspace` / `new-split <dir>` | ワークスペース・ペイン作成 |
| `send` / `send-key` / `read-screen` | 入出力操作 |
| `refresh-surfaces` | 画面バッファ強制更新 |
| `close-surface` / `close-workspace` | リソース終了 |
| `select-workspace` / `rename-workspace` / `rename-tab` | 選択・名前変更 |
| `notify` / `set-status` / `set-progress` | 通知・ステータス・進捗 |
| `wait-for` | シグナル待機 |
