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
| キー送信 | `cmux send-key --surface surface:N return` / `ctrl+c` / `ctrl+d` |
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

## 制御キーの送信

プロセス中断（Ctrl+C）などの制御キーは **`send-key`** で送る。`send` では送れない。

```bash
# ✅ 正しい方法
cmux send-key --surface surface:N ctrl+c

# ❌ 間違い — リテラルテキストが送られるだけ
cmux send --surface surface:N "C-c"
cmux send --surface surface:N "\x03"
cmux send-key --surface surface:N "C-c"   # → Unknown key エラー
```

キー名は `ctrl+c`, `ctrl+d`, `ctrl+z`, `return`, `tab`, `escape` 等。`send-key --help` で確認可能。

## cross-workspace 操作の注意（重要）

別ワークスペースのサーフェスを操作する場合、**`--surface` ではなく `--workspace` を使う**。

**surface:N を渡されたら、まず `cmux tree` でどのワークスペースにあるか確認する。**

```bash
cmux tree   # → surface:N が workspace:M に属することを確認
cmux read-screen --workspace workspace:M
```

```bash
# ✅ 正しい方法 — --workspace で指定（focused surface に自動解決）
cmux send --workspace workspace:N "command\n"
cmux read-screen --workspace workspace:N
cmux send-key --workspace workspace:N return

# ❌ 間違い — --surface で他ワークスペースのサーフェスを指定
cmux send --surface surface:S "command\n"        # → "Surface is not a terminal" エラー
cmux read-screen --surface surface:S             # → 同上
```

**理由**: `--surface` は caller と同一ワークスペース内のサーフェスのみ有効。他ワークスペースのサーフェスを指定すると CLI は "Surface is not a terminal" エラーを返す。`--workspace` はワークスペースの focused surface に自動解決され、cross-workspace でも正しく動作する。

## ペイン再利用の原則

新しいペイン/ワークスペースを作る前に、ユーザーが clear 済みの遊休ペインを探して再利用する。

```bash
cmux list-pane-surfaces                          # 全サーフェス一覧
screen=$(cmux read-screen --surface surface:N)   # 各サーフェスの状態を確認
# シェルプロンプト（$ や ❯）のみ → 遊休 → 再利用可能
```

遊休ペインがなければ通常通り `new-split` / `new-workspace` で作成する。

## サブエージェント操作パターン

サブエージェントを起動し、タスクを委任し、結果を回収する一連の手順。

### 配置方式の選択

| 方式 | 利点 | 注意 |
|------|------|------|
| **同一ワークスペース** (`new-split`) | PTY 遅延初期化問題を回避、`--surface` で直接操作可能 | レイアウトが崩れたら `cmux-grid` で修復 |
| **別ワークスペース** (`new-workspace`) | `close-workspace` で一括終了、`rename-workspace` で識別しやすい | PTY 遅延初期化問題の影響あり（後述） |

### Step 1a: 同一ワークスペースに配置（推奨）

```bash
SURF=$(cmux new-split right | awk '{print $2}')
cmux rename-tab --surface $SURF "Researcher-1"
```

### Step 1b: 別ワークスペースに配置

```bash
WS=$(cmux new-workspace --cwd $(pwd) | awk '{print $2}')
cmux rename-workspace --workspace $WS "Researcher-1"
```

> **注意**: PTY 遅延初期化問題（後述）により、ワークスペースを GUI 上で一度表示する必要がある場合がある。

### Step 2: Claude Code 起動

```bash
cmux send --workspace $WS "claude --dangerously-skip-permissions\n"
```

> `--dangerously-skip-permissions` は信頼できるタスクにのみ使うこと。

### Step 3: Trust 検出 → 承認

起動直後に Trust 確認プロンプトが表示される場合がある。`read-screen` でポーリングし、"trust" や "Yes, I trust" を検出したら承認:

```bash
screen=$(cmux read-screen --workspace $WS)
# "trust" 検出 → 承認
cmux send-key --workspace $WS return
```

### Step 4: 起動完了の検出

`❯` プロンプトが表示されるまで `read-screen --workspace $WS` でポーリング。

