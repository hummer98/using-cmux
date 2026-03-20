# cfork - 会話を新しい cmux ペインにフォーク

現在の Claude Code 会話をフォーク（新しいセッション ID で分岐）し、新しい cmux ペインで自動的に開く。

## 前提条件

`CMUX_SOCKET_PATH` 環境変数が存在しなければ「cmux 内でのみ使用可能です」と伝えて終了する。

## 手順

1. **ペイン分割**: `cmux new-split right` を実行し、返された surface ref を記録する。
   - 引数で方向が指定されている場合はその方向を使う（例: `/cfork down`）

2. **Claude Code 起動**: 新しいペインで会話フォークを起動する:
   ```bash
   cmux send --surface <surface-ref> "claude --continue --fork-session\n"
   ```
   - `--continue`: 現在の会話履歴を引き継ぐ
   - `--fork-session`: 新しいセッション ID を生成（元の会話は影響を受けない）

3. **Trust 検出**: `read-screen` でペインをポーリングし、Trust プロンプト（"trust" を含む行）が表示されたら承認する:
   ```bash
   cmux send-key --surface <surface-ref> return
   ```

4. **起動確認**: `❯` プロンプトの表示を `read-screen` で確認する。

5. **完了報告**: フォークが新しいペインで利用可能になったことをユーザーに伝える。
