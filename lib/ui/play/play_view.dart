import 'package:flutter/material.dart';
import 'package:tetris/models/game_engine.dart';
import 'package:tetris/models/tetromino.dart';
import 'package:tetris/ui/play/play_view_model.dart';

class PlayView extends StatefulWidget {
  const PlayView({
    super.key,
    required this.missionId,
    this.viewModel,
  });

  final String missionId;
  final PlayViewModel? viewModel;

  @override
  State<PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  late final PlayViewModel _vm;
  late final bool _ownsVm;

  @override
  void initState() {
    super.initState();
    _ownsVm = widget.viewModel == null;
    _vm = widget.viewModel ??
        PlayViewModel(missionId: widget.missionId);
    _vm.addListener(_onVm);
  }

  void _onVm() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVm);
    if (_ownsVm) {
      _vm.dispose();
    }
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final board = _vm.displayBoard;
    final h = board.length;
    final w = board.isEmpty ? 0 : board.first.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('ミッション ${_vm.missionId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goHome,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('ライン ${_vm.linesCleared}/${_vm.goalLines}'),
                      _NextPreview(type: _vm.nextType),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: w / h,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: w,
                        ),
                        itemCount: w * h,
                        itemBuilder: (context, index) {
                          final y = index ~/ w;
                          final x = index % w;
                          final filled = board[y][x];
                          return Container(
                            margin: const EdgeInsets.all(0.5),
                            color: filled
                                ? Colors.teal.shade700
                                : Colors.grey.shade300,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                _Controls(vm: _vm),
              ],
            ),
            if (_vm.isTerminal) _ResultOverlay(vm: _vm, onHome: _goHome),
          ],
        ),
      ),
    );
  }
}

class _NextPreview extends StatelessWidget {
  const _NextPreview({required this.type});
  final TetrominoType? type;

  @override
  Widget build(BuildContext context) {
    return Text('Next: ${type?.name ?? '-'}');
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.vm});
  final PlayViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: vm.isTerminal ? null : vm.rotate,
                icon: const Icon(Icons.rotate_right),
                tooltip: '回転',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filledTonal(
                onPressed: vm.isTerminal ? null : vm.moveLeft,
                icon: const Icon(Icons.arrow_back),
                tooltip: '左',
              ),
              IconButton.filledTonal(
                onPressed: vm.isTerminal ? null : vm.softDrop,
                icon: const Icon(Icons.arrow_downward),
                tooltip: 'ソフト',
              ),
              IconButton.filledTonal(
                onPressed: vm.isTerminal ? null : vm.hardDrop,
                icon: const Icon(Icons.vertical_align_bottom),
                tooltip: 'ハード',
              ),
              IconButton.filledTonal(
                onPressed: vm.isTerminal ? null : vm.moveRight,
                icon: const Icon(Icons.arrow_forward),
                tooltip: '右',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({required this.vm, required this.onHome});
  final PlayViewModel vm;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final cleared = vm.status == GameStatus.cleared;
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cleared ? 'クリア！' : '失敗…',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: vm.restart,
                  child: const Text('もう一度'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onHome,
                  child: const Text('ホームへ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