### Step 5: プロンプト送信

```bash
# 単一行
cmux send --workspace $WS "指示テキスト\n"
cmux set-status $WS "調査中" --icon hammer  # ステータスを設定

# 複数行（send-key return で改行）
cmux send --workspace $WS "1行目の指示"
cmux send-key --workspace $WS return
cmux send --workspace $WS "2行目の指示"
cmux send-key --workspace $WS return
```

### Step 6: 完了検出

`❯` プロンプトの再表示を `read-screen --workspace $WS` でポーリングして検出。

### Step 7: 結果回収 & クリーンアップ

```bash
cmux clear-status $WS                                      # ステータスをクリア
result=$(cmux read-screen --workspace $WS --scrollback)  # 全出力取得

# クリーンアップ: Claude 終了 → ペイン閉じ
cmux send --workspace $WS "/exit\n"
sleep 2
cmux close-workspace --workspace $WS                      # ワークスペースごと閉じる
```

> **重要**: `/exit` だけでは Claude プロセスが終了するだけでペイン（surface）は残る。必ず `close-workspace`（または `close-surface`）でペインも閉じること。`sleep 2` は `/exit` の処理完了を待つため。

## new-workspace の PTY 遅延初期化問題（Issue #1472）

`cmux new-workspace` で作成したワークスペースのターミナル PTY は、**GUI 上で一度表示されるまで起動しない**。
`select-workspace` API だけでは不十分で、GUI 描画（SwiftUI レンダリング）が必要。

### 症状

- `cmux send --surface surface:N` → OK を返すがコマンドは実行されない（キューに留まる）
- `cmux read-screen --surface surface:N` → `Surface is not a terminal` エラー
- ソケット API `surface.send_text` → `queued: true` だが未配信
- ソケット API `surface.read_text` → `Terminal surface not found`

### ワークアラウンド: AppleScript メニュークリック

macOS アクセシビリティ許可が必要（システム設定 → プライバシーとセキュリティ → アクセシビリティ）。

```bash
# ワークスペース作成後に GUI 表示を強制する
WS=$(cmux new-workspace --cwd $(pwd) | awk '{print $2}')

# ワークスペースのインデックスを取得
WS_INDEX=$(cmux tree --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for w in data['windows']:
    for ws in w['workspaces']:
        if ws['ref'] == '$WS':
            print(ws['index'] + 1)")

# AppleScript でメニュークリック → PTY 初期化
osascript -e "
tell application \"System Events\"
    tell process \"cmux\"
        click menu item \"ワークスペース $WS_INDEX\" of menu 1 of menu bar item \"表示\" of menu bar 1
    end tell
end tell"
sleep 2

# 元のワークスペースに戻る
ORIG_INDEX=1  # 元のワークスペースの index+1
osascript -e "
tell application \"System Events\"
    tell process \"cmux\"
        click menu item \"ワークスペース $ORIG_INDEX\" of menu 1 of menu bar item \"表示\" of menu bar 1
    end tell
end tell"
```

### 注意: ソケット API のフォールバック

ソケット API `surface.send_text` / `surface.read_text` は、ターゲット surface の PTY が未初期化の場合、**caller の surface にサイレントにフォールバックする**ことがある。レスポンスの `surface_ref` を確認して意図した surface に送信されたか必ず検証すること。

## read-screen トラブルシューティング

| 問題 | 対処 |
|------|------|
| 出力が空 / 古い | `cmux refresh-surfaces` してから再読み取り |
| 長い出力が切れる | `--scrollback` を追加 |
| 特定行数だけ欲しい | `--lines N` で行数指定 |
| surface が見つからない | `cmux list-pane-surfaces` で refs を再確認 |
| `Surface is not a terminal` | 別ワークスペースのサーフェスに `--surface` でアクセスしている → `cmux tree` でワークスペースを確認し `--workspace` を使う。または PTY 遅延初期化問題（上記ワークアラウンド参照） |

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

## ブラウザ自動化

### 開く・ナビゲーション

