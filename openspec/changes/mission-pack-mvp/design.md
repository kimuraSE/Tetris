# Design

## Context

現状は Flutter カウンタ雛形（`lib/main.dart` のみ）で、ゲームロジックも画面分割もない。OpenSpec config は Dart/Flutter・日本語成果物・公式寄り MVVM（View↔ViewModel 1:1、`lib/ui` feature 単位、`lib/data` に Repository）を要求する。要件の動機は proposal.md、振る舞い契約は `mission-rules` / `home-play-navigation` / `play-loop` を参照。

## Goals / Non-Goals

**Goals:**

- Home / Play の2画面と `missionId` 起点のミッション読み込みを、MVVM の依存方向で実装できる構造にする
- 有限バッグ＋`clearLines`（N=4）のルールを、UI から切り離したテスト可能なモデル／エンジン層に置く
- Flame なしで Ticker（または同等の定期更新）＋ CustomPainter／Grid による描画を採用する

**Non-Goals:**

- Flame／ゲームエンジン導入、完全 SRS、スコア／永続化、複数ミッション選択 UI
- オンライン対戦、高度なエフェクトパイプライン
- UseCase 層の必須化（単一 Repository で足りる範囲では ViewModel→Repository 直アクセス）

## Decisions

### 1. アーキテクチャ配置（MVVM）

- `lib/ui/home/` — `HomeView` + `HomeViewModel`（開始→`missionId` でナビ）
- `lib/ui/play/` — `PlayView` + `PlayViewModel`（入力受付、表示状態、クリア／失敗オーバーレイ）
- `lib/data/repositories/` — `MissionRepository`（`missionId` → ミッション定義の SSOT）
- 共有モデル（盤・ピース・ミッション定義）は `lib/` 配下の models（または domain/models）に置く

**代替案:** すべてを単一 `StatefulWidget` に閉じる → 却下（config の層分け・テスト性に反する）。Clean の UseCase 必須化 → 却下（複雑ロジックの Repository 横断が当面ない）。

### 2. ゲームループと描画（no Flame）

- PlayViewModel が `Ticker` または `Timer.periodic` で固定落下間隔を進める
- 盤面描画は `CustomPainter` または単純なセル Grid Widget（どちらでも可。最初は Grid の方がデバッグしやすい場合あり）
- ルール更新（移動・回転・ロック・消去・勝敗）は純 Dart のエンジン／モデル側に集約し、Widget テスト／単体テストから呼び出せるようにする

**代替案:** Flame → 画面2枚・固定タイムステップ程度では導入コストが勝るため不採用（将来エフェクト増で再検討可）。

### 3. ミッション定義の渡し方

- ナビ引数は **`missionId` のみ**（例: `"m01"`）
- `MissionRepository.get(missionId)` が `goalLines: 4`、`bagCount: 1`、初期ゴミパターン ID、`dropIntervalMs` などを返す
- 初期ゴミの**具体セル座標**は Repository／定数内の1パターンとして実装時に定義（specs は「1セル以上の初期固定ブロック」まで）

**代替案:** Play に巨大な grid を丸ごと渡す → 却下（契約が太く、再挑戦時の再取得と二重管理になりやすい）。

### 4. 回転

- MVP は基本4向き＋簡易壁キック。完全 SRS テーブルは持たない

### 5. 操作 UI

- 左右・回転・ソフト／ハードは、画面下部のボタン群を既定とする（ジェスチャは任意の後続）。ルールは入力イベント抽象に依存させ、UI 差し替え可能にする

### 6. ポーズ / seed

- ポーズは任意（簡易で可）。バッグシャッフルの `seed` 固定は任意（未指定なら都度乱数）

## Risks / Trade-offs

- [軽ゴミ＋7ピースで goalLines=4 が難しすぎ／簡単すぎ] → パターンと `dropIntervalMs` を tasks 内で調整。ルール定数は Repository に集約し差し替えやすくする
- [簡易回転で壁際ストレス] → 最低限のキックを入れ、完全 SRS は Non-Goals のまま
- [Ticker と生命周期] → ViewModel dispose で停止。オーバーレイ表示中はループ停止
- [描画性能] → 10×20 は Grid で十分。問題が出たら CustomPainter へ寄せる

## Migration Plan

- 既存カウンタ UI を削除し、`MaterialApp` の home を Home 画面に差し替える（破壊的だが未リリース雛形のためロールバックは git revert）
- 段階: モデル／Repository → Play ループ（ヘッドレス検証）→ Home/Play UI → オーバーレイ

## Open Questions

- 初期ゴミの具体セル配置（実装時に1パターン決定）
- `dropIntervalMs` の最終値（例 900。プレイ感で調整）
- ポーズ UI を初回に含めるか（任意）
