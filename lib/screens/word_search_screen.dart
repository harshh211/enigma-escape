import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../utils/word_search_solver.dart';
import '../widgets/hint_overlay.dart';
import '../widgets/timer_widget.dart';

class WordSearchScreen extends StatelessWidget {
  final bool embedded;
  const WordSearchScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final puzzle = game.activePuzzle;

    if (puzzle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('CIPHER LOCK')),
        body: const Center(
            child: Text('No active puzzle.',
                style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final ws = puzzle.wordsearch;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('LEVEL 1 — WORD SEARCH'),
            automaticallyImplyLeading: false,
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${game.foundWords.length}/${ws.words.length} found',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              const LevelTimerBar(),

              // Instruction bar
              Container(
                width: double.infinity,
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: const Text(
                  'Find the 5 hidden words in the grid.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),

              // Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _Grid(
                    grid: ws.grid,
                    size: ws.gridSize,
                    foundWords: game.foundWords,
                    selectedCells: game.selectedCells,
                    onTap: (cell) =>
                        context.read<GameProvider>().toggleCell(cell),
                  ),
                ),
              ),

              // Word chips
              Container(
                height: 72,
                color: AppColors.surface,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  itemCount: ws.words.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final word = ws.words[i].toUpperCase();
                    final found = game.foundWords.contains(word);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: found
                            ? AppColors.cellFound.withOpacity(0.18)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: found
                              ? AppColors.cellFound
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        word,
                        style: TextStyle(
                          color: found
                              ? AppColors.cellFound
                              : AppColors.textSecondary,
                          fontWeight: found
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                          decoration: found
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                child: Column(children: [
                  // Hint button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showHintPassage(context, ws.words),
                      icon: const Icon(Icons.lightbulb_outline,
                          size: 16),
                      label: const Text('HINT — VIEW PASSAGE'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                            color: AppColors.primary.withOpacity(0.4)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            context.read<GameProvider>().clearSelection(),
                        child: const Text('CLEAR'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: game.selectedCells.isEmpty
                            ? null
                            : () => context
                                .read<GameProvider>()
                                .submitSelection(),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('SUBMIT WORD'),
                      ),
                    ),
                  ]),
                ]),
              ),
            ],
          ),
        ),
        if (game.showHint)
          const Positioned.fill(child: HintOverlay()),
      ],
    );
  }

  void _showHintPassage(BuildContext context, List<String> words) {
    final passage =
        context.read<GameProvider>().activePuzzle!.description;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.lightbulb, color: AppColors.primary, size: 20),
          SizedBox(width: 8),
          Text('PASSAGE HINT',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ]),
        content: SingleChildScrollView(
          child: _HighlightedPassage(
              passage: passage, words: words),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}


class _Grid extends StatelessWidget {
  final List<List<String>> grid;
  final int size;
  final Set<String> foundWords;
  final List<GridCell> selectedCells;
  final ValueChanged<GridCell> onTap;

  const _Grid({
    required this.grid,
    required this.size,
    required this.foundWords,
    required this.selectedCells,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = WordSearchSolver.foundCells(grid, foundWords);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size,
        childAspectRatio: 1,
      ),
      itemCount: size * size,
      itemBuilder: (_, idx) {
        final row = idx ~/ size;
        final col = idx % size;
        final cell = GridCell(row, col);
        final letter = grid[row][col].toUpperCase();

        final isFound = highlighted.contains(cell);
        final isSelected = selectedCells.contains(cell);

        final Color bg;
        final Color fg;
        if (isFound) {
          bg = AppColors.cellFound.withOpacity(0.28);
          fg = AppColors.cellFound;
        } else if (isSelected) {
          bg = AppColors.cellSelected.withOpacity(0.45);
          fg = Colors.white;
        } else {
          bg = AppColors.cellDefault;
          fg = AppColors.textPrimary;
        }

        return GestureDetector(
          onTap: () => onTap(cell),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
              border: isSelected
                  ? Border.all(
                      color: AppColors.cellSelected, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.bold,
                  fontSize: size > 8 ? 11 : 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class _HighlightedPassage extends StatelessWidget {
  final String passage;
  final List<String> words;

  const _HighlightedPassage(
      {required this.passage, required this.words});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final upper = passage.toUpperCase();
    int current = 0;

    
    final List<_WordPos> positions = [];
    for (final word in words) {
      int idx = upper.indexOf(word.toUpperCase());
      while (idx != -1) {
        positions.add(_WordPos(idx, idx + word.length, word));
        idx = upper.indexOf(word.toUpperCase(), idx + 1);
      }
    }
    positions.sort((a, b) => a.start.compareTo(b.start));

    
    final List<_WordPos> clean = [];
    for (final p in positions) {
      if (clean.isEmpty || p.start >= clean.last.end) {
        clean.add(p);
      }
    }

    
    for (final pos in clean) {
      if (current < pos.start) {
        spans.add(TextSpan(
          text: passage.substring(current, pos.start),
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6),
        ));
      }
      spans.add(TextSpan(
        text: passage.substring(pos.start, pos.end),
        style: const TextStyle(
          color: AppColors.background,
          backgroundColor: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 1.6,
        ),
      ));
      current = pos.end;
    }

    if (current < passage.length) {
      spans.add(TextSpan(
        text: passage.substring(current),
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _WordPos {
  final int start;
  final int end;
  final String word;
  _WordPos(this.start, this.end, this.word);
}