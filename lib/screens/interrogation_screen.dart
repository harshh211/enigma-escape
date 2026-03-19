// lib/screens/interrogation_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/timer_widget.dart';

class InterrogationScreen extends StatefulWidget {
  const InterrogationScreen({super.key});

  @override
  State<InterrogationScreen> createState() => _InterrogationScreenState();
}
void _confirmBack(BuildContext context) {
    Navigator.pushNamed(context, '/mission');
  }
class _InterrogationScreenState extends State<InterrogationScreen> {
  int _currentQuestion = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _correct = false;
  bool _showHintText = false;

  // 15 second hint cooldown per question
  int _hintCountdown = 15;
  bool _hintUnlocked = false;
  Timer? _hintTimer;

  final List<String> _hints = [
    'Read the mission briefing carefully — the answer is right there.',
    'Think about security systems — which one makes the loudest noise?',
    'What do we call 12:00 at night? Think about AM and PM.',
    'Think back to Level 1 — what was the first letter of the passphrase you found?',
    'Remember the colors you connected in Level 2 — was orange one of them?',
  ];

  @override
  void initState() {
    super.initState();
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
      _hintCountdown = 15;
      _hintUnlocked = false;
      _showHintText = false;
    });
    _hintTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _hintTimer?.cancel();
        return;
      }
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

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final questions = game.activePuzzle!.interrogation.questions;
    final question = questions[_currentQuestion];
    final isLastQuestion = _currentQuestion == questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'LEVEL 3 — Q${_currentQuestion + 1} of ${questions.length}'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _confirmBack(context),
        ),
      ),
      body: Column(
        children: [
          const LevelTimerBar(),

          // Progress bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentQuestion) / questions.length,
                backgroundColor: AppColors.surfaceLight,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Suspect icon
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceLight,
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.5),
                            width: 2),
                      ),
                      child: const Icon(Icons.person,
                          color: AppColors.accent, size: 40),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text('INTERROGATION',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 2)),
                  ),
                  const SizedBox(height: 20),

                  // Question
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      question.question,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hint button
                  if (!_answered)
                    GestureDetector(
                      onTap: _hintUnlocked
                          ? () {
                              if (!_showHintText) {
                                context.read<GameProvider>().activeSession?.hintsUsed++;
                              }
                              setState(() => _showHintText = !_showHintText);
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _hintUnlocked
                              ? AppColors.primary.withOpacity(0.08)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _hintUnlocked
                                  ? AppColors.primary.withOpacity(0.3)
                                  : AppColors.textSecondary
                                      .withOpacity(0.2)),
                        ),
                        child: Row(children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: _hintUnlocked
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _showHintText
                                  ? _hints[_currentQuestion]
                                  : _hintUnlocked
                                      ? 'Tap for a hint'
                                      : 'Hint available in ${_hintCountdown}s',
                              style: TextStyle(
                                  color: _showHintText
                                      ? AppColors.primary
                                      : _hintUnlocked
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondary
                                              .withOpacity(0.5),
                                  fontSize: 13,
                                  fontStyle: _showHintText
                                      ? FontStyle.italic
                                      : FontStyle.normal),
                            ),
                          ),
                          if (!_hintUnlocked)
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                value: (15 - _hintCountdown) / 15,
                                strokeWidth: 2,
                                backgroundColor:
                                    AppColors.surfaceLight,
                                valueColor:
                                    const AlwaysStoppedAnimation(
                                        AppColors.primary),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Options
                  ...question.options.asMap().entries.map((e) {
                    final idx = e.key;
                    final opt = e.value;

                    Color borderColor = Colors.transparent;
                    Color bgColor = AppColors.surfaceLight;
                    Color textColor = AppColors.textPrimary;

                    if (_answered) {
                      if (idx == question.correct) {
                        borderColor = AppColors.success;
                        bgColor = AppColors.success.withOpacity(0.12);
                        textColor = AppColors.success;
                      } else if (idx == _selectedOption) {
                        borderColor = AppColors.error;
                        bgColor = AppColors.error.withOpacity(0.12);
                        textColor = AppColors.error;
                      }
                    } else if (idx == _selectedOption) {
                      borderColor = AppColors.primary;
                      bgColor = AppColors.primary.withOpacity(0.1);
                    }

                    return GestureDetector(
                      onTap: _answered
                          ? null
                          : () =>
                              setState(() => _selectedOption = idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _selectedOption == idx && !_answered
                                        ? AppColors.primary
                                        : AppColors.background,
                                border: Border.all(
                                    color: _selectedOption == idx
                                        ? AppColors.primary
                                        : AppColors.textSecondary),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + idx),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedOption == idx &&
                                              !_answered
                                          ? AppColors.background
                                          : AppColors.textSecondary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(opt,
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 14)),
                            ),
                            if (_answered && idx == question.correct)
                              const Icon(Icons.check_circle,
                                  color: AppColors.success, size: 20),
                            if (_answered &&
                                idx == _selectedOption &&
                                idx != question.correct)
                              const Icon(Icons.cancel,
                                  color: AppColors.error, size: 20),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Submit / Next button
                  if (!_answered)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _selectedOption == null ? null : _submitAnswer,
                        child: const Text('SUBMIT ANSWER'),
                      ),
                    )
                  else if (_correct)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _nextQuestion,
                        icon: Icon(isLastQuestion
                            ? Icons.lock_open
                            : Icons.arrow_forward),
                        label: Text(isLastQuestion
                            ? 'GET THE CODE'
                            : 'NEXT QUESTION'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitAnswer() {
    final game = context.read<GameProvider>();
    final question = game.activePuzzle!.interrogation
        .questions[_currentQuestion];

    final isCorrect = _selectedOption == question.correct;

    setState(() {
      _answered = true;
      _correct = isCorrect;
    });

    if (!isCorrect) {
      // Track wrong answer
      game.activeSession?.wrongHighlights++;
      Future.delayed(const Duration(milliseconds: 400), () {
        _showLostDialog();
      });
    }
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
                'Wrong answer. You must restart from the beginning.',
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

  void _nextQuestion() {
    final game = context.read<GameProvider>();
    final questions = game.activePuzzle!.interrogation.questions;

    if (_currentQuestion < questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = null;
        _answered = false;
        _correct = false;
      });
      _startHintTimer();
    } else {
      final code = game.activePuzzle!.interrogation.code;
      game.completeLevel(code);
    }
  }
}