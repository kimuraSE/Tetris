# Proposal

## Why

Flutter のカウンタ雛形しかない状態で、テトリスのクローンではなく「ミッションパック」（有限バッグ＋目標達成）というカジュアル短セッションのアレンジを、Home / Play の2画面だけで遊べる MVP として立ち上げる必要がある。探索で方向・ルール・技術前提が確定したため、実装に進める計画成果物を定義する。

## What Changes

- カウンタ Demo を、**ミッションパック MVP** のアプリ構成に置き換える
- **Home**（開始ボタン）と **Play**（1ミッションのゲームプレイ）の2画面を追加する
- ゲームルール: 盤面 10×20、標準7種、バッグ1周（7ピース）、ホールドなし、Next 1、ゆっくり固定落下、軽めの初期ゴミ、目標は **累計4ライン消去（`clearLines`）のみ**
- クリア／失敗オーバーレイと「もう一度」／「ホームへ」のリトライ流れを追加する
- Home→Play は実質 **`missionId` のみ** 渡し、ミッション定義は Repository／定数から読む
- アーキテクチャは Flutter 公式寄り **MVVM**（View / ViewModel / Repository）。ゲームループは Ticker／タイマー、描画は CustomPainter または Grid Widget（**Flame なし**）
- スコア設計・永続化・複数ミッション選択・完全 SRS・オンライン等は **含めない**

## Capabilities

### New Capabilities

- `mission-rules`: 有限バッグ、`clearLines` / `goalLines=4`、勝敗条件、軽ゴミ前提のミッション定義
- `home-play-navigation`: Home↔Play 遷移、`missionId` 渡し、Clear／Fail オーバーレイと再挑戦／Home 戻る
- `play-loop`: 落下・入力・ロック・ライン消去・スポーン／失敗判定を含むプレイ中のループ

### Modified Capabilities

- （なし — 既存 `openspec/specs/` は空）

## Impact

- 影響コード: `lib/main.dart`（雛形削除・アプリ起動差し替え）、新規 `lib/ui/`（home / play）、`lib/data/`（mission repository）、共有モデル
- 依存: 追加パッケージは原則不要（Flame 不採用）。既存 `flutter` / `cupertino_icons` のまま実装可能
- テスト: ルール判定・バッグ・勝敗のユニットテスト、画面遷移の Widget テストを想定
- 非影響: ネイティブ設定の大改修、バックエンド、永続ストレージ
