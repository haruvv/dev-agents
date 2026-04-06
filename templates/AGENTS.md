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
| `docs/<issue-number>-requirements.md` | 要件定義書 |
| `docs/<issue-number>-design.md` | 設計書 |
| `AGENTS.md`（本ファイル） | Worker 向け案内 |

---

## Issue・PR の運用ルール

- Issue は `haruvv/agent-intake` の Discord Bot 経由で起票される
- 子 Issue 本文の1行目は `parent_issue: <番号>` 形式で親 Issue 番号を記載すること
- ブランチ命名規則：`impl/issue-<番号>-<slug>`

---

## ラベル一覧

パイプラインで使用するラベルの定義は `haruvv/dev-agents` の `labels.yml` を参照すること。

| ラベル | 意味 |
|---|---|
| `要件定義作成` | 要件定義ジョブのトリガー |
| `詳細設計作成` | 設計ジョブのトリガー |
| `タスク分割` | タスク分割ジョブのトリガー |
| `ready-for-impl` | 実装ジョブのトリガー |
| `blocked` | 自動処理停止・要人間対応 |
| `needs-human` | 上限超過・人間介入必要 |
| `ai-generated` | Worker が生成した PR |
| `ready-for-human-review` | 人間レビュー待ち（CI 成功後のみ付与） |

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
- CI 失敗時は `haruvv/agent-intake` の Orchestrator が repair ジョブを自動投入する
