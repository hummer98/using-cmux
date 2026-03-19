# タスク一覧

## Task 1: SKILL.md 作成 (P)
- 説明: メインスキル定義。全10セクション（P1〜P10）を含む。サブエージェント操作パターンにコード例を含め、send の改行ルールを3層強調する
- 依存: なし
- 推定規模: L

## Task 2: cmux.md 作成 (P)
- 説明: /cmux スラッシュコマンド。基本操作ガイドとよく使うパターンのクイックリファレンスを表示
- 依存: なし
- 推定規模: S

## Task 3: install.sh 作成
- 説明: インストーラ。--check, --uninstall, デフォルト(インストール)の3モード。既存版検出と警告を含む
- 依存: Task 1, Task 2（コピー対象ファイルが確定している必要がある）
- 推定規模: M

## Task 4: CLAUDE.md 作成 (P)
- 説明: 開発ガイド。ファイル構成、言語ルール、メンテナンス手順を含む
- 依存: なし
- 推定規模: S

## Task 5: README.md 作成
- 説明: 人間向けガイド。Quick Start → What's Different → Installation → Usage → Uninstall の構成
- 依存: Task 1, Task 3（内容とインストール手順が確定している必要がある）
- 推定規模: M

## Task 6: LICENSE + .gitignore 更新 (P)
- 説明: MIT ライセンスファイルと .gitignore の更新
- 依存: なし
- 推定規模: S
