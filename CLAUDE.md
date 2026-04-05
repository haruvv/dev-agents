# dev-agents — エージェント向けリポジトリ地図

AIエージェントチームが自律的に開発を行うための **1リポジトリ完結型パイプライン**。
人間が Issue を起票すると、エージェントが要件整理・設計・実装・レビュー・統合まで自律的に進行する。

---

## リポジトリ地図

```
dev-agents/
├── .github/
│   ├── workflows/        # パイプラインを動かす GitHub Actions ワークフロー群
│   ├── ISSUE_TEMPLATE/   # Issue 起票テンプレート
│   └── pull_request_template.md
├── .claude/
│   ├── agents/           # 各エージェントの振る舞い定義（詳細はこちらを参照）
│   └── common-rules.md   # 全エージェント共通ルール（blocked チェック・ラベル遷移・失敗処理）
├── docs/                 # 真実の源泉（要件・設計・意思決定ログ・実行計画）
│   ├── decisions/        # 意思決定ログ
│   ├── plans/            # 実行計画
│   └── README.md         # docs/ の構造・フォーマット定義
├── scripts/              # CI・セットアップ用スクリプト
└── src/                  # 開発対象の実装コード
```

**詳細な参照先：**
- エージェント共通ルール → `.claude/common-rules.md`
- 各エージェントの振る舞い → `.claude/agents/<エージェント名>.md`
- ドキュメントのフォーマット・構造 → `docs/README.md`

---

## パイプライン概要

Issue のラベルがバトンとなり、エージェントが順番に起動する。

```
人間が Issue 起票
  → 要件定義作成ラベル   → 要件定義エージェント  (claude-requirements.yml)
  → 詳細設計作成ラベル   → 設計エージェント      (claude-design.yml)
  → タスク分割ラベル     → タスク分割エージェント (claude-task-split.yml)  ← 子 Issue を起票
  → ready-for-impl ラベル → 実装エージェント      (claude-impl.yml)         ← PR 作成
  → ready-for-review ラベル → レビューエージェント  (claude-review.yml)
  → review-passed ラベル  → 統合判定エージェント  (claude-merge-check.yml)
```

停滞した場合は監視エージェント（`stale-monitor.yml`、2時間ごと定期実行）が自動回復する。

---

## 黄金原則

1. **`docs/` が真実の源泉** — 要件・設計・判断根拠はすべて `docs/` に記録する。記録のない設計判断は存在しないものとして扱う
2. **`blocked` を正直に使う** — 失敗・依存未解決・判断できない場合は必ず `blocked` ラベルを付けて人間に委ねる。曖昧なまま進めない
3. **CI が制約を強制する** — アーキテクチャ上の禁止事項はコメントや規約文書ではなく CI で機械的に強制する
4. **最小の変更で前進する** — 大きな変更より小さな変更を繰り返す。1 Issue = 1 PR を原則とする

---

## コーディング規約

### コミットメッセージ

```
<type>: <変更内容の要約>
```

| type | 用途 |
|------|------|
| `feat` | 新機能・初回実装 |
| `fix` | バグ修正・差し戻し修正 |
| `docs` | ドキュメント更新 |
| `refactor` | リファクタリング |
| `test` | テスト追加・修正 |
| `chore` | ビルド・設定変更 |

### ファイル命名規則

| 種別 | 命名パターン | 例 |
|------|------------|-----|
| ワークフロー | `claude-<役割>.yml` | `claude-impl.yml` |
| エージェント定義 | `<役割>.md` | `impl.md` |
| 設計書 | `<issue番号>-design.md` | `42-design.md` |
| 意思決定ログ | `YYYY-MM-DD-<トピック>.md` | `2026-04-05-auth-design.md` |
| 実行計画 | `<issue番号>-<タイトル>.md` | `42-user-auth.md` |

### 禁止事項

- シークレット・認証情報をコードにハードコードすること
- `docs/` への記録なしに設計判断を行うこと
- `blocked` ラベルを無視した処理の続行

---

## コードパターン

### 意思決定ログの記録

重要な設計判断・変更が発生したら必ず `docs/decisions/YYYY-MM-DD-<トピック>.md` に記録する。
詳細フォーマット → `docs/README.md`

### 技術スタック固有のパターン

開発対象の技術スタックは人間の Issue 指示によって決定する。
スタックが決まったら以下を整備すること：

- `scripts/check-layer.sh` — レイヤ依存ルール（`LAYER_DEPS` 配列）
- `scripts/check-domain-boundary.sh` — ドメイン境界ルール（`DOMAIN_BOUNDARIES` 配列）
- `scripts/check-boundary-validation.sh` — 境界検証ルール（`BOUNDARY_DIRS` 等）
- `.github/workflows/ci.yml` — lint / test / build ジョブ（現在 TODO コメント）

---

## エージェントへの注意事項

作業開始前に必ず `.claude/common-rules.md` を確認すること。
`blocked` チェック・ラベル遷移ルール・失敗時処理の詳細はすべてそこに定義されている。
