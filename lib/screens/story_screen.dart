import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final puzzle = game.activePuzzle;
    final session = game.activeSession;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Trophy icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.15),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.5), width: 2),
                ),
                child: const Icon(Icons.emoji_events,
                    color: AppColors.primary, size: 56),
              ),
              const SizedBox(height: 20),

              const Text('CONGRATULATIONS!',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 6),
              const Text('YOU ESCAPED!',
                  style: TextStyle(
                      color: AppColors.success,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('See you again!',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 32),

              // Story reveal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.accent.withOpacity(0.4), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.gavel,
                          color: AppColors.accent, size: 18),
                      SizedBox(width: 8),
                      Text('CASE CLOSED',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 14),
                    Text(
                      'Outstanding work, detective! Thanks to your team, the curator Victor A. Greene has been arrested and handed over to the authorities. The Eye of Horus has been recovered from his private office and returned safely to the museum. Justice has been served. The city is safe once again.',

                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.7,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('YOUR STATS',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatBox(
                            label: 'TIME',
                            value: session?.elapsedFormatted ?? '--',
                            color: AppColors.accentBlue),
                        _StatBox(
                            label: 'HINTS',
                            value: '${session?.hintsUsed ?? 0}',
                            color: AppColors.accent),
                        _StatBox(
                            label: 'MISTAKES',
                            value: '${session?.wrongHighlights ?? 0}',
                            color: AppColors.error),
                        _StatBox(
                            label: 'SCORE',
                            value: '${session?.score ?? 0}',
                            color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Back to home button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/', (_) => false),
                  icon: const Icon(Icons.home),
                  label: const Text('BACK TO HOME',
                      style: TextStyle(fontSize: 16, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/leaderboard'),
                  icon: const Icon(Icons.leaderboard, size: 18),
                  label: const Text('VIEW LEADERBOARD'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1)),
        ],
      );
}