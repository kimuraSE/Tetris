import 'package:tetris/models/mission.dart';

/// ミッション定義の Single Source of Truth。
class MissionRepository {
  Mission get(String missionId) {
    final mission = _missions[missionId];
    if (mission == null) {
      throw ArgumentError.value(missionId, 'missionId', 'unknown mission');
    }
    return mission;
  }

  static const String defaultMissionId = 'm01';

  static final Map<String, Mission> _missions = {
    'm01': Mission(
      id: 'm01',
      boardWidth: 10,
      boardHeight: 20,
      goalType: 'clearLines',
      goalLines: 4,
      bagCount: 1,
      dropIntervalMs: 900,
      initialGarbage: _m01LightGarbage(),
    ),
  };

  /// 下寄り・穴あきの軽ゴミ（上から20行）。
  static List<List<bool>> _m01LightGarbage() {
    final rows = List.generate(20, (_) => List<bool>.filled(10, false));
    // 下4行にほぼ埋まった行（各行1穴）— クリアしやすく goalLines=4 と釣り合い。
    const patterns = <String>[
      '1111111101', // y=16
      '1110111111', // y=17
      '1101111111', // y=18
      '1111111011', // y=19
    ];
    for (var i = 0; i < patterns.length; i++) {
      final y = 16 + i;
      final p = patterns[i];
      for (var x = 0; x < 10; x++) {
        rows[y][x] = p[x] == '1';
      }
    }
    return rows;
  }
}
