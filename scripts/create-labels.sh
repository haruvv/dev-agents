#!/usr/bin/env bash
# dev-agents リポジトリに必要な全ラベルを作成するスクリプト
# 設計書 §3（ラベル設計）に基づく
#
# Usage: ./scripts/create-labels.sh [--repo OWNER/REPO]
#
# 既存ラベルはスキップする（--force で上書き）

set -euo pipefail

REPO="${REPO:-}"
FORCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --repo) REPO="$2"; shift 2 ;;
    --force) FORCE=true; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

REPO_FLAG=""
if [[ -n "$REPO" ]]; then
  REPO_FLAG="--repo $REPO"
fi

create_label() {
  local name="$1"
  local color="$2"
  local description="$3"

  if $FORCE; then
    gh label create "$name" --color "$color" --description "$description" $REPO_FLAG --force
  else
    local output
    if output=$(gh label create "$name" --color "$color" --description "$description" $REPO_FLAG 2>&1); then
      : # 作成成功
    elif echo "$output" | grep -qi "already exists"; then
      echo "  skip: '$name' already exists"
    else
      echo "ERROR: failed to create label '$name': $output" >&2
      exit 1
    fi
  fi
}

echo "=== Issue ラベル（§3.1）==="

# トリガーラベル（人間が付与）
create_label "要件定義作成"  "0075ca" "要件定義エージェントのトリガー"
create_label "詳細設計作成"  "0052cc" "設計エージェントのトリガー"
create_label "タスク分割"    "006b75" "タスク分割エージェントのトリガー"
create_label "ready-for-impl" "28a745" "実装エージェントのトリガー"

# 実行中ラベル（各エージェントが付与）
create_label "in-requirements" "bfd4f2" "要件定義エージェント実行中"
create_label "in-design"       "c2e0c6" "設計エージェント実行中"
create_label "in-task-split"   "c5def5" "タスク分割エージェント実行中"
create_label "in-impl"         "d4edda" "実装エージェント実行中（Issue に付与）"

# 待機・エラーラベル
create_label "waiting-for-answer" "e4e669" "要件定義エージェントが人間の回答待ち"
create_label "blocked"            "d73a4a" "自動処理停止・要人間対応"
create_label "needs-human"        "b60205" "自動回復不可・人間介入必要"

echo ""
echo "=== PR ラベル（§3.2）==="

create_label "ai-generated"    "1d76db" "エージェントが生成した PR"
create_label "ready-for-review" "0e8a16" "レビューエージェントのトリガー"
create_label "in-review"        "c5def5" "レビューエージェント実行中"
create_label "needs-fix"        "e4e669" "差し戻しトリガー。実装エージェントを同一 PR ブランチで再起動する"
create_label "review-passed"    "28a745" "レビュー承認済み"
create_label "ready-to-merge"   "0e8a16" "統合条件をすべて満たした"
create_label "auto-merge"       "6f42c1" "自動マージを明示的に許可"
# blocked は §3.1 で作成済み

echo ""
echo "Done."
