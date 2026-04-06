#!/usr/bin/env bash
# bootstrap.sh — 対象 repo に labels.yml のラベルを一括作成する
#
# 使い方:
#   ./scripts/bootstrap.sh <owner/repo>
#
# 依存: gh CLI（認証済み）、yq

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <owner/repo>" >&2
  exit 1
fi

REPO="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABELS_FILE="$SCRIPT_DIR/../labels.yml"

if ! command -v yq &>/dev/null; then
  echo "Error: yq is required. Install with: brew install yq" >&2
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "Error: gh CLI is required. Install with: brew install gh" >&2
  exit 1
fi

count=$(yq '. | length' "$LABELS_FILE")

echo "Creating $count labels in $REPO ..."

for i in $(seq 0 $((count - 1))); do
  name=$(yq ".[$i].name" "$LABELS_FILE")
  color=$(yq ".[$i].color" "$LABELS_FILE")
  description=$(yq ".[$i].description" "$LABELS_FILE")

  if gh label create "$name" \
    --repo "$REPO" \
    --color "$color" \
    --description "$description" \
    --force 2>/dev/null; then
    echo "  ✓ $name"
  else
    echo "  ✗ $name (failed)" >&2
  fi
done

echo "Done."
