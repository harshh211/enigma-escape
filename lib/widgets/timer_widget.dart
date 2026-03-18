import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class TimerWidget extends StatelessWidget {
  final int seconds;
  const TimerWidget({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    final isLow = seconds < 60;
    final isCritical = seconds < 30;

    final color = isCritical
        ? AppColors.error
        : isLow
            ? AppColors.primary
            : AppColors.textPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCritical
            ? AppColors.error.withOpacity(0.15)
            : isLow
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCritical
              ? AppColors.error.withOpacity(0.6)
              : isLow
                  ? AppColors.primary.withOpacity(0.4)
                  : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            '$m:$s',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}


class LevelTimerBar extends StatelessWidget {
  const LevelTimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final seconds = game.timeRemaining;
    final total = game.activePuzzle?.timeLimitSec ?? 600;
    final progress = (seconds / total).clamp(0.0, 1.0);
    final isLow = seconds < 60;
    final isCritical = seconds < 30;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');

    final color = isCritical
        ? AppColors.error
        : isLow
            ? AppColors.primary
            : AppColors.success;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.timer, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$m:$s',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceLight,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}