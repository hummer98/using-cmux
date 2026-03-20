# cfork - 会話を新しい cmux ペインにフォーク

即座に以下を1回の bash で実行せよ（引数があれば `right` をその方向に置き換え）:

```bash
S=$(cmux new-split right | awk '{print $2}') && cmux send --surface "$S" "claude --continue --fork-session\n"
```

ポーリング・Trust 検出・起動確認は一切不要。結果を1行で報告。
