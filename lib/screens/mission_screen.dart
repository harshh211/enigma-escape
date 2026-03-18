import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/hint_overlay.dart';
import '../widgets/timer_widget.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    if (game.activePuzzle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('MISSION')),
        body: const Center(
          child: Text('No active mission.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    if (game.sessionComplete) return _ResultScreen();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('MISSION BRIEFING'),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => _confirmAbandon(context),
            ),
          ),
          body: _BriefingBody(),
        ),
        if (game.showHint) const Positioned.fill(child: HintOverlay()),
      ],
    );
  }

  Future<void> _confirmAbandon(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Abandon mission?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
            'Your progress will not be saved.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CONTINUE',
                  style: TextStyle(color: AppColors.accent))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ABANDON',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }
}

class _BriefingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final puzzle = game.activePuzzle!;
    final mins = (puzzle.timeLimitSec / 60).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mission icon
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.lock,
                  color: AppColors.primary, size: 46),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(puzzle.title,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoBox(Icons.timer, '$mins MIN', 'TIME LIMIT'),
              _InfoBox(Icons.layers, '5', 'LEVELS'),
              _InfoBox(Icons.star,
                  puzzle.difficulty.toUpperCase(), 'DIFFICULTY'),
            ],
          ),
          const SizedBox(height: 28),

          // Briefing
          _Section(
            title: 'YOUR MISSION',
            child: Text(puzzle.description,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.7)),
          ),
          const SizedBox(height: 20),

          // Level overview
          _Section(
            title: 'WHAT AWAITS YOU',
            child: Column(
              children: puzzle.levels.map((l) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withOpacity(0.15),
                            border: Border.all(
                                color: AppColors.accent.withOpacity(0.4)),
                          ),
                          child: Center(
                            child: Text('${l.level}',
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.title,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(l.instruction,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
            ),
          ),
          const SizedBox(height: 32),

          // Start button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/levels'),
              icon: const Icon(Icons.play_arrow, size: 22),
              label: const Text('BEGIN LEVEL 1',
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
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _InfoBox(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1)),
        ],
      );
}

// Result screen 
class _ResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final won = game.wordSearchComplete;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Icon(
                won ? Icons.emoji_events : Icons.timer_off,
                size: 80,
                color: won ? AppColors.primary : AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                won ? 'YOU ESCAPED!' : "TIME'S UP!",
                style: TextStyle(
                    color: won ? AppColors.primary : AppColors.error,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
              const SizedBox(height: 20),
              _ScoreRow(
                  label: 'SCORE',
                  value: '${game.activeSession?.score ?? 0}',
                  big: true),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScoreRow(
                      label: 'TIME',
                      value:
                          game.activeSession?.elapsedFormatted ?? '--'),
                  _ScoreRow(
                      label: 'HINTS',
                      value: '${game.activeSession?.hintsUsed ?? 0}'),
                  _ScoreRow(
                      label: 'MISTAKES',
                      value:
                          '${game.activeSession?.wrongHighlights ?? 0}'),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/', (_) => false),
                  icon: const Icon(Icons.home),
                  label: const Text('BACK TO HOME'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  final bool big;
  const _ScoreRow(
      {required this.label, required this.value, this.big = false});
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: big ? 36 : 22,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.5)),
        ],
      );
}