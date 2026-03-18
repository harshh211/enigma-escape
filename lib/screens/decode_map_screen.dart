import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class DecodeMapScreen extends StatefulWidget {
  const DecodeMapScreen({super.key});

  @override
  State<DecodeMapScreen> createState() => _DecodeMapScreenState();
}

class _DecodeMapScreenState extends State<DecodeMapScreen> {
  
  final List<int> _dials = [0, 0, 0, 0];
  late List<int> _correctCombination;
  bool _checked = false;
  bool _won = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    
    _correctCombination =
        context.read<GameProvider>().activePuzzle!.decodeMap.correctOrder;
  }

  void _increment(int dialIndex) {
    setState(() {
      _dials[dialIndex] = (_dials[dialIndex] + 1) % 10;
      _checked = false;
    });
  }

  void _decrement(int dialIndex) {
    setState(() {
      _dials[dialIndex] = (_dials[dialIndex] - 1 + 10) % 10;
      _checked = false;
    });
  }

  void _checkCombination() {
    bool correct = true;
    for (int i = 0; i < _correctCombination.length; i++) {
      if (_dials[i] != _correctCombination[i]) {
        correct = false;
        break;
      }
    }

    setState(() {
      _checked = true;
      _won = correct;
      if (!correct) _attempts++;
    });

    if (correct) {
      Future.delayed(const Duration(milliseconds: 600), () {
        final code =
            context.read<GameProvider>().activePuzzle!.decodeMap.code;
        context.read<GameProvider>().completeLevel(code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 5 — CRACK THE LOCK'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Instruction
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Set the correct combination to crack the lock.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Use the codes you collected from all previous levels.',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  if (_checked && !_won) ...[
                    const SizedBox(height: 8),
                    Text(
                      '✗ Wrong combination — attempts: $_attempts',
                      style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                  if (_checked && _won) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '✓ Lock cracked! Well done!',
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Lock image
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLight,
                border: Border.all(
                  color: _won
                      ? AppColors.success
                      : _checked
                          ? AppColors.error
                          : AppColors.primary.withOpacity(0.4),
                  width: 3,
                ),
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
                size: 72,
              ),
            ),

            const SizedBox(height: 40),

            // Dials
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _dials.length,
                  (i) => _Dial(
                    value: _dials[i],
                    onUp: () => _increment(i),
                    onDown: () => _decrement(i),
                    isCorrect: _won ? true : null,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Codes collected
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CODES COLLECTED',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: context
                          .read<GameProvider>()
                          .completedLevelCodes
                          .map((c) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.primary
                                          .withOpacity(0.4)),
                                ),
                                child: Text(c,
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        letterSpacing: 2)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Check button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _won ? null : _checkCombination,
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
            ),
          ],
        ),
      ),
    );
  }
}

// Single dial widget
class _Dial extends StatelessWidget {
  final int value;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final bool? isCorrect;

  const _Dial({
    required this.value,
    required this.onUp,
    required this.onDown,
    this.isCorrect,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Up arrow
          GestureDetector(
            onTap: onUp,
            child: Container(
              width: 56,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Icon(Icons.keyboard_arrow_up,
                  color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(height: 2),
          // Number display
          Container(
            width: 56,
            height: 64,
            decoration: BoxDecoration(
              color: isCorrect == true
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.surface,
              border: Border.all(
                color: isCorrect == true
                    ? AppColors.success
                    : AppColors.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  color: isCorrect == true
                      ? AppColors.success
                      : AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Down arrow
          GestureDetector(
            onTap: onDown,
            child: Container(
              width: 56,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.primary, size: 28),
            ),
          ),
        ],
      );
}