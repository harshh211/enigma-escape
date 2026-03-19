// lib/screens/level_router_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import 'word_search_screen.dart';
import 'color_cascade_screen.dart';
import 'interrogation_screen.dart';
import 'memory_grid_screen.dart';
import 'decode_map_screen.dart';

class LevelRouterScreen extends StatelessWidget {
  const LevelRouterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final level = game.currentLevel;

    if (game.levelComplete) {
      return _LevelCompleteBanner(
        level: level,
        code: game.completedLevelCodes.last,
        isLastLevel: level == game.totalLevels,
      );
    }

    return switch (level) {
      1 => const WordSearchScreen(embedded: true),
      2 => const ColorCascadeScreen(),
      3 => const InterrogationScreen(),
      4 => const MemoryGridScreen(),
      5 => const DecodeMapScreen(),
      _ => const WordSearchScreen(embedded: true),
    };
  }
}

class _LevelCompleteBanner extends StatelessWidget {
  final int level;
  final String code;
  final bool isLastLevel;

  const _LevelCompleteBanner({
    required this.level,
    required this.code,
    required this.isLastLevel,
  });

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final puzzle = game.activePuzzle;
    final reveals = puzzle?.chapterReveals ?? [];
    final chapterText = reveals.length >= level ? reveals[level - 1] : '';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 80),
                const SizedBox(height: 20),
                Text(
                  isLastLevel ? 'MISSION COMPLETE!' : 'LEVEL $level COMPLETE!',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 20),

                // Code box
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.accentBlue.withOpacity(0.4)),
                  ),
                  child: Column(children: [
                    const Text('CODE UNLOCKED',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 2)),
                    const SizedBox(height: 6),
                    Text(code,
                        style: const TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6)),
                  ]),
                ),
                const SizedBox(height: 16),

                // Chapter reveal
                if (chapterText.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.auto_stories,
                              color: AppColors.primary, size: 14),
                          const SizedBox(width: 6),
                          Text('CHAPTER $level',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 8),
                        Text(chapterText,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                height: 1.6,
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                // All collected codes so far
                if (game.completedLevelCodes.length > 1)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: game.completedLevelCodes
                        .map((c) => Chip(
                              label: Text(c,
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 32),

                if (isLastLevel) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/story', (_) => false),
                      icon: const Icon(Icons.auto_stories),
                      label: const Text('CONTINUE'),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.read<GameProvider>().goToNextLevel(),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text('GO TO LEVEL ${level + 1}'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Next: ${puzzle?.levels[level].title ?? ""}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}