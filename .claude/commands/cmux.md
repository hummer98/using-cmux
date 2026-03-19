# cmux クイックリファレンス

まず `cmux identify` を実行して現在の環境を確認し、結果を表示してください。

次に、以下のクイックリファレンスを参照しながらユーザーの操作を支援してください。

---

## 基本操作

| 操作 | コマンド |
|------|---------|
| 環境確認 | `cmux identify` |
| ワークスペース一覧 | `cmux list-workspaces` |
| ペイン分割（右） | `cmux new-split right` |
| ペイン分割（下） | `cmux new-split down` |
| 画面読み取り | `cmux read-screen --surface surface:N` |
| スクロールバック含む | `cmux read-screen --surface surface:N --scrollback` |
| テキスト送信 | `cmux send --surface surface:N "text\n"` |
| キー送信 | `cmux send-key --surface surface:N return` |
| サーフェス閉じる | `cmux close-surface --surface surface:N` |
| 通知 | `cmux notify --title "タイトル" --body "本文"` |

## send の改行ルール（重要）

**単一行**: `\n` 末尾で送信できる。

```bash
cmux send --surface surface:N "echo hello\n"
```

**複数行は `\n` で送れない**。`send-key return` で1行ずつ送る:

```bash
cmux send --surface surface:N "echo line1"
cmux send-key --surface surface:N return
cmux send --surface surface:N "echo line2"
cmux send-key --surface surface:N return
```

## サブエージェント起動の最小手順

1. **ペイン分割**: `cmux new-split right` → surface:N を取得
2. **Claude 起動**: `cmux send --surface surface:N "claude --dangerously-skip-permissions\n"`
3. **Trust 検出**: `cmux read-screen --surface surface:N` をポーリングし、trust プロンプトが出たら `cmux send --surface surface:N "trust\n"`
4. **起動確認**: `read-screen` で Claude Code の起動完了（`$` や入力プロンプト `>`）を検出
5. **プロンプト送信**: `cmux send --surface surface:N "指示内容"` + `cmux send-key --surface surface:N return`
6. **完了待機**: `read-screen` をポーリングし完了マーカーを検出
7. **結果回収**: `cmux read-screen --surface surface:N --scrollback`

## トラブルシューティング

| 症状 | 対処 |
|------|------|
| read-screen が空 | `cmux refresh-surfaces` を実行してからリトライ |
| surface が見つからない | `cmux list-pane-surfaces` で最新の ref を確認 |
| 複数行が化ける | `send` + `send-key return` に切り替える |
| 操作対象を間違える | `cmux identify` で caller/focused を再確認 |

## 環境変数

| 変数 | 用途 |
|------|------|
| `CMUX_SOCKET_PATH` | cmux ソケットパス（cmux 内で自動設定） |
| `CMUX_WORKSPACE_ID` | 現在のワークスペース UUID |
| `CMUX_SURFACE_ID` | 現在のサーフェス UUID |

詳細は using-cmux スキル（SKILL.md）を参照してください。
