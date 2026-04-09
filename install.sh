#!/usr/bin/env bash
set -euo pipefail

# ソースディレクトリの解決
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# インストール元
SRC_SKILL="${SCRIPT_DIR}/skills/using-cmux/SKILL.md"
SRC_COMMAND="${SCRIPT_DIR}/commands/cmux.md"
SRC_CFORK="${SCRIPT_DIR}/commands/cfork.md"
SRC_CFORK_BIN="${SCRIPT_DIR}/bin/cfork"
SRC_GRID_BIN="${SCRIPT_DIR}/bin/cmux-grid"
SRC_READ_BIN="${SCRIPT_DIR}/bin/cmux-read"
SRC_SEND_BIN="${SCRIPT_DIR}/bin/cmux-send"
SRC_SEND_KEY_BIN="${SCRIPT_DIR}/bin/cmux-send-key"

# インストール先
DEST_SKILL="${HOME}/.claude/skills/using-cmux/SKILL.md"
DEST_COMMAND="${HOME}/.claude/commands/cmux.md"
DEST_CFORK="${HOME}/.claude/commands/cfork.md"
DEST_CFORK_BIN="${HOME}/.local/bin/cfork"
DEST_GRID_BIN="${HOME}/.local/bin/cmux-grid"
DEST_READ_BIN="${HOME}/.local/bin/cmux-read"
DEST_SEND_BIN="${HOME}/.local/bin/cmux-send"
DEST_SEND_KEY_BIN="${HOME}/.local/bin/cmux-send-key"

# 色付き出力
green() { printf '\033[32m%s\033[0m\n' "$1"; }
yellow() { printf '\033[33m%s\033[0m\n' "$1"; }
red() { printf '\033[31m%s\033[0m\n' "$1"; }

# ソースファイルの存在確認
check_source_files() {
  local missing=0
  if [[ ! -f "$SRC_SKILL" ]]; then
    red "エラー: ソースファイルが見つかりません: ${SRC_SKILL}"
    missing=1
  fi
  if [[ ! -f "$SRC_COMMAND" ]]; then
    red "エラー: ソースファイルが見つかりません: ${SRC_COMMAND}"
    missing=1
  fi
  if [[ ! -f "$SRC_CFORK" ]]; then
    red "エラー: ソースファイルが見つかりません: ${SRC_CFORK}"
    missing=1
  fi
  if [[ ! -f "$SRC_CFORK_BIN" ]]; then
    red "エラー: ソースファイルが見つかりません: ${SRC_CFORK_BIN}"
    missing=1
  fi
  if [[ ! -f "$SRC_GRID_BIN" ]]; then
    red "エラー: ソースファイルが見つかりません: ${SRC_GRID_BIN}"
    missing=1
  fi
  if [[ ! -f "$SRC_READ_BIN" ]]; then
    red "エラー: ソースファイルが見つかりません: ${SRC_READ_BIN}"
    missing=1
  fi
  if [[ ! -f "$SRC_SEND_BIN" ]]; then
    red "エラー: ソースファイルが見つかりません: ${SRC_SEND_BIN}"
    missing=1
  fi
  if [[ ! -f "$SRC_SEND_KEY_BIN" ]]; then
    red "エラー: ソースファイルが見つかりません: ${SRC_SEND_KEY_BIN}"
    missing=1
  fi
  if [[ $missing -eq 1 ]]; then
    exit 1
  fi
}

# --check: インストール状態の確認
do_check() {
  local installed=0
  if [[ -f "$DEST_SKILL" ]]; then
    green "✓ ${DEST_SKILL}"
    installed=$((installed + 1))
  else
    red "✗ ${DEST_SKILL}"
  fi
  if [[ -f "$DEST_COMMAND" ]]; then
    green "✓ ${DEST_COMMAND}"
    installed=$((installed + 1))
  else
    red "✗ ${DEST_COMMAND}"
  fi
  if [[ -f "$DEST_CFORK" ]]; then
    green "✓ ${DEST_CFORK}"
    installed=$((installed + 1))
  else
    red "✗ ${DEST_CFORK}"
  fi

  if [[ -f "$DEST_CFORK_BIN" ]]; then
    green "✓ ${DEST_CFORK_BIN}"
    installed=$((installed + 1))
  else
    red "✗ ${DEST_CFORK_BIN}"
  fi

  if [[ -f "$DEST_GRID_BIN" ]]; then
    green "✓ ${DEST_GRID_BIN}"
    installed=$((installed + 1))
  else
    red "✗ ${DEST_GRID_BIN}"
  fi
  if [[ -f "$DEST_READ_BIN" ]]; then
    green "✓ ${DEST_READ_BIN}"
    installed=$((installed + 1))
  else
    red "✗ ${DEST_READ_BIN}"
  fi
  if [[ -f "$DEST_SEND_BIN" ]]; then
    green "✓ ${DEST_SEND_BIN}"
    installed=$((installed + 1))
  else
    red "✗ ${DEST_SEND_BIN}"
  fi
  if [[ -f "$DEST_SEND_KEY_BIN" ]]; then
    green "✓ ${DEST_SEND_KEY_BIN}"
    installed=$((installed + 1))
  else
    red "✗ ${DEST_SEND_KEY_BIN}"
  fi

  if [[ $installed -eq 8 ]]; then
    green "インストール済みです。"
    exit 0
  else
    yellow "未インストールのファイルがあります。"
    exit 1
  fi
}

