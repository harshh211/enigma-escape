// lib/screens/memory_grid_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/timer_widget.dart';

enum MemoryPhase { memorize, recall, lost }

class MemoryGridScreen extends StatefulWidget {
  const MemoryGridScreen({super.key});

  @override
  State<MemoryGridScreen> createState() => _MemoryGridScreenState();
}
void _confirmBack(BuildContext context) {
    Navigator.pushNamed(context, '/mission');
  }
class _MemoryGridScreenState extends State<MemoryGridScreen> {
  MemoryPhase _phase = MemoryPhase.memorize;
  List<int> _playerSequence = [];
  int _attempts = 0;
  static const int _maxAttempts = 3;

  late List<int> _sequence;
  late int _gridSize;
  int _countdown = 5;

  // Hint cooldown
  int _hintCountdown = 60;
  bool _hintUnlocked = false;
  Timer? _hintTimer;
  bool _showingHint = false;

  @override
  void initState() {
    super.initState();
    final data = context.read<GameProvider>().activePuzzle!.memoryGrid;
    _sequence = data.sequence;
    _gridSize = data.gridSize;
    _startCountdown();
    _startHintTimer();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    setState(() {
      _hintCountdown = 60;
      _hintUnlocked = false;
    });
    _hintTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) { _hintTimer?.cancel(); return; }
      setState(() {
        if (_hintCountdown > 0) {
          _hintCountdown--;
        } else {
          _hintUnlocked = true;
          _hintTimer?.cancel();
        }
      });
    });
  }

  void _showHint() {
    context.read<GameProvider>().activeSession?.hintsUsed++;
    setState(() {
      _showingHint = true;
      _phase = MemoryPhase.memorize;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showingHint = false;
          _phase = MemoryPhase.recall;
          _playerSequence = [];
        });
      }
    });
  }

  void _startCountdown() {
    setState(() {
      _phase = MemoryPhase.memorize;
      _countdown = 5;
      _playerSequence = [];
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      if (_countdown <= 0) {
        setState(() => _phase = MemoryPhase.recall);
        return false;
      }
      return true;
    });
  }

  void _onTileTap(int index) {
    if (_phase != MemoryPhase.recall) return;

    final newSeq = [..._playerSequence, index];
    setState(() => _playerSequence = newSeq);

    final step = newSeq.length - 1;

    if (newSeq[step] != _sequence[step]) {
      _attempts++;
      context.read<GameProvider>().activeSession?.wrongHighlights++;
      if (_attempts >= _maxAttempts) {
        setState(() => _phase = MemoryPhase.lost);
        Future.delayed(const Duration(milliseconds: 300), _showLostDialog);
      } else {
        _showWrongDialog();
      }
      return;
    }

    if (newSeq.length == _sequence.length) {
      Future.delayed(const Duration(milliseconds: 400), () {
        final code =
            context.read<GameProvider>().activePuzzle!.memoryGrid.code;
        context.read<GameProvider>().completeLevel(code);
      });
    }
  }

  void _showWrongDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close, color: AppColors.error, size: 56),
            const SizedBox(height: 12),
            const Text('WRONG SEQUENCE',
                style: TextStyle(
                    color: AppColors.error,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              '${_maxAttempts - _attempts} attempt${_maxAttempts - _attempts != 1 ? 's' : ''} remaining',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _startCountdown();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('TRY AGAIN'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            const Text('YOU LOST!',
                style: TextStyle(
                    color: AppColors.error,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'You used all 3 attempts. Restart from the beginning.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/mission', (_) => false);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('RESTART FROM BRIEFING'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 4 — MEMORY GRID'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _confirmBack(context),
        ),
      ),
      body: Column(
        children: [
          const LevelTimerBar(),

          // Phase banner
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            color: _phase == MemoryPhase.memorize
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.accent.withOpacity(0.15),
            padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Column(
              children: [
                Text(
                  _showingHint
                      ? 'HINT — MEMORIZE AGAIN!'
                      : _phase == MemoryPhase.memorize
                          ? 'MEMORIZE THE BLOCKS'
                          : 'TAP THE BLOCKS IN ORDER',
                  style: TextStyle(
                    color: _showingHint
                        ? AppColors.success
                        : _phase == MemoryPhase.memorize
                            ? AppColors.primary
                            : AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_phase == MemoryPhase.memorize && !_showingHint) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Switching in $_countdown seconds...',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
                if (_phase == MemoryPhase.recall) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${_playerSequence.length} / ${_sequence.length} tapped  ·  Attempt ${_attempts + 1} of $_maxAttempts',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSize,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _gridSize * _gridSize,
                  itemBuilder: (context, idx) {
                    final isInSequence = _sequence.contains(idx);
                    final isTapped = _playerSequence.contains(idx);
                    final posInSequence = _sequence.indexOf(idx);

                    Color bg;

                    if ((_phase == MemoryPhase.memorize || _showingHint) &&
                        isInSequence) {
                      bg = AppColors.primary.withOpacity(0.7);
                    } else if (_phase == MemoryPhase.recall && isTapped) {
                      bg = AppColors.accent.withOpacity(0.6);
                    } else {
                      bg = AppColors.surfaceLight;
                    }

                    return GestureDetector(
                      onTap: () => _onTileTap(idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (_phase == MemoryPhase.memorize ||
                                        _showingHint) &&
                                    isInSequence
                                ? AppColors.primary
                                : AppColors.surface,
                            width: 2,
                          ),
                          boxShadow: (_phase == MemoryPhase.memorize ||
                                      _showingHint) &&
                                  isInSequence
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primary.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: (_phase == MemoryPhase.memorize ||
                                    _showingHint) &&
                                isInSequence
                            ? Center(
                                child: Text(
                                  '${posInSequence + 1}',
                                  style: const TextStyle(
                                    color: AppColors.background,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Hint button
          if (_phase == MemoryPhase.recall)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _hintUnlocked && !_showingHint
                      ? _showHint
                      : null,
                  icon: Icon(
                    Icons.lightbulb_outline,
                    color: _hintUnlocked
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 16,
                  ),
                  label: Text(
                    _hintUnlocked
                        ? 'HINT — SHOW SEQUENCE AGAIN'
                        : 'HINT AVAILABLE IN ${_hintCountdown}s',
                    style: TextStyle(
                      color: _hintUnlocked
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _hintUnlocked
                          ? AppColors.primary.withOpacity(0.4)
                          : AppColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}