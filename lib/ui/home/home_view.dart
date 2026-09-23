import 'package:flutter/material.dart';
import 'package:tetris/ui/home/home_view_model.dart';
import 'package:tetris/ui/play/play_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, this.viewModel});

  final HomeViewModel? viewModel;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _vm =
      widget.viewModel ?? HomeViewModel();

  void _onStart() {
    if (!_vm.canStart()) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayView(missionId: _vm.missionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ミッションパック',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '有限バッグで4ライン消去を目指そう',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _onStart,
                  child: const Text('スタート'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
