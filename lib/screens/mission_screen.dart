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
          child: Text('No active mission. Return home and start one.',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    if (game.sessionComplete) return _ResultScreen();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(game.activePuzzle!.title,
                overflow: TextOverflow.ellipsis),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => _confirmAbandon(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Cipher Lock',
                onPressed: () =>
                    Navigator.pushNamed(context, '/levels'),
              ),
              IconButton(
                icon: const Icon(Icons.list_alt),
                tooltip: 'Clue Tracker',
                onPressed: () =>
                    Navigator.pushNamed(context, '/clues'),
              ),
            ],
          ),
          body: _MissionBody(),
        ),
        if (game.showHint)
          const Positioned.fill(child: HintOverlay()),
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
            'Your progress will not be saved to the leaderboard.',
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

class _MissionBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final puzzle = game.activePuzzle!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(children: [
            Expanded(
                child: TimerWidget(seconds: game.timeRemaining)),
            const SizedBox(width: 10),
            _Badge(Icons.lightbulb_outline,
                '${game.cluesFound}/${game.clues.length}',
                AppColors.primary),
            const SizedBox(width: 8),
            _Badge(
                Icons.search,
                '${game.foundWords.length}/${puzzle.wordsearch.words.length}',
                AppColors.accentBlue),
            const SizedBox(width: 8),
            _Badge(Icons.psychology,
                '${game.activeSession?.hintsUsed ?? 0} hints',
                AppColors.accent),
          ]),
          const SizedBox(height: 20),

          // Briefing
          _Section(
            title: 'MISSION BRIEFING',
            child: Text(puzzle.description,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(height: 16),

          // Clues
          _Section(
            title: 'CLUES  (tap to reveal)',
            child: Column(
              children: game.clues.asMap().entries.map((e) {
                final c = e.value;
                return GestureDetector(
                  onTap: () =>
                      context.read<GameProvider>().findClue(c.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.isFound
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: c.isFound
                            ? AppColors.success.withOpacity(0.5)
                            : AppColors.surfaceLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          c.isFound
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: c.isFound
                              ? AppColors.success
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            c.isFound
                                ? c.text
                                : 'Tap to reveal clue ${e.key + 1}',
                            style: TextStyle(
                              color: c.isFound
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontStyle: c.isFound
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Cipher lock button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/levels'),
              icon: const Icon(Icons.search),
              label: const Text('OPEN WORD SEARCH CIPHER LOCK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Hint button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  context.read<GameProvider>().requestHint(),
              icon: const Icon(Icons.psychology, size: 18),
              label: const Text('ASK GAME MASTER FOR HINT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: BorderSide(
                    color: AppColors.accent.withOpacity(0.5)),
              ),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Badge(this.icon, this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(text,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

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
              if (won) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.accentBlue.withOpacity(0.4)),
                  ),
                  child: Column(children: [
                    const Text('PASSPHRASE',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text(game.passphrase ?? '',
                        style: const TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8)),
                  ]),
                ),
              ],
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
                      value: game.activeSession?.elapsedFormatted ??
                          '--'),
                  _ScoreRow(
                      label: 'HINTS',
                      value:
                          '${game.activeSession?.hintsUsed ?? 0}'),
                  _ScoreRow(
                      label: 'MISTAKES',
                      value:
                          '${game.activeSession?.wrongHighlights ?? 0}'),
                ],
              ),
              if (won) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    const Text('CHAPTER REVEAL',
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(game.activePuzzle?.storyReveal ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontStyle: FontStyle.italic,
                            height: 1.5)),
                  ]),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/', (_) => false),
                  icon: const Icon(Icons.home),
                  label: const Text('BACK TO MISSIONS'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/leaderboard'),
                child: const Text('VIEW LEADERBOARD',
                    style: TextStyle(
                        color: AppColors.textSecondary)),
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