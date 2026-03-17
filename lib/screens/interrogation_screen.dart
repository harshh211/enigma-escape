import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class InterrogationScreen extends StatefulWidget {
  const InterrogationScreen({super.key});

  @override
  State<InterrogationScreen> createState() => _InterrogationScreenState();
}

class _InterrogationScreenState extends State<InterrogationScreen> {
  int _currentQuestion = 0;
  int _wrongAnswers = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _correct = false;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final questions =
        game.activePuzzle!.interrogation.questions;
    final question = questions[_currentQuestion];
    final isLastQuestion = _currentQuestion == questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 3 — INTERROGATION'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestion + 1} of ${questions.length}',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12),
                    ),
                    Text(
                      '$_wrongAnswers wrong',
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:
                        (_currentQuestion) / questions.length,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ],
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceLight,
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.5),
                            width: 2),
                      ),
                      child: const Icon(Icons.person,
                          color: AppColors.accent, size: 44),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('SUSPECT',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            letterSpacing: 2)),
                  ),
                  const SizedBox(height: 24),

                  // Question
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 20),

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
                          : () => setState(
                              () => _selectedOption = idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _selectedOption == idx &&
                                        !_answered
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
                                      color:
                                          _selectedOption == idx &&
                                                  !_answered
                                              ? AppColors.background
                                              : AppColors
                                                  .textSecondary),
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
                            if (_answered &&
                                idx == question.correct)
                              const Icon(Icons.check_circle,
                                  color: AppColors.success,
                                  size: 20),
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
                        onPressed: _selectedOption == null
                            ? null
                            : _submitAnswer,
                        child: const Text('SUBMIT ANSWER'),
                      ),
                    )
                  else
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
                          backgroundColor: _correct
                              ? AppColors.success
                              : AppColors.primary,
                        ),
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
    final question = context
        .read<GameProvider>()
        .activePuzzle!
        .interrogation
        .questions[_currentQuestion];

    final isCorrect = _selectedOption == question.correct;

    setState(() {
      _answered = true;
      _correct = isCorrect;
      if (!isCorrect) {
        _wrongAnswers++;
        // Wrong answer costs 15 seconds
        context.read<GameProvider>().activeSession?.wrongHighlights++;
      }
    });
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
    } else {
      // All questions done — complete the level
      final code = game.activePuzzle!.interrogation.code;
      game.completeLevel(code);
    }
  }
}