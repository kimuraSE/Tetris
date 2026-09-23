import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/data/repositories/mission_repository.dart';
import 'package:tetris/models/game_engine.dart';
import 'package:tetris/models/mission.dart';
import 'package:tetris/models/tetromino.dart';

void main() {
  group('MissionRepository', () {
    test('m01 は確定MVPパラメータを返す', () {
      final mission = MissionRepository().get('m01');
      expect(mission.id, 'm01');
      expect(mission.boardWidth, 10);
      expect(mission.boardHeight, 20);
      expect(mission.goalType, 'clearLines');
      expect(mission.goalLines, 4);
      expect(mission.bagCount, 1);
      expect(mission.dropIntervalMs, closeTo(900, 50));
      expect(mission.initialGarbage.length, 20);
      expect(mission.initialGarbage.every((r) => r.length == 10), isTrue);
      expect(
        mission.initialGarbage.any((r) => r.any((c) => c)),
        isTrue,
      );
    });
  });

  group('GameEngine bag & spawn', () {
    test('バッグは7種×1周で消費され枯渇する', () {
      final engine = GameEngine(random: Random(1));
      final mission = MissionRepository().get('m01');
      engine.start(mission);
      expect(engine.active, isNotNull);
      expect(engine.bagRemaining, 6);

      // 残6 + 現在1 = 計7スポーンまで。ハードドロップでロックを繰り返す。
      var spawns = 1;
      while (engine.status == GameStatus.playing && spawns < 20) {
        engine.hardDrop();
        if (engine.active != null) {
          spawns++;
        }
      }
      // バッグ枯渇またはクリアで終了
      expect(
        engine.status == GameStatus.failed ||
            engine.status == GameStatus.cleared,
        isTrue,
      );
      expect(engine.piecesSpawned, lessThanOrEqualTo(7));
    });

    test('開始時に軽ゴミがある', () {
      final engine = GameEngine(random: Random(0));
      engine.start(MissionRepository().get('m01'));
      expect(engine.hasInitialGarbage, isTrue);
    });
  });

  group('GameEngine movement', () {
    test('壁への移動は拒否される', () {
      final empty = Mission(
        id: 'empty',
        boardWidth: 10,
        boardHeight: 20,
        goalType: 'clearLines',
        goalLines: 99,
        bagCount: 1,
        dropIntervalMs: 900,
        initialGarbage:
            List.generate(20, (_) => List<bool>.filled(10, false)),
      );
      final engine = GameEngine(random: Random(42));
      engine.start(empty);
      // 左端まで
      for (var i = 0; i < 20; i++) {
        engine.moveLeft();
      }
      final xBefore = engine.active!.x;
      expect(engine.moveLeft(), isFalse);
      expect(engine.active!.x, xBefore);
    });

    test('回転とハードドロップでロックできる', () {
      final empty = Mission(
        id: 'empty',
        boardWidth: 10,
        boardHeight: 20,
        goalType: 'clearLines',
        goalLines: 99,
        bagCount: 1,
        dropIntervalMs: 900,
        initialGarbage:
            List.generate(20, (_) => List<bool>.filled(10, false)),
      );
      final engine = GameEngine(random: Random(2));
      engine.start(empty);
      engine.rotateClockwise();
      engine.hardDrop();
      // ロック後は次ピースまたは終了
      expect(
        engine.active != null || engine.status != GameStatus.playing,
        isTrue,
      );
    });
  });

  group('GameEngine clear & fail', () {
    test('ライン消去で linesCleared が増え goal でクリア', () {
      final rows = List.generate(20, (_) => List<bool>.filled(10, false));
      // 下4行: 列5だけ空き
      for (var y = 16; y <= 19; y++) {
        for (var x = 0; x < 10; x++) {
          rows[y][x] = x != 5;
        }
      }
      final mission = Mission(
        id: 'almost',
        boardWidth: 10,
        boardHeight: 20,
        goalType: 'clearLines',
        goalLines: 4,
        bagCount: 1,
        dropIntervalMs: 900,
        initialGarbage: rows,
      );
      final engine = GameEngine(random: Random(0));
      engine.start(mission);
      // I 縦置きで列5を埋める（回転1の相対x=2 → piece.x=3）
      engine.active = ActivePiece(
        type: TetrominoType.I,
        x: 3,
        y: 16,
        rotation: 1,
      );
      engine.hardDrop();
      expect(engine.status, GameStatus.cleared);
      expect(engine.linesCleared, greaterThanOrEqualTo(4));
    });

    test('スポーン不能で失敗', () {
      // 最上行をほぼ埋めてスポーン不能にする
      final rows = List.generate(20, (_) => List<bool>.filled(10, false));
      for (var x = 0; x < 10; x++) {
        rows[0][x] = true;
        rows[1][x] = true;
      }
      final mission = Mission(
        id: 'blocked',
        boardWidth: 10,
        boardHeight: 20,
        goalType: 'clearLines',
        goalLines: 4,
        bagCount: 1,
        dropIntervalMs: 900,
        initialGarbage: rows,
      );
      final engine = GameEngine(random: Random(0));
      engine.start(mission);
      expect(engine.status, GameStatus.failed);
    });

    test('バッグ空かつ未クリアで失敗', () {
      final empty = Mission(
        id: 'empty',
        boardWidth: 10,
        boardHeight: 20,
        goalType: 'clearLines',
        goalLines: 4,
        bagCount: 1,
        dropIntervalMs: 900,
        initialGarbage:
            List.generate(20, (_) => List<bool>.filled(10, false)),
      );
      final engine = GameEngine(random: Random(0));
      engine.start(empty);
      while (engine.status == GameStatus.playing) {
        engine.hardDrop();
      }
      // 空盤では4ライン達成は困難 → 失敗が基本
      expect(engine.status, GameStatus.failed);
      expect(engine.linesCleared, lessThan(4));
    });
  });
}
