import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/puzzle_service.dart';
import '../utils/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  final bool embedded;
  const LeaderboardScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final sessions = game.leaderboard;

    final body = sessions.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.leaderboard,
                    size: 60, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                const Text('No completed missions yet.',
                    style:
                        TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                const Text(
                    'Finish a mission to appear on the board.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12)),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => context
                      .read<GameProvider>()
                      .loadLeaderboard(),
                  icon: const Icon(Icons.refresh,
                      color: AppColors.textSecondary),
                  label: const Text('REFRESH',
                      style: TextStyle(
                          color: AppColors.textSecondary)),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: () =>
                context.read<GameProvider>().loadLeaderboard(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, i) {
                final s = sessions[i];
                final puzzle =
                    PuzzleService.instance.getById(s.puzzleId);
                final rank = i + 1;

                final rankColor = rank == 1
                    ? const Color(0xFFFFD700)
                    : rank == 2
                        ? const Color(0xFFC0C0C0)
                        : rank == 3
                            ? const Color(0xFFCD7F32)
                            : AppColors.textSecondary;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: rank <= 3
                        ? Border.all(
                            color: rankColor.withOpacity(0.4))
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Rank
                      SizedBox(
                        width: 38,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                rank <= 3
                                    ? Icons.emoji_events
                                    : Icons.person_outline,
                                color: rankColor,
                                size: 18),
                            Text('$rank',
                                style: TextStyle(
                                    color: rankColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(s.teamName,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            Text(
                                puzzle?.title ?? s.puzzleId,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(children: [
                              _Tag(Icons.timer,
                                  s.elapsedFormatted),
                              const SizedBox(width: 10),
                              _Tag(Icons.psychology,
                                  '${s.hintsUsed} hints'),
                              const SizedBox(width: 10),
                              _Tag(Icons.warning_amber,
                                  '${s.wrongHighlights} err'),
                            ]),
                          ],
                        ),
                      ),
                      // Score
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${s.score}',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          const Text('pts',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEADERBOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<GameProvider>().loadLeaderboard(),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tag(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(text,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary)),
        ],
      );
}