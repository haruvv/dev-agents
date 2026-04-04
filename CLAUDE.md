# dev-agents — エージェント向けリポジトリ地図

このリポジトリは、AIエージェントチームが自律的に開発を行うための **1リポジトリ完結型パイプライン** だ。
ワークフロー定義・エージェント定義・実装コード・設計ドキュメントのすべてをここで管理する。

---

## リポジトリ構成

```
dev-agents/
├── .github/
│   ├── ISSUE_TEMPLATE/       # Issue テンプレート
│   ├── workflows/            # GitHub Actions ワークフロー
│   └── pull_request_template.md
├── .claude/
│   └── agents/               # エージェント定義（Markdown）
├── docs/                     # 設計書・要件定義（真実の源泉）
├── scripts/                  # セットアップスクリプト
└── src/                      # 実装コード（将来）
```

---

## フェーズとラベルのバトンリレー

| ラベル | トリガーするワークフロー | 完了後に付与するラベル |
|--------|------------------------|----------------------|
| `要件定義作成` | claude-requirements.yml | `詳細設計作成` |
| `詳細設計作成` | claude-detailed-design.yml | `タスク分割` |
| `タスク分割` | claude-task-split.yml | `ready-for-impl`（各サブIssue） |
| `ready-for-impl` | claude-impl.yml | `ready-for-review` |
| `ready-for-review` | claude-auto-review.yml | `review-passed` |
| `review-passed` | claude-auto-merge.yml | —（マージ・クローズ） |

---

## ラベル一覧

| ラベル | 意味 |
|--------|------|
| `要件定義作成` | 要件定義エージェントのトリガー |
| `詳細設計作成` | 詳細設計エージェントのトリガー |
| `タスク分割` | タスク分割エージェントのトリガー |
| `ready-for-impl` | 実装エージェントのトリガー |
| `in-progress` | エージェント実行中 |
| `blocked` | 失敗または依存 Issue 未解決。人間の確認が必要 |
| `ai-generated` | エージェント生成物の識別 |
| `ready-for-review` | レビュー待ち |
| `review-passed` | レビュー完了（自動マージのゲート） |

---

## 黄金原則

1. **`docs/` が真実の源泉** — 要件・設計・判断根拠はすべて `docs/` に記録する。外部サービスやSlackは「存在しないもの」として扱う
2. **`blocked` を正直に使う** — 失敗・依存未解決・判断できない場合は必ず `blocked` ラベルを付けて人間に委ねる
3. **CIが制約を強制する** — アーキテクチャ上の禁止事項はコメントではなくCIで機械的に強制する

## 禁止事項

- `docs/` への記録なしに設計判断を行うこと
- `blocked` ラベルを無視した実装の続行
- シークレット・認証情報のコードへの埋め込み
