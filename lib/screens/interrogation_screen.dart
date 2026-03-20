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

class _InterrogationScreenState extends State<InterrogationScreen> {
  int _currentQuestion = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _correct = false;

  int _hintCountdown = 15;
  bool _hintUnlocked = false;
  Timer? _hintTimer;
  bool _hintShownForThisQuestion = false;

  final List<String> _hints = [
    'Read the mission briefing carefully the answer is right there.',
    'Think about security systems, which one makes the loudest noise?',
    'What do we call 12:00 at night?',
    'Think back to leVel 1,',
    'Remember the colors you connected in Level 2. This color looks like red',
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
      _hintShownForThisQuestion = false;
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
      if (_hintCountdown == 0 &&
          !_answered &&
          !_hintShownForThisQuestion) {
        setState(() => _hintShownForThisQuestion = true);
        context.read<GameProvider>().activeSession?.hintsUsed++;
        Future.delayed(
            const Duration(milliseconds: 100), _showHintDialog);
      }
    });
  }

  void _showHintDialog() {
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
            Text(
              '→  ${_hints[_currentQuestion]}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.5),
            ),
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

  void _showPassageHint(BuildContext context) {
    context.read<GameProvider>().activeSession?.hintsUsed++;
    final passage =
        context.read<GameProvider>().activePuzzle!.description;
    final words =
        context.read<GameProvider>().activePuzzle!.wordsearch.words;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.lightbulb, color: AppColors.primary, size: 20),
          SizedBox(width: 8),
          Text('PASSAGE HINT',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ]),
        content: SingleChildScrollView(
          child: _PassageText(passage: passage, words: words),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Widget _feedbackBtn(IconData icon, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
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

          // AI hint countdown bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Row(children: [
              const Icon(Icons.psychology,
                  color: AppColors.accent, size: 14),
              const SizedBox(width: 6),
              Text(
                _hintUnlocked
                    ? '🤖 AI Hint ready!'
                    : '🤖 AI Hint in ${_hintCountdown}s',
                style: TextStyle(
                    color: _hintCountdown <= 5
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: _hintCountdown <= 5
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (15 - _hintCountdown) / 15,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation(
                        AppColors.accent),
                    minHeight: 4,
                  ),
                ),
              ),
            ]),
          ),

          // Progress bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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

                  // Passage hint — only on question 1
                  if (_currentQuestion == 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showPassageHint(context),
                          icon: const Icon(
                              Icons.lightbulb_outline,
                              size: 16),
                          label:
                              const Text('VIEW PASSAGE HINT'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                                color: AppColors.primary
                                    .withOpacity(0.4)),
                          ),
                        ),
                      ),
                    ),

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
                        bgColor =
                            AppColors.success.withOpacity(0.12);
                        textColor = AppColors.success;
                      } else if (idx == _selectedOption) {
                        borderColor = AppColors.error;
                        bgColor =
                            AppColors.error.withOpacity(0.12);
                        textColor = AppColors.error;
                      }
                    } else if (idx == _selectedOption) {
                      borderColor = AppColors.primary;
                      bgColor =
                          AppColors.primary.withOpacity(0.1);
                    }

                    return GestureDetector(
                      onTap: _answered
                          ? null
                          : () => setState(
                              () => _selectedOption = idx),
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius:
                              BorderRadius.circular(12),
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
                                    color:
                                        _selectedOption == idx
                                            ? AppColors.primary
                                            : AppColors
                                                .textSecondary),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + idx),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedOption ==
                                                  idx &&
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
                                  color: AppColors.error,
                                  size: 20),
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
      game.activeSession?.wrongHighlights++;
      Future.delayed(
          const Duration(milliseconds: 400), _showLostDialog);
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
            const Icon(Icons.cancel,
                color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            const Text('YOU LOST!',
                style: TextStyle(
                    color: AppColors.error,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Wrong answer. You must restart from the beginning of level 3.',
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
                label: const Text('RESTART'),
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

  void _confirmBack(BuildContext context) {
    Navigator.pushNamed(context, '/mission');
  }
}

class _PassageText extends StatelessWidget {
  final String passage;
  final List<String> words;
  const _PassageText({required this.passage, required this.words});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final upper = passage.toUpperCase();
    int current = 0;

    final List<_Pos> positions = [];
    for (final word in words) {
      int idx = upper.indexOf(word.toUpperCase());
      while (idx != -1) {
        positions.add(_Pos(idx, idx + word.length));
        idx = upper.indexOf(word.toUpperCase(), idx + 1);
      }
    }
    positions.sort((a, b) => a.start.compareTo(b.start));

    final List<_Pos> clean = [];
    for (final p in positions) {
      if (clean.isEmpty || p.start >= clean.last.end) clean.add(p);
    }

    for (final pos in clean) {
      if (current < pos.start) {
        spans.add(TextSpan(
          text: passage.substring(current, pos.start),
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6),
        ));
      }
      spans.add(TextSpan(
        text: passage.substring(pos.start, pos.end),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 1.6,
        ),
      ));
      current = pos.end;
    }

    if (current < passage.length) {
      spans.add(TextSpan(
        text: passage.substring(current),
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _Pos {
  final int start;
  final int end;
  _Pos(this.start, this.end);
}