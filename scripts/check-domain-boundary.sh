#!/usr/bin/env bash
# check-domain-boundary.sh — ドメイン外直接参照チェック
#
# 役割: あるドメインが別ドメインの内部実装を直接参照していないかを検出する。
# ドメイン間の参照は共有インターフェース / 公開 API を通じてのみ許可する。
# src/ が空の場合はスキップする。
#
# 【カスタマイズ方法】
# src/ にコードを追加したら、以下の DOMAIN_BOUNDARIES 配列を実際のドメイン構成に合わせて設定すること。
#
# 例（ドメイン: user / order / payment が存在する場合）:
#   user ドメインは order/payment ドメインの内部 (internal/) を直接参照してはならない
#   公開 API (api/, types.ts, index.ts) 経由の参照のみ許可
#
# 設定形式: "参照元ドメインのパス:禁止される参照先の内部パス"
# DOMAIN_BOUNDARIES=(
#   "src/user:src/order/internal"
#   "src/user:src/payment/internal"
#   "src/order:src/user/internal"
# )

set -euo pipefail

VIOLATIONS=0

echo "=== ドメイン外直接参照チェック ==="

# src/ にファイルがなければスキップ
SRC_FILES=$(find src/ -type f 2>/dev/null | wc -l)
if [ "$SRC_FILES" -eq 0 ]; then
  echo "src/ にファイルが存在しません。ドメイン境界チェックをスキップします。"
  exit 0
fi

# ---- TODO: 以下を実際のドメイン構成に合わせて設定する ----
DOMAIN_BOUNDARIES=()
# 例:
# DOMAIN_BOUNDARIES=(
#   "src/user:src/order/internal"
#   "src/user:src/payment/internal"
# )
# -------------------------------------------------------

if [ "${#DOMAIN_BOUNDARIES[@]}" -eq 0 ]; then
  echo "ドメイン境界ルールが未定義です。src/ の構造が決まったら scripts/check-domain-boundary.sh を設定してください。"
  exit 0
fi

for RULE in "${DOMAIN_BOUNDARIES[@]}"; do
  FROM_DOMAIN="${RULE%%:*}"
  FORBIDDEN_PATH="${RULE##*:}"
  FORBIDDEN_BASENAME=$(basename "$FORBIDDEN_PATH")

  if [ ! -d "$FROM_DOMAIN" ]; then
    continue
  fi

  MATCHES=$(grep -rn "from ['\"].*${FORBIDDEN_BASENAME}\|require.*${FORBIDDEN_BASENAME}" "$FROM_DOMAIN/" 2>/dev/null || true)
  if [ -n "$MATCHES" ]; then
    echo "[FAIL] ドメイン外直接参照: $FROM_DOMAIN から $FORBIDDEN_PATH への直接参照が禁止されています:"
    echo "$MATCHES"
    VIOLATIONS=$((VIOLATIONS + 1))
  else
    echo "[PASS] $FROM_DOMAIN → $FORBIDDEN_PATH: 直接参照なし"
  fi
done

echo ""
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "ドメイン境界チェック: ${VIOLATIONS} 件の違反が見つかりました。"
  exit 1
else
  echo "ドメイン境界チェック: すべてのルールを満たしています。"
fi
