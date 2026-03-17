import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class EnigmaDrawer extends StatelessWidget {
  const EnigmaDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: AppColors.surfaceLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ENIGMA ROOMS',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  Text(game.teamName,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                      '${game.achievements.where((a) => a.isUnlocked).length}/${game.achievements.length} achievements',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _Tile(icon: Icons.extension, label: 'Missions', route: '/'),
            _Tile(
                icon: Icons.emoji_events,
                label: 'Achievements & Story',
                route: '/achievements'),
            _Tile(
                icon: Icons.leaderboard,
                label: 'Leaderboard',
                route: '/leaderboard'),
            const Divider(
                color: AppColors.surfaceLight, thickness: 1, height: 24),
            _Tile(icon: Icons.settings, label: 'Settings', route: '/settings'),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '100% offline · SQLite + SharedPreferences\nNo cloud. No internet required.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _Tile(
      {required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.textSecondary, size: 22),
        title: Text(label,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14)),
        onTap: () {
          Navigator.pop(context);
          if (route == '/') {
            Navigator.pushNamedAndRemoveUntil(
                context, '/', (_) => false);
          } else {
            Navigator.pushNamed(context, route);
          }
        },
      );
}