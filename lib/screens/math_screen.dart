import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/hint_overlay.dart';
import '../widgets/timer_widget.dart';

class MathScreen extends StatefulWidget {
  const MathScreen({super.key});

  @override
  State<MathScreen> createState() => _MathScreenState();
}

class _MathScreenState extends State<MathScreen> {
  final TextEditingController _yellowController = TextEditingController();

  String _message = '';
  bool _solved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startTimer();
    });
  }

  @override
  void dispose() {
    _yellowController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final yellowText = _yellowController.text.trim();

    if (yellowText.isEmpty) {
      setState(() {
        _message = 'Please enter a value.';
      });
      return;
    }

    final yellow = int.tryParse(yellowText);

    if (yellow == null) {
      setState(() {
        _message = 'Only digits from 0 to 9 are allowed.';
      });
      return;
    }

    if (yellow < 0 || yellow > 9) {
      setState(() {
        _message = 'Use a single digit only.';
      });
      return;
    }

    final isCorrect = (yellow == 5);

    if (isCorrect) {
      setState(() {
        _solved = true;
        _message = 'Correct! Yellow = $yellow';
      });
      context.read<GameProvider>().completeLevel('Key');
    } else {
      setState(() {
        _message = 'That answer is not correct. Try again.';
      });
    }
  }

  void _clearInputs() {
    _yellowController.clear();
    setState(() {
      _message = '';
      _solved = false;
    });
  }

  Widget _circle(Color color, {double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleRow(List<Color> colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors
          .map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _circle(c),
            ),
          )
          .toList(),
    );
  }

  Widget _digitInput({
    required String label,
    required Color color,
    required TextEditingController controller,
  }) {
    return Column(
      children: [
        _circle(color, size: 54),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 88,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    const Color white = Colors.white;
    const Color red = Colors.red;
    final Color yellow = Colors.yellow.shade700;

    final hintProgress = game.hintAvailable
        ? 3.0
        : (60 - game.hintCooldownRemaining) / 30;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('LEVEL 6 — CIRCLE MATH'),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushNamed(context, '/mission'),
            ),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'YELLOW ONLY',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              const LevelTimerBar(),

              Container(
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology,
                      color: AppColors.accent,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      game.hintAvailable
                          ? '🤖 AI Hint ready!'
                          : '🤖 AI Hint in ${game.hintCooldownRemaining}s',
                      style: TextStyle(
                        color: game.hintAvailable
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: game.hintAvailable
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: hintProgress,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.accent,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (game.hintAvailable)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.read<GameProvider>().requestHint(),
                      icon: const Icon(Icons.psychology),
                      label: const Text('GET AI HINT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),

              Container(
                width: double.infinity,
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  'Solve the circle math puzzle and enter only the yellow digit.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2A2A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'WHAT NUMBER IS THE\nYELLOW CIRCLE?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 60, right: 12),
                                  child: Text(
                                    '+',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    _buildPuzzleRow([white, red, yellow]),
                                    const SizedBox(height: 10),
                                    _buildPuzzleRow([white, red, yellow]),
                                    const SizedBox(height: 10),
                                    _buildPuzzleRow([white, red, yellow]),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 180,
                                      height: 3,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildPuzzleRow([yellow, yellow, yellow]),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ENTER ONLY THE YELLOW DIGIT',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      _digitInput(
                        label: 'YELLOW',
                        color: yellow,
                        controller: _yellowController,
                      ),

                      const SizedBox(height: 28),

                      if (_message.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _solved
                                ? AppColors.success.withOpacity(0.12)
                                : AppColors.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _solved
                                  ? AppColors.success.withOpacity(0.4)
                                  : AppColors.error.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            _message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  _solved ? AppColors.success : AppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _clearInputs,
                              child: const Text('CLEAR'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _solved ? null : _checkAnswer,
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('CHECK ANSWER'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (game.showHint) const Positioned.fill(child: HintOverlay()),
      ],
    );
  }
}