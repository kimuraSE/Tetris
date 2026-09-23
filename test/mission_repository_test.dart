import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/data/repositories/mission_repository.dart';

void main() {
  test('Flame 依存がなく MissionRepository が定数ミッションを返す', () {
    // pubspec に flame が無いことは analyze/pub get と別途確認。
    final m = MissionRepository().get('m01');
    expect(m.goalLines, 4);
  });
}
