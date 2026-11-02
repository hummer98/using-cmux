# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.9.0] - 2026-11-02

### Added
- `/ctab`: タブタイトルを `[surface番号]` を維持したまま変更するコマンドとスキル
- SKILL.md に、TTY を占有するコマンド（`claude --resume`、`ssh -t`、`vim` など）を Bash ツールで実行せず別 surface に送る指針を追加 (#11)
- SKILL.md に `new-split --command`（cmux 0.64.23 以降）と `list-panes --json` のペイン寸法（cmux 0.64.25 以降）を追加 (#9, #8)

### Changed
- snapshot と screenshot の使い分けルールを強調
- PTY 遅延初期化の節に、cmux 本家で修正されたバージョンを明記 (#4)

### Fixed
- `bin/` のスクリプトは Bash ツールの PATH にのみ入り、ユーザーのターミナルでは使えないことをドキュメントに明記 (#15)
- `ctab` スキルの、SessionStart フックでタイトルが戻る条件の説明を修正 (#15)
