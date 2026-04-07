# AGENTS.md — AI Worker 向け案内文書

本ファイルは、このリポジトリで動作する AI Worker が作業開始時に参照する入口文書である。
詳細仕様はここに書かず、参照先を示すことに徹する。

---

## このリポジトリについて

このリポジトリ（`haruvv/dev-agents`）は、AI 自律開発パイプラインの実行現場かつナレッジベース。
Worker はここに Issue 起票された要求を受け取り、要件整理・設計・実装・修正を行う。
蓄積された docs/ がパイプライン自体の記録システムとして機能する。

---

## 主要参照先

| ドキュメント | 内容 |
|---|---|
| Issue コメント `<!-- requirements-doc -->` | 要件定義書（requirements Worker が Issue コメントに投稿） |
| Issue コメント `<!-- design-doc -->` | 設計書（design Worker が Issue コメントに投稿） |
| `docs/constraints.md` | アーキテクチャ制約・禁止事項 |
| `docs/pipeline-learnings.md` | パイプライン運用で得た知見の蓄積 |
| `AGENTS.md`（本ファイル） | Worker 向け案内（入口） |

### Worker 間ハンドオフ

要件定義書・設計書は `docs/` ファイルではなく、**Issue コメントに投稿**する。
後続 Worker はコメント一覧から `body.startsWith("<!-- {marker} -->")` のコメントを探す。

---

## アーキテクチャ制約

詳細は `docs/constraints.md` を参照。Worker は実装前に必ず確認すること。

---

## Issue・PR の運用ルール

- Issue は `haruvv/agent-intake` の Discord Bot 経由で起票される
- 子 Issue 本文の1行目は `parent_issue: <番号>` 形式で親 Issue 番号を記載すること
- ブランチ命名規則：`impl/issue-<番号>-<slug>`
- PR 本文には関連 Issue 番号・変更概要・主要な設計判断を記載すること

---

## ラベル一覧

パイプラインで使用するラベルの定義。詳細は `labels.yml` を参照。

### Issue ラベル（ステート遷移）

| ラベル | 意味 | 付与主体 |
|---|---|---|
| `要件定義作成` | 要件定義ジョブのトリガー | 人間 / processor |
| `in-requirements` | 要件定義 Worker 実行中 | Worker |
| `waiting-for-answer` | 人間の回答待ち | Worker |
| `詳細設計作成` | 設計ジョブのトリガー | Worker |
| `in-design` | 設計 Worker 実行中 | Worker |
| `タスク分割` | タスク分割ジョブのトリガー | Worker |
| `in-task-split` | タスク分割 Worker 実行中 | Worker |
| `ready-for-impl` | 実装ジョブのトリガー | Worker |
| `in-impl` | 実装 Worker 実行中 | Worker |
| `blocked` | 自動処理停止・要人間対応 | Worker / Orchestrator |
| `needs-human` | 上限超過・人間介入必要 | Orchestrator |

### PR ラベル

| ラベル | 意味 | 付与主体 |
|---|---|---|
| `ai-generated` | Worker が生成した PR | Worker |
| `ready-for-human-review` | 人間レビュー待ち（CI 成功後のみ付与） | Orchestrator |

---

## waiting-for-answer からの再エントリー手順

requirements Worker が曖昧点を検知した場合、Issue に `waiting-for-answer` ラベルが付与される。
人間が回答した後、以下の手順でパイプラインを再開する。

1. Issue から `waiting-for-answer` ラベルを外す
2. `要件定義作成` ラベルを付与する
3. requirements ジョブが自動的に再実行される

---

## CI

- PR 作成時および main push 時に actionlint による構文チェックが実行される
- CI 失敗時は `haruvv/agent-intake` の Orchestrator が repair ジョブを自動投入する（最大3回）
- repair 上限到達時は `needs-human` ラベルが付与され、自動処理が停止する

---

## Garbage Collection

定期的に以下を確認し、陳腐化・不整合を解消すること。

- `docs/` 内の古い設計書・要件定義書（クローズ済み Issue に対応するもの）
- `blocked` / `needs-human` 状態のまま放置された Issue
- 未マージのまま長期間放置された `ai-generated` PR
- `docs/constraints.md` の鮮度（実装との整合性）
- `docs/pipeline-learnings.md` への知見の反映状況
