#!/usr/bin/env bash
# check-boundary-validation.sh — 境界における型・スキーマ検証の必須化チェック
#
# 役割: システム境界（外部入力・APIエンドポイント・ドメイン間インターフェース）で
#       型またはスキーマ検証が行われているかを確認する。
# src/ が空の場合はスキップする。
#
# 【カスタマイズ方法】
# src/ にコードを追加したら、以下の BOUNDARY_PATTERNS を実際の実装に合わせて設定すること。
#
# 例（TypeScript + Zod を使用する場合）:
#   API ルートハンドラには必ず zod の parse/safeParse を含める
#   検証なしの req.body 直接アクセスは禁止
#
# VALIDATION_PATTERNS — 境界で使用が必須なバリデーション関数のパターン
# FORBIDDEN_PATTERNS  — 境界での生の入力アクセスで禁止するパターン
# BOUNDARY_FILES_GLOB — 境界ファイルを特定する glob パターン（例: APIルート）

set -euo pipefail

VIOLATIONS=0

echo "=== 境界型・スキーマ検証チェック ==="

# src/ にファイルがなければスキップ
SRC_FILES=$(find src/ -type f 2>/dev/null | wc -l)
if [ "$SRC_FILES" -eq 0 ]; then
  echo "src/ にファイルが存在しません。境界バリデーションチェックをスキップします。"
  exit 0
fi

# ---- TODO: 以下を実際の実装に合わせて設定する ----
# 境界ファイルのパス（ルートハンドラ・コントローラ等）
BOUNDARY_DIRS=()
# 例: BOUNDARY_DIRS=("src/interface/routes" "src/interface/controllers")

# 境界で必須なバリデーション関数のパターン（いずれか1つ以上含まれていれば OK）
VALIDATION_PATTERNS=()
# 例: VALIDATION_PATTERNS=("\.parse(" "\.safeParse(" "validate(" "schema\.check(")

# 境界での禁止パターン（生の入力への直接アクセス）
FORBIDDEN_RAW_ACCESS=()
# 例: FORBIDDEN_RAW_ACCESS=("req\.body\." "request\.body\." "event\.body\.")
# -------------------------------------------------------

if [ "${#BOUNDARY_DIRS[@]}" -eq 0 ]; then
  echo "境界バリデーションルールが未定義です。src/ の構造が決まったら scripts/check-boundary-validation.sh を設定してください。"
  exit 0
fi

for BOUNDARY_DIR in "${BOUNDARY_DIRS[@]}"; do
  if [ ! -d "$BOUNDARY_DIR" ]; then
    continue
  fi

  # 境界ファイルを列挙
  BOUNDARY_FILES=$(find "$BOUNDARY_DIR" -type f -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" 2>/dev/null)

  for FILE in $BOUNDARY_FILES; do
    HAS_VALIDATION=0

    # バリデーションパターンのいずれかが含まれているかチェック
    for PATTERN in "${VALIDATION_PATTERNS[@]}"; do
      if grep -q "$PATTERN" "$FILE" 2>/dev/null; then
        HAS_VALIDATION=1
        break
      fi
    done

    if [ "$HAS_VALIDATION" -eq 0 ] && [ "${#VALIDATION_PATTERNS[@]}" -gt 0 ]; then
      echo "[FAIL] 境界バリデーション未実装: $FILE にスキーマ検証が見つかりません"
      VIOLATIONS=$((VIOLATIONS + 1))
    fi

    # 禁止パターン（生の入力アクセス）のチェック
    for FORBIDDEN in "${FORBIDDEN_RAW_ACCESS[@]}"; do
      MATCHES=$(grep -n "$FORBIDDEN" "$FILE" 2>/dev/null || true)
      if [ -n "$MATCHES" ]; then
        echo "[FAIL] 生の入力アクセスが禁止されています ($FILE):"
        echo "$MATCHES"
        VIOLATIONS=$((VIOLATIONS + 1))
      fi
    done
  done
done

echo ""
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "境界バリデーションチェック: ${VIOLATIONS} 件の違反が見つかりました。"
  exit 1
else
  echo "境界バリデーションチェック: すべてのルールを満たしています。"
fi
