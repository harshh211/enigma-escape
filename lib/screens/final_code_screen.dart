import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class FinalCodeScreen extends StatefulWidget {
  const FinalCodeScreen({super.key});

  @override
  State<FinalCodeScreen> createState() => _FinalCodeScreenState();
}

class _FinalCodeScreenState extends State<FinalCodeScreen> {
  final List<TextEditingController> _controllers = [];
  bool _checked = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    final count = context.read<GameProvider>().completedLevelCodes.length;
    for (int i = 0; i < count; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  void _checkCodes() {
    final game = context.read<GameProvider>();
    final correct = game.completedLevelCodes;
    bool allCorrect = true;

    for (int i = 0; i < correct.length; i++) {
      if (_controllers[i].text.trim().toUpperCase() !=
          correct[i].toUpperCase()) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      _checked = true;
      _won = allCorrect;
    });

    if (allCorrect) {
      // End the session
      Future.delayed(const Duration(milliseconds: 500), () {
        _showCongratsDialog();
      });
    }
  }

  void _showCongratsDialog() {
    final game = context.read<GameProvider>();
    final session = game.activeSession;
    final elapsed = session?.elapsedFormatted ?? '--';
    final hints = session?.hintsUsed ?? 0;
    final mistakes = session?.wrongHighlights ?? 0;
    // Force save latest stats before showing
    if (session != null) {
      session.endTime ??= DateTime.now();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events,
                color: AppColors.primary, size: 72),
            const SizedBox(height: 16),
            const Text('CONGRATULATIONS!',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('YOU WON!',
                style: TextStyle(
                    color: AppColors.success,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('See you again!',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),

            // Stats
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('YOUR STATS',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatBox('TIME', elapsed, AppColors.accentBlue),
                      _StatBox('HINTS', '$hints', AppColors.accent),
                      _StatBox(
                          'MISTAKES', '$mistakes', AppColors.error),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (_) => false);
                },
                icon: const Icon(Icons.home),
                label: const Text('BACK TO HOME'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final codes = game.completedLevelCodes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FINAL ESCAPE'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 2),
                ),
                child: const Icon(Icons.vpn_key,
                    color: AppColors.primary, size: 46),
              ),
            ),
            const SizedBox(height: 20),

            const Center(
              child: Text('ENTER THE CODES',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                  'Enter all the codes you collected, in the order you found them.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 32),

            // Code input fields
            ...List.generate(codes.length, (i) {
              final isCorrect = _checked &&
                  _controllers[i].text.trim().toUpperCase() ==
                      codes[i].toUpperCase();
              final isWrong = _checked &&
                  _controllers[i].text.trim().toUpperCase() !=
                      codes[i].toUpperCase();

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    // Level badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(0.15),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Input
                    Expanded(
                      child: TextField(
                        controller: _controllers[i],
                        style: TextStyle(
                            color: isCorrect
                                ? AppColors.success
                                : isWrong
                                    ? AppColors.error
                                    : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Level ${i + 1} code',
                          hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13),
                          filled: true,
                          fillColor: isCorrect
                              ? AppColors.success.withOpacity(0.1)
                              : isWrong
                                  ? AppColors.error.withOpacity(0.1)
                                  : AppColors.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.primary.withOpacity(0.5),
                                width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isCorrect
                                  ? AppColors.success.withOpacity(0.5)
                                  : isWrong
                                      ? AppColors.error.withOpacity(0.5)
                                      : Colors.transparent,
                            ),
                          ),
                          suffixIcon: _checked
                              ? Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.error)
                              : null,
                        ),
                        onChanged: (_) =>
                            setState(() => _checked = false),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            if (_checked && !_won)
              const Center(
                child: Text('Some codes are wrong — try again!',
                    style: TextStyle(
                        color: AppColors.error, fontSize: 13)),
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _won ? null : _checkCodes,
                icon: const Icon(Icons.key, size: 20),
                label: const Text('SUBMIT ALL CODES',
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1)),
        ],
      );
}