# using-cmux 開発ガイド

cmux ターミナル操作のための Claude Code スキルパッケージ。
サブエージェント操作パターンを中心に、実践的なノウハウを構造化して提供する。

## ファイル構成

| ファイル | 役割 |
|---------|------|
| `skills/using-cmux/SKILL.md` | メインスキル定義（AI が読む） |
| `commands/cmux.md` | `/cmux` スラッシュコマンド |
| `commands/cfork.md` | `/cfork` 会話フォークコマンド |
| `bin/cmux-grid` | ペインをグリッドレイアウトに整列するスクリプト |
| `bin/cmux-read` `bin/cmux-send` `bin/cmux-send-key` | surface→workspace 自動解決ラッパー |
| `bin/cfork` | `/cfork` 用シェルスクリプト |
| `.claude-plugin/plugin.json` | Plugin マニフェスト |
| `.claude-plugin/marketplace.json` | Marketplace カタログ |
| `README.md` | 人間向けガイド |
| `CLAUDE.md` | この開発ガイド |
| `LICENSE` | MIT ライセンス |
| `.gitignore` | Git 除外設定 |

## 言語ルール

- **ドキュメント・コメント**: 日本語
- **コード（変数名・関数名・コマンド）**: 英語

## SKILL.md の編集ルール

- **約200行を目標**とする（簡潔さ優先）
- ブラウザ操作は **必要十分な範囲**でカバーする（現在の cmux `--help` と照合して最新状態を維持）
- **サブエージェント操作パターン**が中核セクション（~50行）
- **send の改行ルール**は3層強調を維持する:
  1. 専用セクションで詳細説明
  2. サブエージェントパターン内で実例
  3. 「よくあるミス」テーブルで再強調
- テーブル形式・コード例を多用し、散文は最小限に

## cmux-team との境界

| 観点 | using-cmux | cmux-team |
|------|-----------|-----------|
| 対象 | 汎用的な cmux 操作 | マルチエージェントオーケストレーション |
| サブエージェント | 1体の起動→監視→結果回収 | 複数エージェントの並列管理 |
| スコープ | cmux CLI の基本操作全般 | チーム構成・タスク分配・同期 |

**重複を避ける**: using-cmux に cmux-team 固有の機能（チーム管理、イシュー管理等）を含めない。

## メンテナンス手順

1. `cmux --help` の出力と SKILL.md のコマンド一覧を突き合わせて整合性を確認
2. 新しい cmux コマンドが追加されたら SKILL.md を更新
3. SKILL.md の行数が200行を大幅に超えていないか確認

## 配布

Plugin として配布する。`bin/` 配下のスクリプトは Claude Code が自動的に PATH に追加するため、ユーザー側でのセットアップは不要。skills/ commands/ も Plugin マニフェスト経由で読み込まれる。

`/plugin update` 後、PATH に焼き込まれているのは旧バージョンのまま（セッション開始時に確定）。`bin/` の更新を反映するには cmux セッションの再起動が必要。
