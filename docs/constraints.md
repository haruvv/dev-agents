# アーキテクチャ制約

本ファイルはこのリポジトリ全体に適用される制約を定義する。
Worker は実装時にここに記載された制約を必ず遵守すること。

---

## ディレクトリ構造ルール

```
dev-agents/
├── AGENTS.md          ← 更新可。Worker 向け地図
├── docs/              ← 更新可。永続知識（アーキテクチャ制約・運用知見のみ）
├── apps/              ← 更新可。実装コード（implement Worker が書く場所）
│   └── <app-name>/   ← アプリごとのサブディレクトリ（英小文字ハイフン区切り）
├── .github/workflows/ ← 更新可（CI・トリガー変更時のみ）
├── labels.yml         ← パイプライン仕様変更時のみ更新（人間がキュレーション）
└── scripts/           ← 手動運用スクリプト。Worker は原則触らない
```

## 禁止事項

- `docs/` 配下への実装コードの配置禁止
- `apps/` 以外（`src/`・ルートなど）への実装コードの配置禁止
- `labels.yml` の Worker による自動更新禁止
- `AGENTS.md` の Worker による自動上書き禁止
- `docs/constraints.md` の Worker による自動更新禁止
- Issue 固有の要件定義書・設計書を `docs/` ファイルとして作成すること禁止
  （代わりに Issue コメントに投稿する）

## アプリ実装コードの配置ルール

- 実装コードはすべて `apps/<アプリ名>/` 配下に置く
- アプリ名は英小文字・ハイフン区切り（例: `apps/go-button-app/`）
- ルートや `src/` への配置は禁止

## Worker 間ハンドオフ（コメント方式）

要件定義書・設計書は Issue コメントとして投稿する。`docs/` ファイルは使用しない。

| アーティファクト | Issue コメント冒頭マーカー | 生成主体 |
|---|---|---|
| 要件定義書 | `<!-- requirements-doc -->` | requirements Worker |
| 設計書 | `<!-- design-doc -->` | design Worker |

## docs/ に置くもの（永続知識のみ）

| ファイル | 命名規則 | 生成主体 |
|---|---|---|
| アーキテクチャ制約 | `docs/constraints.md`（本ファイル） | 人間 |
| 運用知見 | `docs/pipeline-learnings.md` | 人間（GC Worker が補助） |

## ブランチ・PR ルール

- 実装ブランチ：`impl/issue-<番号>-<slug>`
- docs の直接コミットは `main` ブランチへ（requirements / design / task-split Worker）
- コード実装は必ずブランチを切り PR を作成（implement Worker）
- PR 本文には関連 Issue 番号・変更概要・主要な設計判断を記載すること
