# 設計書：ボタンを押すと「GO!」と表示される React Web アプリの作成

## 目的・背景

学習・デモ目的のシンプルな React インタラクティブ UI として、ボタンクリック時に「GO!」テキストを表示する機能を実装する。状態管理・イベントハンドリングの基本パターンを示す最小構成のアプリ。

## 実装方針

- **技術スタック**: React（追加ライブラリなし）、Create React App または Vite による雛形
- **状態管理**: `useState` フックで表示フラグ（`boolean`）を管理
- **コンポーネント構成**: `App` コンポーネント単体で完結（分割不要）
- **表示制御**: `showMessage` が `true` のときのみ `<p>GO!</p>` をレンダリング（条件付きレンダリング）
- **配置先**: `src/` 配下に実装コードを配置

```
src/
├── App.jsx       ← メインコンポーネント（useState・ボタン・GO!表示）
├── main.jsx      ← エントリーポイント
└── index.css     ← 最小限のスタイル（任意）
```

**App.jsx 概略:**

```jsx
import { useState } from 'react';

export default function App() {
  const [showMessage, setShowMessage] = useState(false);

  return (
    <div>
      <button onClick={() => setShowMessage(true)}>ボタン</button>
      {showMessage && <p>GO!</p>}
    </div>
  );
}
```

## 制約条件

- `src/` 配下にのみ実装コードを配置する（設計書・要件定義書の配置禁止）
- バックエンド連携・認証機能は実装しない
- React 以外の追加ライブラリ（状態管理ライブラリ等）は導入しない
- 過度な抽象化・コンポーネント分割は行わない

## 作業分割方針（タスク分割 Worker への指示）

本機能はシンプルな単一コンポーネント実装であるため、1 PR で完結できる。

### タスク一覧

| # | タスク概要 | 依存 |
|---|-----------|------|
| 1 | React プロジェクトの初期セットアップ（Vite + React） | なし |
| 2 | `App.jsx` に `useState` を用いたボタン・GO! 表示を実装 | #1 |

## 検証方法

- [ ] ページ初期表示時に「GO!」テキストが表示されていないこと
- [ ] ボタンをクリックすると「GO!」テキストが表示されること
- [ ] `npm run build` がエラーなく完了すること
- [ ] `npm run dev`（または `npm start`）でローカル起動できること