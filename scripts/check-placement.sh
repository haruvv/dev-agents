#!/usr/bin/env bash
# check-placement.sh — ファイル配置ルールの検証
#
# 役割: コード・設定・設計情報が正しいディレクトリに配置されているかを確認する。
# src/ が空の場合は配置違反が存在しないためスキップする。
#
# 違反時: 違反ファイルを出力して exit 1 する。

set -euo pipefail

VIOLATIONS=0

echo "=== ファイル配置ルールチェック ==="

# src/ にファイルがなければスキップ
SRC_FILES=$(find src/ -type f 2>/dev/null | wc -l)
if [ "$SRC_FILES" -eq 0 ]; then
  echo "src/ にファイルが存在しません。配置ルールチェックをスキップします。"
  exit 0
fi

# ---- ルール1: ワークフロー定義は .github/workflows/ のみに置く ----
# 拡張子だけでなく GitHub Actions 固有のキー（on: + jobs:）を両方含むファイルを検出する。
# これにより OpenAPI spec や Kubernetes マニフェスト等の正当な YAML を誤検知しない。
MISPLACED_WORKFLOWS=""
while IFS= read -r -d '' FILE; do
  if grep -q "^on:" "$FILE" 2>/dev/null && grep -q "^jobs:" "$FILE" 2>/dev/null; then
    MISPLACED_WORKFLOWS="${MISPLACED_WORKFLOWS}${FILE}"$'\n'
  fi
done < <(find src/ scripts/ \( -name "*.yml" -o -name "*.yaml" \) -print0 2>/dev/null)

if [ -n "$MISPLACED_WORKFLOWS" ]; then
  echo "[FAIL] GitHub Actions ワークフロー定義が .github/workflows/ 以外に存在します:"
  echo "$MISPLACED_WORKFLOWS"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "[PASS] ワークフロー定義の配置: OK"
fi

# ---- ルール2: エージェント定義は .claude/agents/ のみに置く ----
MISPLACED_AGENTS=$(find src/ -name "*.md" 2>/dev/null | xargs grep -l "エージェント定義\|agent definition" 2>/dev/null || true)
if [ -n "$MISPLACED_AGENTS" ]; then
  echo "[FAIL] エージェント定義ファイルが src/ に存在します (.claude/agents/ に移動してください):"
  echo "$MISPLACED_AGENTS"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "[PASS] エージェント定義の配置: OK"
fi

# ---- ルール3: 設計書・要件定義は docs/ のみに置く ----
# src/ 配下に *-design.md や *-requirements.md が置かれていないか
MISPLACED_DOCS=$(find src/ -name "*-design.md" -o -name "*-requirements.md" 2>/dev/null || true)
if [ -n "$MISPLACED_DOCS" ]; then
  echo "[FAIL] 設計書・要件定義が src/ に存在します (docs/ に移動してください):"
  echo "$MISPLACED_DOCS"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "[PASS] 設計書・要件定義の配置: OK"
fi

# ---- ルール4: シークレット・認証情報のハードコード禁止 ----
# よくあるパターンを grep で検出（false positive を減らすため厳密な境界を使用）
SECRET_PATTERNS=(
  'password\s*=\s*"[^"]+'
  'secret\s*=\s*"[^"]+'
  'api_key\s*=\s*"[^"]+'
  'token\s*=\s*"[^"]+'
  'AKIA[0-9A-Z]{16}'
)

FOUND_SECRETS=0
for PATTERN in "${SECRET_PATTERNS[@]}"; do
  MATCHES=$(grep -rniE "$PATTERN" src/ 2>/dev/null | grep -v "_test\.\|test_\|example\|placeholder\|dummy\|TODO" || true)
  if [ -n "$MATCHES" ]; then
    echo "[FAIL] シークレット・認証情報のハードコードが疑われます (パターン: $PATTERN):"
    echo "$MATCHES"
    FOUND_SECRETS=1
  fi
done

if [ "$FOUND_SECRETS" -eq 0 ]; then
  echo "[PASS] シークレット・認証情報のハードコード: 検出なし"
else
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# ---- 結果 ----
echo ""
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "配置ルールチェック: ${VIOLATIONS} 件の違反が見つかりました。"
  exit 1
else
  echo "配置ルールチェック: すべてのルールを満たしています。"
fi
