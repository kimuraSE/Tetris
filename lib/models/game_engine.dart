import 'dart:math';

import 'package:tetris/models/mission.dart';
import 'package:tetris/models/tetromino.dart';

enum GameStatus { playing, cleared, failed }

/// UI 非依存のミッションパック・ゲームエンジン。
class GameEngine {
  GameEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  late Mission mission;
  late List<List<bool>> board;
  final List<TetrominoType> _bag = [];
  ActivePiece? active;
  TetrominoType? nextType;
  int linesCleared = 0;
  GameStatus status = GameStatus.playing;
  int piecesSpawned = 0;

  void start(Mission mission) {
    this.mission = mission;
    board = mission.initialGarbage
        .map((row) => List<bool>.from(row))
        .toList();
    assert(board.length == mission.boardHeight);
    assert(board.every((r) => r.length == mission.boardWidth));

    _bag.clear();
    for (var i = 0; i < mission.bagCount; i++) {
      final cycle = List<TetrominoType>.from(TetrominoType.values);
      cycle.shuffle(_random);
      _bag.addAll(cycle);
    }

    linesCleared = 0;
    status = GameStatus.playing;
    piecesSpawned = 0;
    active = null;
    nextType = _bag.isNotEmpty ? _bag.first : null;
    _spawnNext();
  }

  int get bagRemaining => _bag.length;

  bool get hasInitialGarbage =>
      board.any((row) => row.any((cell) => cell));

  /// 自然落下1段。着地ならロック。
  void tick() {
    if (status != GameStatus.playing || active == null) return;
    if (!_tryMove(0, 1)) {
      _lockActive();
    }
  }

  bool moveLeft() => _inputMove(-1, 0);
  bool moveRight() => _inputMove(1, 0);

  bool softDrop() {
    if (status != GameStatus.playing || active == null) return false;
    if (_tryMove(0, 1)) return true;
    _lockActive();
    return false;
  }

  void hardDrop() {
    if (status != GameStatus.playing || active == null) return;
    while (_tryMove(0, 1)) {}
    _lockActive();
  }

  bool rotateClockwise() {
    if (status != GameStatus.playing || active == null) return false;
    final piece = active!;
    final newRotation = (piece.rotation + 1) % 4;
    const kicks = [0, -1, 1, -2, 2];
    for (final dx in kicks) {
      if (_fits(piece.type, piece.x + dx, piece.y, newRotation)) {
        piece.x += dx;
        piece.rotation = newRotation;
        return true;
      }
    }
    return false;
  }

  bool _inputMove(int dx, int dy) {
    if (status != GameStatus.playing || active == null) return false;
    return _tryMove(dx, dy);
  }

  bool _tryMove(int dx, int dy) {
    final piece = active!;
    if (!_fits(piece.type, piece.x + dx, piece.y + dy, piece.rotation)) {
      return false;
    }
    piece.x += dx;
    piece.y += dy;
    return true;
  }

  bool _fits(TetrominoType type, int x, int y, int rotation) {
    for (final c in TetrominoShapes.cells(type, rotation)) {
      final ax = c.x + x;
      final ay = c.y + y;
      if (ax < 0 ||
          ax >= mission.boardWidth ||
          ay < 0 ||
          ay >= mission.boardHeight) {
        return false;
      }
      if (board[ay][ax]) return false;
    }
    return true;
  }

  void _lockActive() {
    final piece = active!;
    for (final c in piece.absoluteCells()) {
      board[c.y][c.x] = true;
    }
    active = null;
    _clearLines();
    if (status == GameStatus.cleared) return;
    _spawnNext();
  }

  void _clearLines() {
    var cleared = 0;
    for (var y = mission.boardHeight - 1; y >= 0; y--) {
      if (board[y].every((c) => c)) {
        board.removeAt(y);
        board.insert(0, List<bool>.filled(mission.boardWidth, false));
        cleared++;
        y++; // re-check same index after shift
      }
    }
    linesCleared += cleared;
    if (mission.goalType == 'clearLines' &&
        linesCleared >= mission.goalLines) {
      status = GameStatus.cleared;
    }
  }

  void _spawnNext() {
    if (status != GameStatus.playing) return;
    if (_bag.isEmpty) {
      status = GameStatus.failed;
      nextType = null;
      return;
    }
    final type = _bag.removeAt(0);
    nextType = _bag.isNotEmpty ? _bag.first : null;
    // スポーン: 上部中央付近
    final spawnX = (mission.boardWidth ~/ 2) - 2;
    const spawnY = 0;
    if (!_fits(type, spawnX, spawnY, 0)) {
      status = GameStatus.failed;
      active = null;
      return;
    }
    active = ActivePiece(type: type, x: spawnX, y: spawnY);
    piecesSpawned++;
  }

  /// 描画用: 固定盤 + アクティブピース。
  List<List<bool>> displayBoard() {
    final copy = board.map((r) => List<bool>.from(r)).toList();
    final piece = active;
    if (piece != null) {
      for (final c in piece.absoluteCells()) {
        if (c.y >= 0 &&
            c.y < mission.boardHeight &&
            c.x >= 0 &&
            c.x < mission.boardWidth) {
          copy[c.y][c.x] = true;
        }
      }
    }
    return copy;
  }
}
