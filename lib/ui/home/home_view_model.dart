import 'package:flutter/foundation.dart';
import 'package:tetris/data/repositories/mission_repository.dart';

/// Home 画面用 ViewModel。開始時の missionId を提供する。
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({MissionRepository? repository})
      : _repository = repository ?? MissionRepository();

  final MissionRepository _repository;

  String get missionId => MissionRepository.defaultMissionId;

  /// 開始可能か（定義が取れること）を検証。
  bool canStart() {
    try {
      _repository.get(missionId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