```bash
BSURF=$(cmux browser open https://example.com | awk '{print $2}')  # ブラウザを開く
cmux browser $BSURF goto https://google.com   # 移動
cmux browser $BSURF back / forward / reload   # 戻る・進む・リロード
cmux browser $BSURF url                        # 現在の URL を取得
cmux browser $BSURF focus-webview              # ブラウザにフォーカス
```

### スナップショットと要素参照

```bash
cmux browser $BSURF snapshot --interactive   # [ref=eN] マーカー付きで取得（操作前に必須）
```

出力例（eN が CSS セレクタとして機能する）:
```
heading "Welcome" [ref=e1]
button "Submit" [ref=e2]
textbox [ref=e3]
```

| オプション | 説明 |
|-----------|------|
| `--interactive` / `-i` | `[ref=eN]` マーカーを付与 |
| `--compact` | コンパクト表示 |
| `--max-depth N` | DOM 深度制限 |
| `--selector css` | 特定要素のみ |
| `--cursor` | カーソル位置情報を含む |

### 要素の操作

セレクタには CSS セレクタまたはスナップショットの ref（`e2` 等）を使う。`--snapshot-after` で操作後に自動でスナップショットを取得できる。

```bash
cmux browser $BSURF click e2              # クリック
cmux browser $BSURF dblclick e5           # ダブルクリック
cmux browser $BSURF hover e3              # ホバー
cmux browser $BSURF focus e3             # フォーカス
cmux browser $BSURF scroll-into-view e4  # ビューにスクロール
cmux browser $BSURF check e8 / uncheck e8 # チェック・解除
```

### フォーム操作

```bash
cmux browser $BSURF fill e3 "hello"         # 入力（既存をクリアして入力）
cmux browser $BSURF type e3 "world"         # 追記入力
cmux browser $BSURF select e7 "option-val"  # ドロップダウン選択
cmux browser $BSURF press Enter             # キー押下（Return, Tab, Escape 等）
```

### 要素の検索・状態確認

```bash
# find: ARIA ロール / テキスト / ラベル / プレースホルダー / alt / title / testid / first / last / nth
cmux browser $BSURF find role button
cmux browser $BSURF find text "Submit"
cmux browser $BSURF find nth 3 --selector "li"

# is: 要素の状態確認
cmux browser $BSURF is visible e3    # 表示されているか
cmux browser $BSURF is enabled e3   # 有効か
cmux browser $BSURF is checked e8   # チェック済みか
```

### データ取得

```bash
cmux browser $BSURF get url / title               # URL・タイトル
cmux browser $BSURF get text e3                   # テキスト
cmux browser $BSURF get html e3                   # HTML
cmux browser $BSURF get value e3                  # 入力値
cmux browser $BSURF get attr e3 href              # 属性
cmux browser $BSURF get count "button"            # 要素数
cmux browser $BSURF get box e3                    # バウンディングボックス
```

### 待機

```bash
cmux browser $BSURF wait --selector "#loaded" --timeout-ms 10000
cmux browser $BSURF wait --text "Success"
cmux browser $BSURF wait --url-contains "/dashboard"
cmux browser $BSURF wait --load-state complete          # または interactive
cmux browser $BSURF wait --function "document.readyState === 'complete'"
```

### JavaScript・DOM 注入

```bash
cmux browser $BSURF eval 'document.querySelector("h1").innerText'
cmux browser $BSURF addinitscript 'window.myFlag = true'  # ページ読み込み前に注入
cmux browser $BSURF addstyle 'body { background: red }'   # CSS 注入
```

### iframe・ダイアログ

```bash
cmux browser $BSURF frame selector "#iframe1"   # iframe に切り替え
cmux browser $BSURF frame main                   # メインフレームに戻る

cmux browser $BSURF dialog accept               # confirm/alert を OK
cmux browser $BSURF dialog dismiss              # キャンセル
cmux browser $BSURF dialog accept "入力テキスト" # prompt に入力
```

### スクロール・スクリーンショット・デバッグ