# --uninstall: アンインストール
do_uninstall() {
  local removed=0
  if [[ -f "$DEST_SKILL" ]]; then
    rm "$DEST_SKILL"
    green "削除: ${DEST_SKILL}"
    removed=$((removed + 1))
  fi
  if [[ -f "$DEST_COMMAND" ]]; then
    rm "$DEST_COMMAND"
    green "削除: ${DEST_COMMAND}"
    removed=$((removed + 1))
  fi
  if [[ -f "$DEST_CFORK" ]]; then
    rm "$DEST_CFORK"
    green "削除: ${DEST_CFORK}"
    removed=$((removed + 1))
  fi
  if [[ -f "$DEST_CFORK_BIN" ]]; then
    rm "$DEST_CFORK_BIN"
    green "削除: ${DEST_CFORK_BIN}"
    removed=$((removed + 1))
  fi
  if [[ -f "$DEST_GRID_BIN" ]]; then
    rm "$DEST_GRID_BIN"
    green "削除: ${DEST_GRID_BIN}"
    removed=$((removed + 1))
  fi
  if [[ -f "$DEST_READ_BIN" ]]; then
    rm "$DEST_READ_BIN"
    green "削除: ${DEST_READ_BIN}"
    removed=$((removed + 1))
  fi
  if [[ -f "$DEST_SEND_BIN" ]]; then
    rm "$DEST_SEND_BIN"
    green "削除: ${DEST_SEND_BIN}"
    removed=$((removed + 1))
  fi
  if [[ -f "$DEST_SEND_KEY_BIN" ]]; then
    rm "$DEST_SEND_KEY_BIN"
    green "削除: ${DEST_SEND_KEY_BIN}"
    removed=$((removed + 1))
  fi

  # 空ディレクトリの削除
  local skill_dir="${HOME}/.claude/skills/using-cmux"
  if [[ -d "$skill_dir" ]] && [[ -z "$(ls -A "$skill_dir")" ]]; then
    rmdir "$skill_dir"
  fi

  if [[ $removed -eq 0 ]]; then
    yellow "削除対象のファイルがありませんでした。"
  else
    green "アンインストール完了（${removed} ファイル削除）。"
  fi
}

# インストール実行
do_install() {
  check_source_files

  # 既存ファイルの検出と警告
  if [[ -f "$DEST_SKILL" ]]; then
    yellow "既存ファイルを上書きします: ${DEST_SKILL}"
  fi
  if [[ -f "$DEST_COMMAND" ]]; then
    yellow "既存ファイルを上書きします: ${DEST_COMMAND}"
  fi
  if [[ -f "$DEST_CFORK" ]]; then
    yellow "既存ファイルを上書きします: ${DEST_CFORK}"
  fi
  if [[ -f "$DEST_CFORK_BIN" ]]; then
    yellow "既存ファイルを上書きします: ${DEST_CFORK_BIN}"
  fi
  if [[ -f "$DEST_GRID_BIN" ]]; then
    yellow "既存ファイルを上書きします: ${DEST_GRID_BIN}"
  fi
  if [[ -f "$DEST_READ_BIN" ]]; then
    yellow "既存ファイルを上書きします: ${DEST_READ_BIN}"
  fi
  if [[ -f "$DEST_SEND_BIN" ]]; then
    yellow "既存ファイルを上書きします: ${DEST_SEND_BIN}"
  fi
  if [[ -f "$DEST_SEND_KEY_BIN" ]]; then
    yellow "既存ファイルを上書きします: ${DEST_SEND_KEY_BIN}"
  fi

  # ディレクトリ作成
  mkdir -p "$(dirname "$DEST_SKILL")"
  mkdir -p "$(dirname "$DEST_COMMAND")"
  mkdir -p "$(dirname "$DEST_CFORK_BIN")"

  # コピー
  cp "$SRC_SKILL" "$DEST_SKILL"
  green "インストール: ${DEST_SKILL}"

  cp "$SRC_COMMAND" "$DEST_COMMAND"
  green "インストール: ${DEST_COMMAND}"

  cp "$SRC_CFORK" "$DEST_CFORK"
  green "インストール: ${DEST_CFORK}"

  cp "$SRC_CFORK_BIN" "$DEST_CFORK_BIN"
  chmod +x "$DEST_CFORK_BIN"
  green "インストール: ${DEST_CFORK_BIN}"

  cp "$SRC_GRID_BIN" "$DEST_GRID_BIN"
  chmod +x "$DEST_GRID_BIN"
  green "インストール: ${DEST_GRID_BIN}"

  cp "$SRC_READ_BIN" "$DEST_READ_BIN"
  chmod +x "$DEST_READ_BIN"
  green "インストール: ${DEST_READ_BIN}"

  cp "$SRC_SEND_BIN" "$DEST_SEND_BIN"
  chmod +x "$DEST_SEND_BIN"
  green "インストール: ${DEST_SEND_BIN}"

  cp "$SRC_SEND_KEY_BIN" "$DEST_SEND_KEY_BIN"
  chmod +x "$DEST_SEND_KEY_BIN"
  green "インストール: ${DEST_SEND_KEY_BIN}"

  green "インストール完了。"
}

# メイン
case "${1:-}" in
  --check)
    do_check
    ;;
  --uninstall)
    do_uninstall
    ;;
  --help|-h)
    echo "使い方: bash install.sh [--check|--uninstall|--help]"
    echo ""
    echo "  引数なし    インストール実行"
    echo "  --check     インストール状態の確認"
    echo "  --uninstall アンインストール"
    echo "  --help      このヘルプを表示"
    ;;
  "")
    do_install
    ;;
  *)
    red "不明なオプション: $1"
    echo "使い方: bash install.sh [--check|--uninstall|--help]"
    exit 1
    ;;
esac
