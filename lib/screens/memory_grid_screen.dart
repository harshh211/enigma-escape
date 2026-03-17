import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

enum MemoryPhase { memorize, recall, result }

class MemoryGridScreen extends StatefulWidget {
  const MemoryGridScreen({super.key});

  @override
  State<MemoryGridScreen> createState() => _MemoryGridScreenState();
}

class _MemoryGridScreenState extends State<MemoryGridScreen> {
  MemoryPhase _phase = MemoryPhase.memorize;
  List<int> _playerSequence = [];
  bool _failed = false;
  int _attempts = 0;

  late List<int> _sequence;
  late int _gridSize;

  @override
  void initState() {
    super.initState();
    final data =
        context.read<GameProvider>().activePuzzle!.memoryGrid;
    _sequence = data.sequence;
    _gridSize = data.gridSize;

    // Auto switch to recall after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _phase == MemoryPhase.memorize) {
        setState(() => _phase = MemoryPhase.recall);
      }
    });
  }

  void _onTileTap(int index) {
    if (_phase != MemoryPhase.recall) return;

    setState(() {
      _playerSequence = [..._playerSequence, index];
    });

    final step = _playerSequence.length - 1;

    // Wrong tile
    if (_playerSequence[step] != _sequence[step]) {
      setState(() {
        _failed = true;
        _phase = MemoryPhase.result;
        _attempts++;
      });
      return;
    }

    // Completed sequence correctly
    if (_playerSequence.length == _sequence.length) {
      setState(() {
        _phase = MemoryPhase.result;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        final code = context
            .read<GameProvider>()
            .activePuzzle!
            .memoryGrid
            .code;
        context.read<GameProvider>().completeLevel(code);
      });
    }
  }

  void _tryAgain() {
    setState(() {
      _phase = MemoryPhase.memorize;
      _playerSequence = [];
      _failed = false;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _phase == MemoryPhase.memorize) {
        setState(() => _phase = MemoryPhase.recall);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 4 — MEMORY GRID'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Phase banner
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            color: _phase == MemoryPhase.memorize
                ? AppColors.primary.withOpacity(0.15)
                : _phase == MemoryPhase.recall
                    ? AppColors.accent.withOpacity(0.15)
                    : AppColors.success.withOpacity(0.15),
            padding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 20),
            child: Column(
              children: [
                Text(
                  _phase == MemoryPhase.memorize
                      ? '👁  MEMORIZE THE SEQUENCE'
                      : _phase == MemoryPhase.recall
                          ? '🧠  NOW REPEAT IT'
                          : _failed
                              ? '✗  WRONG — TRY AGAIN'
                              : '✓  CORRECT!',
                  style: TextStyle(
                    color: _phase == MemoryPhase.memorize
                        ? AppColors.primary
                        : _phase == MemoryPhase.recall
                            ? AppColors.accent
                            : _failed
                                ? AppColors.error
                                : AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_phase == MemoryPhase.memorize) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Switching to recall in 4 seconds...',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11),
                  ),
                ],
                if (_phase == MemoryPhase.recall) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_playerSequence.length} / ${_sequence.length} tapped',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11),
                  ),
                ],
              ],
            ),
          ),

          // Sequence display (only during memorize phase)
          if (_phase == MemoryPhase.memorize)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: _sequence.asMap().entries.map((e) {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Center(
                      child: Text(
                        '${e.value + 1}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSize,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _gridSize * _gridSize,
                  itemBuilder: (context, idx) {
                    final isInSequence =
                        _sequence.contains(idx);
                    final posInSequence =
                        _sequence.indexOf(idx);
                    final isTapped =
                        _playerSequence.contains(idx);

                    Color bg;
                    Widget child;

                    if (_phase == MemoryPhase.memorize &&
                        isInSequence) {
                      bg = AppColors.primary.withOpacity(0.3);
                      child = Text(
                        '${posInSequence + 1}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      );
                    } else if (_phase == MemoryPhase.recall &&
                        isTapped) {
                      bg = AppColors.accent.withOpacity(0.4);
                      child = const Icon(Icons.check,
                          color: AppColors.accent, size: 20);
                    } else {
                      bg = AppColors.surfaceLight;
                      child = const SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () => _onTileTap(idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _phase == MemoryPhase.memorize &&
                                    isInSequence
                                ? AppColors.primary
                                : AppColors.surface,
                          ),
                        ),
                        child: Center(child: child),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Try again button
          if (_phase == MemoryPhase.result && _failed)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text('Attempts: $_attempts',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _tryAgain,
                    icon: const Icon(Icons.refresh),
                    label: const Text('TRY AGAIN'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}