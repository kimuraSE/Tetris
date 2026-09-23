import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/main.dart';
import 'package:tetris/models/game_engine.dart';
import 'package:tetris/ui/home/home_view.dart';
import 'package:tetris/ui/play/play_view.dart';
import 'package:tetris/ui/play/play_view_model.dart';

void main() {
  testWidgets('Home が表示される', (tester) async {
    await tester.pumpWidget(const MissionPackApp());
    expect(find.text('ミッションパック'), findsOneWidget);
    expect(find.text('スタート'), findsOneWidget);
  });

  testWidgets('スタートで Play へ遷移する', (tester) async {
    await tester.pumpWidget(const MissionPackApp());
    await tester.tap(find.text('スタート'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ミッション'), findsWidgets);
    expect(find.byType(PlayView), findsOneWidget);
  });

  testWidgets('PlayViewModel dispose でループが止まる', (tester) async {
    final vm = PlayViewModel(missionId: 'm01');
    expect(vm.isLoopRunning, isTrue);
    vm.dispose();
    expect(vm.isLoopRunning, isFalse);
  });

  testWidgets('操作ボタンがエンジンに伝わる', (tester) async {
    final vm = PlayViewModel(missionId: 'm01');
    await tester.pumpWidget(
      MaterialApp(
        home: PlayView(missionId: 'm01', viewModel: vm),
      ),
    );
    final xBefore = vm.engine.active?.x;
    await tester.tap(find.byTooltip('右'));
    await tester.pump();
    expect(vm.engine.active?.x, isNot(equals(xBefore)));
    await tester.pumpWidget(const SizedBox.shrink());
    vm.dispose();
  });

  testWidgets('クリア／失敗オーバーレイともう一度・ホームへ', (tester) async {
    final vm = PlayViewModel(missionId: 'm01');

    // 強制的に失敗状態へ
    while (vm.status == GameStatus.playing) {
      vm.hardDrop();
    }
    expect(vm.isTerminal, isTrue);
    expect(vm.isLoopRunning, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeView(),
      ),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => PlayView(missionId: 'm01', viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('失敗…'), findsOneWidget);
    expect(find.text('もう一度'), findsOneWidget);
    expect(find.text('ホームへ'), findsOneWidget);

    await tester.tap(find.text('もう一度'));
    await tester.pump();
    expect(vm.status, GameStatus.playing);
    expect(vm.missionId, 'm01');

    // 再度失敗させてホームへ
    while (vm.status == GameStatus.playing) {
      vm.hardDrop();
    }
    await tester.pump();
    await tester.tap(find.text('ホームへ'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeView), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    vm.dispose();
  });
}
