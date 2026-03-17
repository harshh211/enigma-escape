import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/puzzle_service.dart';
import '../models/puzzle_model.dart';
import '../utils/app_theme.dart';
import '../widgets/enigma_drawer.dart';
import 'achievements_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final body = switch (_tabIndex) {
      0 => const _MissionsTab(),
      1 => const AchievementsScreen(embedded: true),
      2 => const LeaderboardScreen(embedded: true),
      _ => const _MissionsTab(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('ENIGMA ROOMS'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: const EnigmaDrawer(),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.extension), label: 'Missions'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: 'Achievements'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
        ],
      ),
    );
  }
}

class _MissionsTab extends StatelessWidget {
  const _MissionsTab();

  @override
  Widget build(BuildContext context) {
    final puzzles = PuzzleService.instance.puzzles;
    final game = context.watch<GameProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.surface, AppColors.surfaceLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back,',
                    style: Theme.of(context).textTheme.bodySmall),
                Text(game.teamName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.extension,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                      '${puzzles.length} mission${puzzles.length != 1 ? 's' : ''} available',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  const Icon(Icons.emoji_events,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                      '${game.achievements.where((a) => a.isUnlocked).length}/${game.achievements.length} unlocked',
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('AVAILABLE MISSIONS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (puzzles.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No missions loaded.',
                    style:
                        TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ...puzzles.map((p) => _PuzzleCard(puzzle: p)),
        ],
      ),
    );
  }
}

class _PuzzleCard extends StatelessWidget {
  final Puzzle puzzle;
  const _PuzzleCard({required this.puzzle});

  @override
  Widget build(BuildContext context) {
    final isHard = puzzle.difficulty == 'hard';
    final mins = (puzzle.timeLimitSec / 60).round();
    final diffColor =
        isHard ? AppColors.accent : AppColors.accentBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: diffColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(puzzle.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.primary)),
              ),
              _Chip(
                  label: puzzle.difficulty.toUpperCase(),
                  color: diffColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(puzzle.description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            children: [
              _InfoChip(Icons.timer, '$mins min'),
              _InfoChip(Icons.grid_on,
                  '${puzzle.wordsearch.gridSize}×${puzzle.wordsearch.gridSize} grid'),
              _InfoChip(Icons.search,
                  '${puzzle.wordsearch.words.length} words'),
              _InfoChip(Icons.lightbulb_outline,
                  '${puzzle.clues.length} clues'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _start(context),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('START MISSION'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _start(BuildContext context) async {
    await context.read<GameProvider>().startSession(puzzle);
    if (context.mounted) Navigator.pushNamed(context, '/mission');
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color)),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      );
}