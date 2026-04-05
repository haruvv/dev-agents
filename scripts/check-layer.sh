#!/usr/bin/env bash
# check-layer.sh — レイヤ逆流チェック
#
# 役割: 上位レイヤが下位レイヤに依存する逆流を検出する。
# src/ が空の場合はスキップする。
#
# 【カスタマイズ方法】
# src/ にコードを追加したら、以下の LAYER_DEPS 配列を実際のアーキテクチャに合わせて設定すること。
#
# 例（レイヤ構成: domain > usecase > interface > infrastructure）:
#   domain は usecase/interface/infrastructure を import してはならない
#   usecase は interface/infrastructure を import してはならない
#   interface は infrastructure を import してはならない（infrastructure は最下位）
#
# 設定形式: "上位レイヤのパス:禁止される下位レイヤのパス"
# LAYER_DEPS=(
#   "src/domain:src/usecase"
#   "src/domain:src/interface"
#   "src/domain:src/infrastructure"
#   "src/usecase:src/interface"
#   "src/usecase:src/infrastructure"
# )

set -euo pipefail

VIOLATIONS=0

echo "=== レイヤ逆流チェック ==="

# src/ にファイルがなければスキップ
SRC_FILES=$(find src/ -type f 2>/dev/null | wc -l)
if [ "$SRC_FILES" -eq 0 ]; then
  echo "src/ にファイルが存在しません。レイヤ逆流チェックをスキップします。"
  exit 0
fi

# ---- TODO: 以下を実際のレイヤ構成に合わせて設定する ----
# 現時点では src/ の構成が未定のためチェックルールを定義していない。
# src/ にコードを追加したタイミングで以下の配列を埋めること。
LAYER_DEPS=()
# 例:
# LAYER_DEPS=(
#   "src/domain:src/usecase"
#   "src/domain:src/interface"
# )
# -------------------------------------------------------

if [ "${#LAYER_DEPS[@]}" -eq 0 ]; then
  echo "レイヤ依存ルールが未定義です。src/ の構造が決まったら scripts/check-layer.sh を設定してください。"
  exit 0
fi

for RULE in "${LAYER_DEPS[@]}"; do
  UPPER="${RULE%%:*}"
  FORBIDDEN="${RULE##*:}"
  FORBIDDEN_BASENAME=$(basename "$FORBIDDEN")

  if [ ! -d "$UPPER" ]; then
    continue
  fi

  # import/require/from で禁止レイヤへの参照を検出
  MATCHES=$(grep -rn "from ['\"].*${FORBIDDEN_BASENAME}\|require.*${FORBIDDEN_BASENAME}\|import.*${FORBIDDEN_BASENAME}" "$UPPER/" 2>/dev/null || true)
  if [ -n "$MATCHES" ]; then
    echo "[FAIL] レイヤ逆流: $UPPER → $FORBIDDEN への依存が禁止されています:"
    echo "$MATCHES"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "[PASS] $UPPER → $FORBIDDEN: 逆流なし"
  fi
done

echo ""
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "レイヤ逆流チェック: ${VIOLATIONS} 件の違反が見つかりました。"
  exit 1
else
  echo "レイヤ逆流チェック: すべてのルールを満たしています。"
fi