```bash
cmux browser $BSURF scroll --dy 500                    # 下に 500px
cmux browser $BSURF scroll --selector "#list" --dy 200 # 要素内スクロール
cmux browser $BSURF screenshot --out ~/Desktop/cap.png
cmux browser $BSURF highlight e3                        # 要素をハイライト
cmux browser $BSURF console list                        # コンソールメッセージ
cmux browser $BSURF errors list                         # JavaScript エラー
```

### snapshot vs screenshot の使い分け

**原則: 要素を操作・確認する目的では `snapshot` を使う。`screenshot` はトークンを大量消費するため最終手段にとどめる。**

| 目的 | 使うコマンド | 理由 |
|------|------------|------|
| ページ上の要素を探して操作する | `snapshot --interactive` | テキストで返るため低コスト。ref で直接操作可能 |
| テキスト内容・構造を確認する | `snapshot` | DOM ツリーをテキストで取得 |
| 視覚的レイアウトの確認が必要 | `screenshot` | PNG 画像（トークン大） |
| デバッグで目視確認したい | `screenshot` | スナップショットで判断できない場合のみ |

`screenshot` を使いたくなったらまず `snapshot` で代替できないか検討すること。

### セッション・状態管理

```bash
cmux browser $BSURF cookies get / set / clear
cmux browser $BSURF storage local get --key "user"
cmux browser $BSURF storage session set --key "token" --value "xyz"
cmux browser $BSURF state save ~/.browser-state/session.json   # 認証状態を保存
cmux browser $BSURF state load ~/.browser-state/session.json   # 復元
cmux browser $BSURF tab list / new / switch 2 / close 2        # タブ管理
```

### WKWebView の制限（コマンドは存在するが `not_supported` エラー）

以下のコマンドは `cmux browser --help` に表示されるが、現在の WKWebView では動作しない:

| コマンド | エラー |
|---------|--------|
| `viewport <w> <h>` | `browser.viewport.set is not supported on WKWebView` |
| `geo <lat> <lon>` | `browser.geolocation.set is not supported on WKWebView` |
| `offline true/false` | `browser.offline.set is not supported on WKWebView` |
| `trace start/stop` | `browser.trace.start is not supported on WKWebView` |
| `network route/unroute` | `browser.network.route is not supported on WKWebView` |
| `screencast start/stop` | `browser.screencast.start is not supported on WKWebView` |
| `input mouse/keyboard/touch` | `browser.input_mouse is not supported on WKWebView` |

### ブラウザ操作のよくあるミス

| ミス | 正しい方法 |
|------|-----------|
| スナップショットなしで ref を使う | 操作前に `snapshot --interactive` で ref を取得 |
| ナビゲーション後に古い ref を使う | 遷移後は再スナップショット（ref は DOM 変更で無効化） |
| `dialog` を無視してハングする | クリック前後に `dialog accept/dismiss` を仕込む |
| iframe 内の要素が見つからない | `frame selector` で切り替えてから操作する |

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
| 同一ワークスペースのレイアウト崩れを放置 | `cmux-grid` で整列するか、別ワークスペースに配置する |
| `read-screen` の結果が空で諦める | `refresh-surfaces` を実行してからリトライ |
| Trust プロンプトを見逃してハングする | 起動後に `read-screen` でポーリングして検出する |
| `--surface` で他ワークスペースを操作 | `cmux-read` / `cmux-send` / `cmux-send-key` を使う（自動解決） |
| `send "C-c"` や `send "\x03"` で Ctrl+C を送る | `send-key ctrl+c` を使う（制御キーの送信 参照） |
| 遊休ペインがあるのに新しく split する | `list-pane-surfaces` + `read-screen` で遊休ペインを探して再利用する |
| ワークスペースに名前を付けない | `rename-workspace` で用途を示す名前を付ける |
| `/exit` だけでクリーンアップ完了と思う | `/exit` → `sleep 2` → `close-workspace` / `close-surface` でペインも閉じる |

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
| `cmux-grid` / `cmux-grid 2x3` | ペインをグリッドレイアウトに整列 |
| `notify` / `set-status` / `set-progress` | 通知・ステータス・進捗 |
| `wait-for` | シグナル待機 |
