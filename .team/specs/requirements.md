# using-cmux スキルパッケージ — 要件定義

## 概要

AI が cmux ターミナルを操作するための汎用スキルパッケージ。
hashangit/cmux-skill の代替として、実践的なノウハウを反映した自作版。

## 背景・動機

- 既存の using-cmux スキル (hashangit製) はブラウザ API リファレンスが50%を占め、サブエージェント操作の知見が不足
- cmux-team 開発で判明した実践知見を反映したオリジナル版が必要
- cmux-team（マルチエージェントオーケストレーション）の前提スキルとして位置づける

## 成果物

| # | ファイル | 説明 |
|---|---------|------|
| 1 | `.claude/skills/using-cmux/SKILL.md` | メインスキル定義 |
| 2 | `.claude/commands/cmux.md` | /cmux スラッシュコマンド |
| 3 | `install.sh` | インストーラ（--check, --uninstall 対応） |
| 4 | `README.md` | 人間向けガイド |
| 5 | `CLAUDE.md` | 開発ガイド |
| 6 | `.gitignore` | Git除外設定 |
| 7 | `LICENSE` | MIT ライセンス |

## SKILL.md 要件（優先度順）

### P1: 基本操作
- `cmux identify` — 現在の環境確認
- `cmux split` — ペイン分割
- `cmux workspace` — ワークスペース管理
- `cmux send` — コマンド送信
- `cmux read-screen` — 画面読み取り
- `cmux close` — ペイン/ワークスペース終了

### P2: send の改行ルール（重要）
- 単一行コマンド: `cmux send <surface> "command\n"` — `\n` で送信OK
- 複数行コマンド: 各行を `cmux send` で送り、行間に `cmux send-key <surface> return` が必要
- **これは最も頻出するミスなので明確に記述する**

### P3: サブエージェント1体の起動→監視→結果回収パターン
- Trust ポーリング: `cmux read-screen` で "Trust" プロンプトを検出し承認
- ブート検出: Claude Code の起動完了を検出
- プロンプト送信: `cmux send` でタスクを送信
- 完了検出: 出力の安定化やプロンプト復帰で検出

### P4: read-screen トラブルシューティング
- `cmux refresh-surfaces` — 画面が古い場合のリフレッシュ
- `--scrollback` オプション — スクロールバック内容の取得

### P5: ロングラン実行の監視
- dev server, build 等の起動と監視パターン
- バックグラウンドプロセスの出力確認方法

### P6: 通知
- `cmux notify` — cmux 内通知
- `osascript` — macOS ネイティブ通知
- 使い分けの指針

### P7: ステータス・プログレス表示
- `cmux set-status` — ステータスバー更新
- `cmux set-progress` — 進捗表示

### P8: ブラウザ
- 最小限の記述（5行以内）
- `cmux browser --help` 参照を案内

### P9: 環境変数
- `CMUX_SOCKET_PATH` — ソケットパス
- `CMUX_WORKSPACE_ID` — ワークスペースID
- `CMUX_SURFACE_ID` — サーフェスID

### P10: よくあるミス
- 改行問題（P2の再強調）
- UUID vs refs（surface参照の方法）
- 同一ワークスペース配置の問題

## install.sh 要件

- `--check`: インストール状態の確認
- `--uninstall`: アンインストール
- 引数なし: インストール実行
- インストール先: `~/.claude/skills/using-cmux/` と `~/.claude/commands/`
- シンボリックリンクまたはコピーで配置

## スラッシュコマンド (/cmux) 要件

- cmux の基本操作ガイドを表示
- よく使うパターンのクイックリファレンス

## 制約

- ドキュメント・コメントは日本語、コードは英語
- cmux-team との重複を避ける（using-cmux は汎用、cmux-team はオーケストレーション）
- ブラウザ操作は最小限に抑える
