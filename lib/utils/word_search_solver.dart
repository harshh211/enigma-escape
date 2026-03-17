// lib/utils/word_search_solver.dart

import 'package:flutter/foundation.dart';

@immutable
class GridCell {
  final int row;
  final int col;
  const GridCell(this.row, this.col);

  @override
  bool operator ==(Object other) => other is GridCell && other.row == row && other.col == col;
  @override
  int get hashCode => Object.hash(row, col);
  @override
  String toString() => '($row,$col)';
}

class WordMatch {
  final String word;
  final List<GridCell> cells;
  WordMatch({required this.word, required this.cells});
}

class WordSearchSolver {
  // All 8 directions: [dRow, dCol]
  static const List<List<int>> _dirs = [
    [0, 1],   // right
    [0, -1],  // left
    [1, 0],   // down
    [-1, 0],  // up
    [1, 1],   // down-right
    [1, -1],  // down-left
    [-1, 1],  // up-right
    [-1, -1], // up-left
  ];

  /// Find a word anywhere in the grid. Returns null if not found.
  static WordMatch? findWord(List<List<String>> grid, String word) {
    final rows = grid.length;
    final cols = grid[0].length;
    final upper = word.toUpperCase();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c].toUpperCase() != upper[0]) continue;
        for (final d in _dirs) {
          final cells = <GridCell>[];
          var ok = true;
          for (int i = 0; i < upper.length; i++) {
            final nr = r + d[0] * i;
            final nc = c + d[1] * i;
            if (nr < 0 || nr >= rows || nc < 0 || nc >= cols ||
                grid[nr][nc].toUpperCase() != upper[i]) {
              ok = false;
              break;
            }
            cells.add(GridCell(nr, nc));
          }
          if (ok) return WordMatch(word: upper, cells: cells);
        }
      }
    }
    return null;
  }

  /// Given selected cells, return the matching word name or null.
  static String? matchSelected(
      List<List<String>> grid, List<GridCell> selected, List<String> candidates) {
    if (selected.isEmpty) return null;
    for (final word in candidates) {
      final match = findWord(grid, word);
      if (match == null) continue;
      if (match.cells.length != selected.length) continue;
      final a = match.cells.toSet();
      final b = selected.toSet();
      if (a.containsAll(b) && b.containsAll(a)) return word.toUpperCase();
    }
    return null;
  }

  /// Build passphrase from first letter of each found word in order.
  static String buildPassphrase(List<String> words) =>
      words.map((w) => w[0].toUpperCase()).join();

  /// All cells that belong to any of the found words (for highlighting).
  static Set<GridCell> foundCells(List<List<String>> grid, Set<String> foundWords) {
    final cells = <GridCell>{};
    for (final w in foundWords) {
      final m = findWord(grid, w);
      if (m != null) cells.addAll(m.cells);
    }
    return cells;
  }
}