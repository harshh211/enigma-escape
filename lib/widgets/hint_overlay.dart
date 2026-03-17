import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/hint_model.dart';
import '../utils/app_theme.dart';

class HintOverlay extends StatelessWidget {
  const HintOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final result = game.pendingHint;
    if (result == null) return const SizedBox.shrink();

    final isWS = result.hint.type == HintType.wordSearch;
    final color = isWS ? AppColors.accent : AppColors.primary;
    final label = isWS ? 'WORD SEARCH HINT' : 'STORY HINT';
    final icon = isWS ? Icons.search : Icons.auto_stories;

    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.6), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 12)),
              ]),
              const SizedBox(height: 4),
              const Text('GAME MASTER',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 1.5)),
              const SizedBox(height: 20),
              Text(result.hint.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      height: 1.5)),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(result.displayReason,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: color.withOpacity(0.85),
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _RateButton(
                  icon: Icons.thumb_up_alt_outlined,
                  label: 'Helpful',
                  color: AppColors.success,
                  onTap: () => context.read<GameProvider>().rateHint(true),
                ),
                const SizedBox(width: 14),
                _RateButton(
                  icon: Icons.thumb_down_alt_outlined,
                  label: 'Not helpful',
                  color: AppColors.error,
                  onTap: () => context.read<GameProvider>().rateHint(false),
                ),
              ]),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    context.read<GameProvider>().dismissHint(),
                child: const Text('DISMISS',
                    style: TextStyle(
                        color: AppColors.textSecondary, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _RateButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ]),
        ),
      );
}