# AGENTS.md — AI Worker 向け案内文書

本ファイルは、このリポジトリで動作する AI Worker が作業開始時に参照する入口文書である。
詳細仕様はここに書かず、参照先を示すことに徹する。

---

## このリポジトリについて

<!-- リポジトリの目的・概要を1〜3行で記述する -->

---

## 主要参照先

| ドキュメント | 内容 |
|---|---|
| `docs/<issue-number>-requirements.md` | 要件定義書（requirements Worker が生成） |
| `docs/<issue-number>-design.md` | 設計書（design Worker が生成） |
| `docs/requirements-template.md` | 要件定義書のフォーマット定義 |
| `docs/design-template.md` | 設計書のフォーマット定義 |
| `AGENTS.md`（本ファイル） | Worker 向け案内（入口） |

---

## アーキテクチャ制約

<!-- このリポジトリ固有の制約・禁止事項を記述する -->
<!-- Worker はここに記載された制約を実装時に必ず遵守すること -->

- 

<!-- 例:
- レイヤー逆流の禁止（infrastructure → domain への直接参照不可）
- ドメイン外への直接 DB アクセス禁止
- 環境変数は必ず設定ファイル経由で参照すること
-->

---

## Issue・PR の運用ルール

- Issue は `haruvv/agent-intake` の Discord Bot 経由で起票される
- 子 Issue 本文の1行目は `parent_issue: <番号>` 形式で親 Issue 番号を記載すること
- ブランチ命名規則：`impl/issue-<番号>-<slug>`
- PR 本文には関連 Issue 番号・変更概要・主要な設計判断を記載すること

---

## ラベル一覧

パイプラインで使用するラベルの定義。詳細は `haruvv/dev-agents` の `labels.yml` を参照。

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

<!-- このリポジトリの CI 内容を記述する（テンプレート初期値） -->
- PR 作成時および main push 時に actionlint による構文チェックが実行される
- CI 失敗時は `haruvv/agent-intake` の Orchestrator が repair ジョブを自動投入する（最大3回）
- repair 上限到達時は `needs-human` ラベルが付与され、自動処理が停止する

---

## Garbage Collection

定期的に以下を確認し、陳腐化・不整合を解消すること。

- `docs/` 内の古い設計書・要件定義書（クローズ済み Issue に対応するもの）
- `blocked` / `needs-human` 状態のまま放置された Issue
- 未マージのまま長期間放置された `ai-generated` PR
- このリポジトリ固有の制約（アーキテクチャ制約セクション）の鮮度
