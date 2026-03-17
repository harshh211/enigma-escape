import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class ClueTrackerScreen extends StatelessWidget {
  const ClueTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final clues = game.clues;
    final found = game.cluesFound;

    return Scaffold(
      appBar: AppBar(title: const Text('CLUE TRACKER')),
      body: Column(
        children: [
          // Stats bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                    label: 'FOUND',
                    value: '$found',
                    color: AppColors.success),
                _Stat(
                    label: 'REMAINING',
                    value: '${clues.length - found}',
                    color: AppColors.primary),
                _Stat(
                    label: 'HINTS',
                    value:
                        '${game.activeSession?.hintsUsed ?? 0}',
                    color: AppColors.accent),
                _Stat(
                    label: 'MISTAKES',
                    value:
                        '${game.activeSession?.wrongHighlights ?? 0}',
                    color: AppColors.error),
              ],
            ),
          ),

          // Clue list
          Expanded(
            child: clues.isEmpty
                ? const Center(
                    child: Text(
                        'No clues yet — start a mission first.',
                        style: TextStyle(
                            color: AppColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: clues.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final c = clues[i];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: c.isFound
                              ? AppColors.success.withOpacity(0.09)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: c.isFound
                                ? AppColors.success.withOpacity(0.4)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _NumberBubble(
                                number: i + 1,
                                filled: c.isFound),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.isFound
                                        ? c.text
                                        : 'Not yet discovered',
                                    style: TextStyle(
                                        color: c.isFound
                                            ? AppColors.textPrimary
                                            : AppColors
                                                .textSecondary,
                                        fontStyle: c.isFound
                                            ? FontStyle.normal
                                            : FontStyle.italic,
                                        fontSize: 14),
                                  ),
                                  if (c.isFound &&
                                      c.foundAt != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Found at ${_fmt(c.foundAt!)}',
                                      style: const TextStyle(
                                          color:
                                              AppColors.textSecondary,
                                          fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Words found row
          if (game.activePuzzle != null)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WORDS DECODED',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: game.activePuzzle!.wordsearch.words
                        .map((w) {
                      final f = game.foundWords
                          .contains(w.toUpperCase());
                      return Chip(
                        label: Text(w.toUpperCase(),
                            style: TextStyle(
                                color: f
                                    ? AppColors.cellFound
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        backgroundColor: f
                            ? AppColors.cellFound.withOpacity(0.12)
                            : AppColors.surfaceLight,
                        side: BorderSide(
                            color: f
                                ? AppColors.cellFound.withOpacity(0.5)
                                : Colors.transparent),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(
      {required this.label,
      required this.value,
      required this.color});
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: AppColors.textSecondary)),
        ],
      );
}

class _NumberBubble extends StatelessWidget {
  final int number;
  final bool filled;
  const _NumberBubble(
      {required this.number, required this.filled});
  @override
  Widget build(BuildContext context) => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.success : AppColors.surfaceLight,
          border: Border.all(
              color: filled
                  ? AppColors.success
                  : AppColors.textSecondary),
        ),
        child: Center(
          child: Text('$number',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: filled
                      ? Colors.white
                      : AppColors.textSecondary)),
        ),
      );
}