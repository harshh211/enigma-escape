// lib/screens/decode_map_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/timer_widget.dart';

class DecodeMapScreen extends StatefulWidget {
  const DecodeMapScreen({super.key});

  @override
  State<DecodeMapScreen> createState() => _DecodeMapScreenState();
}

class _DecodeMapScreenState extends State<DecodeMapScreen> {
  late List<String> _shuffledCodes;
  late List<int> _correctAnswers;
  final List<int?> _selectedLevels = [null, null, null, null];
  bool _checked = false;
  bool _won = false;
  int _attempts = 0;

  final List<Map<String, dynamic>> _codeInfo = [
    {'code': 'V.A.G.L.E.', 'level': 1},
    {'code': 'LOCK', 'level': 2},
    {'code': 'VAULT', 'level': 3},
    {'code': 'TRACKS', 'level': 4},
  ];

  // AI hint countdown
  int _hintCountdown = 30;
  bool _hintUnlocked = false;
  Timer? _hintTimer;
  bool _hintShown = false;

  @override
  void initState() {
    super.initState();
    _shuffledCodes = _codeInfo.map((c) => c['code'] as String).toList();
    _shuffledCodes.shuffle();
    _correctAnswers = _shuffledCodes
        .map((code) => _codeInfo
            .firstWhere((c) => c['code'] == code)['level'] as int)
        .toList();
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
      _hintCountdown = 30;
      _hintUnlocked = false;
      _hintShown = false;
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
      if (_hintCountdown == 0 && !_hintShown && !_won) {
        setState(() => _hintShown = true);
        context.read<GameProvider>().trackHintUsed();
        Future.delayed(
            const Duration(milliseconds: 100), _showAutoHint);
      }
    });
  }

  void _showAutoHint() {
    if (!mounted) return;
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
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology,
                      color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text('AI GAME MASTER',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1)),
                ]),
            const SizedBox(height: 16),
            const Text(
              'Remember which level gave you each code:',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._codeInfo.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(c['code'] as String,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 10),
                      Text('Level ${c['level']}',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _feedbackBtn(
                      Icons.thumb_up_alt_outlined, AppColors.success),
                  const SizedBox(width: 14),
                  _feedbackBtn(
                      Icons.thumb_down_alt_outlined, AppColors.error),
                ]),
          ],
        ),
      ),
    );
  }

  Widget _feedbackBtn(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _startHintTimer();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  void _checkAnswers() {
    bool allCorrect = true;
    for (int i = 0; i < _correctAnswers.length; i++) {
      if (_selectedLevels[i] != _correctAnswers[i]) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      _checked = true;
      _won = allCorrect;
      if (!allCorrect) _attempts++;
    });

    if (allCorrect) {
      Future.delayed(const Duration(milliseconds: 600), () {
        final code = context
            .read<GameProvider>()
            .activePuzzle!
            .decodeMap
            .code;
        context.read<GameProvider>().completeLevel(code);
      });
    }
  }

  void _confirmBack(BuildContext context) {
    Navigator.pushNamed(context, '/mission');
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final allSelected = _selectedLevels.every((l) => l != null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 5 — CRACK THE LOCK'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _confirmBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LevelTimerBar(),
            const SizedBox(height: 8),

            // AI hint countdown bar
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.psychology,
                    color: AppColors.accent, size: 14),
                const SizedBox(width: 6),
                Text(
                  _hintUnlocked
                      ? '🤖 AI Hint ready!'
                      : '🤖 AI Hint in ${_hintCountdown}s',
                  style: TextStyle(
                      color: _hintCountdown <= 10
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: _hintCountdown <= 10
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (30 - _hintCountdown) / 30,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.accent),
                      minHeight: 4,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Lock icon
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.12),
                  border: Border.all(
                      color: _won
                          ? AppColors.success
                          : AppColors.primary.withOpacity(0.4),
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_won ? AppColors.success : AppColors.primary)
                              .withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _won ? Icons.lock_open : Icons.lock,
                  color: _won ? AppColors.success : AppColors.primary,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Center(
              child: Text('CRACK THE LOCK',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'On which level did you find each code?',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),

            if (_checked && !_won) ...[
              const SizedBox(height: 8),
              const Center(
                child: Text('Wrong! Try again.',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold)),
              ),
            ],
            if (_checked && _won) ...[
              const SizedBox(height: 8),
              const Center(
                child: Text('✓ Lock cracked!',
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold)),
              ),
            ],

            const SizedBox(height: 28),

            // Code questions
            ...List.generate(_shuffledCodes.length, (i) {
              final code = _shuffledCodes[i];
              final selected = _selectedLevels[i];
              final isCorrect =
                  _checked && selected == _correctAnswers[i];
              final isWrong =
                  _checked && selected != _correctAnswers[i];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCorrect
                        ? AppColors.success.withOpacity(0.6)
                        : isWrong
                            ? AppColors.error.withOpacity(0.6)
                            : AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Text(code,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 2)),
                      ),
                      const SizedBox(width: 10),
                      const Text('was found on level:',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13)),
                      const Spacer(),
                      if (isCorrect)
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 20),
                      if (isWrong)
                        const Icon(Icons.cancel,
                            color: AppColors.error, size: 20),
                    ]),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (lvl) {
                        final levelNum = lvl + 1;
                        final isSelected = selected == levelNum;
                        return GestureDetector(
                          onTap: _checked && _won
                              ? null
                              : () => setState(() {
                                    _selectedLevels[i] = levelNum;
                                    _checked = false;
                                  }),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.2)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceLight,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$levelNum',
                                style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            if (_attempts > 0)
              Center(
                child: Text('Attempts: $_attempts',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12)),
              ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: !allSelected || _won ? null : _checkAnswers,
                icon: const Icon(Icons.lock_open),
                label: const Text('CRACK THE LOCK',
                    style:
                        TextStyle(fontSize: 16, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _won ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}