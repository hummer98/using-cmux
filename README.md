# using-cmux

AI が cmux を操作するための Claude Code スキルパッケージ。

## Quick Start

```bash
git clone <repository-url>
cd using-cmux
bash install.sh
```

これで Claude Code が cmux 操作のスキルを自動的に読み込みます。

## 既存スキルとの違い

hashangit/cmux-skill の代替として設計されています。

- **ブラウザ操作の記述を最小限に削減** — 元の約50%から5行程度へ。`cmux browser --help` 参照の案内のみ
- **サブエージェント操作パターンを中核に据えた** — 起動→監視→結果回収の一連の手順を構造化
- **send の改行ルールを明確化** — 3箇所で強調（専用セクション、サブエージェントパターン内の実例、よくあるミスのテーブル）

## Installation

```bash
bash install.sh
```

以下のファイルがインストールされます:

| インストール先 | 内容 |
|---------------|------|
| `~/.claude/skills/using-cmux/SKILL.md` | メインスキル定義（Claude Code が自動読み込み） |
| `~/.claude/commands/cmux.md` | `/cmux` スラッシュコマンド |

### インストール確認

```bash
bash install.sh --check
```

## Usage

- **SKILL.md** は Claude Code のスキルシステムが自動で読み込みます。cmux 環境内（`CMUX_SOCKET_PATH` 環境変数が存在する場合）でトリガーされます
- `/cmux` スラッシュコマンドでクイックリファレンスを表示できます

## Uninstall

```bash
bash install.sh --uninstall
```

## License

MIT
