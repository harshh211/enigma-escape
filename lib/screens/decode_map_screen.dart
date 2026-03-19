import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class DecodeMapScreen extends StatefulWidget {
  const DecodeMapScreen({super.key});

  @override
  State<DecodeMapScreen> createState() => _DecodeMapScreenState();
}
void _confirmBack(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Return to briefing?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Your level progress will be lost.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('STAY',
                  style: TextStyle(color: AppColors.accent))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/mission', (_) => false);
              },
              child: const Text('GO BACK',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
class _DecodeMapScreenState extends State<DecodeMapScreen> {
  
  late List<String> _shuffledCodes;
  late List<int> _correctAnswers; 
  final List<int?> _selectedLevels = [null, null, null, null];
  bool _checked = false;
  bool _won = false;
  int _attempts = 0;

  
  final List<Map<String, dynamic>> _codeInfo = [
    {'code': 'VAGLE', 'level': 1},
    {'code': 'CC1',   'level': 2},
    {'code': 'MG1',   'level': 4},
    {'code': 'IR1',   'level': 3},
  ];

  @override
  void initState() {
    super.initState();
    // Shuffle the display order
    _shuffledCodes = _codeInfo.map((c) => c['code'] as String).toList();
    _shuffledCodes.shuffle();
    _correctAnswers = _shuffledCodes
        .map((code) => _codeInfo
            .firstWhere((c) => c['code'] == code)['level'] as int)
        .toList();
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
        final code =
            context.read<GameProvider>().activePuzzle!.decodeMap.code;
        context.read<GameProvider>().completeLevel(code);
      });
    }
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TimerBadge(seconds: game.timeRemaining),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      color: (_won ? AppColors.success : AppColors.primary)
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
              final isCorrect = _checked && selected == _correctAnswers[i];
              final isWrong = _checked && selected != _correctAnswers[i];

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
                              color: AppColors.primary.withOpacity(0.4)),
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
                    // Level selector buttons 1-4
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            duration: const Duration(milliseconds: 200),
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
                        color: AppColors.textSecondary, fontSize: 12)),
              ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: !allSelected || _won ? null : _checkAnswers,
                icon: const Icon(Icons.lock_open),
                label: const Text('CRACK THE LOCK',
                    style: TextStyle(fontSize: 16, letterSpacing: 1)),
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

// Small timer badge for appbar
class TimerBadge extends StatelessWidget {
  final int seconds;
  const TimerBadge({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    final isLow = seconds < 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isLow
            ? AppColors.error.withOpacity(0.2)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isLow
                ? AppColors.error.withOpacity(0.5)
                : Colors.transparent),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.timer,
            size: 13,
            color: isLow ? AppColors.error : AppColors.textSecondary),
        const SizedBox(width: 4),
        Text('$m:$s',
            style: TextStyle(
                color: isLow ? AppColors.error : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ]),
    );
  }
}