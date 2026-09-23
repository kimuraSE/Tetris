import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tetris/data/repositories/mission_repository.dart';
import 'package:tetris/models/game_engine.dart';
import 'package:tetris/models/mission.dart';
import 'package:tetris/models/tetromino.dart';

/// Play 画面用 ViewModel。Ticker 相当の定期落下と入力 API。
class PlayViewModel extends ChangeNotifier {
  PlayViewModel({
    required this.missionId,
    MissionRepository? repository,
    GameEngine? engine,
  })  : _repository = repository ?? MissionRepository(),
        engine = engine ?? GameEngine() {
    restart();
  }

  final String missionId;
  final MissionRepository _repository;
  final GameEngine engine;

  Timer? _timer;
  late Mission mission;

  GameStatus get status => engine.status;
  int get linesCleared => engine.linesCleared;
  int get goalLines => mission.goalLines;
  TetrominoType? get nextType => engine.nextType;
  List<List<bool>> get displayBoard => engine.displayBoard();
  bool get isTerminal =>
      status == GameStatus.cleared || status == GameStatus.failed;

  void restart() {
    _stopLoop();
    mission = _repository.get(missionId);
    engine.start(mission);
    _startLoop();
    notifyListeners();
  }

  void _startLoop() {
    _stopLoop();
    if (isTerminal) return;
    _timer = Timer.periodic(
      Duration(milliseconds: mission.dropIntervalMs),
      (_) => _onTick(),
    );
  }

  void _stopLoop() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTick() {
    if (isTerminal) {
      _stopLoop();
      return;
    }
    engine.tick();
    _afterEngine();
  }

  void _afterEngine() {
    if (isTerminal) {
      _stopLoop();
    }
    notifyListeners();
  }

  void moveLeft() {
    if (isTerminal) return;
    engine.moveLeft();
    notifyListeners();
  }

  void moveRight() {
    if (isTerminal) return;
    engine.moveRight();
    notifyListeners();
  }

  void rotate() {
    if (isTerminal) return;
    engine.rotateClockwise();
    notifyListeners();
  }

  void softDrop() {
    if (isTerminal) return;
    engine.softDrop();
    _afterEngine();
  }

  void hardDrop() {
    if (isTerminal) return;
    engine.hardDrop();
    _afterEngine();
  }

  /// テスト用: タイマーが動いているか。
  @visibleForTesting
  bool get isLoopRunning => _timer != null && _timer!.isActive;

  @override
  void dispose() {
    _stopLoop();
    super.dispose();
  }
}
