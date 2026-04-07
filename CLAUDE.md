# CLAUDE.md — dev-agents AI Worker 設定

このリポジトリ（`haruvv/dev-agents`）で動作する AI Worker 向けの設定ファイル。
Worker は GitHub Issue を受け取り、要件整理・設計・実装・修正を自律的に行う。

## パイプライン概要

```
GitHub Issue (labeled)
  → Worker ECS (Claude Code)
    → 要件定義 / 設計 / タスク分割 / 実装 / repair
      → PR 作成 → CI → レビュー
```

詳細は `AGENTS.md` を参照。

## エージェント

複雑なタスクには以下のサブエージェントを積極的に活用すること。

| エージェント | 用途 | 起動タイミング |
|---|---|---|
| `planner` | 実装計画の策定 | 実装着手前に必ず呼ぶ |
| `architect` | アーキテクチャ判断 | 設計の判断が必要なとき |
| `code-reviewer` | コードレビュー | コミット前に必ず呼ぶ |
| `security-reviewer` | セキュリティチェック | 認証・外部API・DB操作を含む実装時 |
| `code-explorer` | コードベース探索 | 既存コードを把握する必要があるとき |
| `doc-updater` | ドキュメント更新 | 実装変更後 |

エージェント定義: `.claude/agents/`

## スキル

以下のスキルが利用可能。必要に応じて参照すること。

| スキル | 内容 |
|---|---|
| `coding-standards` | コーディング規約・命名・品質基準 |
| `api-design` | REST API 設計パターン |
| `backend-patterns` | バックエンド設計パターン |
| `frontend-patterns` | フロントエンド設計パターン |
| `python-patterns` | Python ベストプラクティス |
| `python-testing` | Python テストパターン |
| `tdd-workflow` | TDD ワークフロー（Red-Green-Refactor） |
| `verification-loop` | 実装検証ループ |
| `plankton-code-quality` | コード品質チェック |
| `e2e-testing` | E2E テスト |

スキル定義: `.claude/skills/`

## 実装ルール

1. **実装前に必ず `planner` エージェントで計画を立てる**
2. **アプリコードは `apps/<app-name>/` 配下に配置する**（英小文字・ハイフン区切り）
3. **コミット前に `code-reviewer` エージェントでレビューを通す**
4. `docs/constraints.md` のアーキテクチャ制約を必ず遵守する
5. ドキュメント（`docs/`）への実装コード配置は禁止

## ディレクトリ構造

```
dev-agents/
├── apps/              ← 実装するアプリはここに配置
│   └── <app-name>/
├── docs/              ← 要件定義書・設計書（実装コード禁止）
├── .claude/
│   ├── agents/        ← ECC エージェント定義
│   ├── skills/        ← ECC スキル定義
│   └── rules/         ← ECC 共通ルール
├── CLAUDE.md          ← 本ファイル
└── AGENTS.md          ← パイプライン詳細案内
```

## CI

- PR 作成時に actionlint が実行される
- CI 失敗時は Orchestrator が自動で repair ジョブを投入する（最大3回）
