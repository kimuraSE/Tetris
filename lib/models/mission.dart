/// ミッション定義（クリア条件・盤面パラメータ）。
class Mission {
  const Mission({
    required this.id,
    required this.boardWidth,
    required this.boardHeight,
    required this.goalType,
    required this.goalLines,
    required this.bagCount,
    required this.dropIntervalMs,
    required this.initialGarbage,
  });

  final String id;
  final int boardWidth;
  final int boardHeight;

  /// MVP では常に `clearLines`。
  final String goalType;
  final int goalLines;

  /// 7種バッグの周回数。MVP は 1。
  final int bagCount;
  final int dropIntervalMs;

  /// 行優先・上から下。`true` は初期固定ブロック。
  /// 長さは [boardHeight]、各行の長さは [boardWidth]。
  final List<List<bool>> initialGarbage;

  int get totalBagPieces => 7 * bagCount;
}
