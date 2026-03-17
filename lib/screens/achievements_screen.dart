import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  final bool embedded;
  const AchievementsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final all = game.achievements;
    final unlocked = all.where((a) => a.isUnlocked).length;

    final body = Column(
      children: [
        // Progress header
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Text('$unlocked / ${all.length} Unlocked',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: all.isEmpty ? 0 : unlocked / all.length,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation(
                      AppColors.primary),
                  minHeight: 7,
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: all.isEmpty
              ? const Center(
                  child: Text(
                      'Complete missions to unlock achievements!',
                      style: TextStyle(
                          color: AppColors.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: all.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final a = all[i];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: a.isUnlocked
                            ? AppColors.surfaceLight
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: a.isUnlocked
                              ? AppColors.primary.withOpacity(0.5)
                              : AppColors.textSecondary
                                  .withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: a.isUnlocked
                                  ? AppColors.primary
                                      .withOpacity(0.18)
                                  : AppColors.surfaceLight,
                            ),
                            child: Icon(
                              a.isUnlocked
                                  ? Icons.emoji_events
                                  : Icons.lock_outline,
                              color: a.isUnlocked
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.isUnlocked ? a.name : '???',
                                  style: TextStyle(
                                    color: a.isUnlocked
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  a.isUnlocked
                                      ? a.description
                                      : 'Complete the mission to unlock',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13),
                                ),
                                if (a.isUnlocked &&
                                    a.unlockedAt != null) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    'Unlocked ${_date(a.unlockedAt!)}',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
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
      ],
    );

    if (embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('ACHIEVEMENTS & STORY')),
      body: body,
    );
  }

  String _date(DateTime d) => '${d.month}/${d.day}/${d.year}';
}