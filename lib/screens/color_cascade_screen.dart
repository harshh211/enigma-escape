import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class ColorCascadeScreen extends StatefulWidget {
  const ColorCascadeScreen({super.key});

  @override
  State<ColorCascadeScreen> createState() => _ColorCascadeScreenState();
}

class _ColorCascadeScreenState extends State<ColorCascadeScreen> {
  static const _colorMap = {
    'red':    Color(0xFFE05555),
    'blue':   Color(0xFF5588E0),
    'green':  Color(0xFF50C878),
    'yellow': Color(0xFFE8B86D),
    'purple': Color(0xFFB86DE8),
  };

  late List<List<String?>> _grid;
  late int _gridSize;
  late List<String> _colorList;
  late int _movesLeft;
  late int _movesAllowed;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    final puzzle = context.read<GameProvider>().activePuzzle!;
    final data = puzzle.colorCascade;
    _gridSize = data.gridSize;
    _colorList = data.colors;
    _movesAllowed = data.movesAllowed;
    _movesLeft = _movesAllowed;
    _grid = _generateGrid();
  }

  List<List<String?>> _generateGrid() {
    final rng = Random(42); // fixed seed so grid is consistent
    return List.generate(
      _gridSize,
      (_) => List.generate(
        _gridSize,
        (_) => _colorList[rng.nextInt(_colorList.length)],
      ),
    );
  }

  // Find all connected cells of same color starting from (r,c)
  Set<String> _findGroup(int r, int c) {
    final color = _grid[r][c];
    if (color == null) return {};
    final visited = <String>{};
    final queue = ['$r,$c'];
    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      if (visited.contains(pos)) continue;
      visited.add(pos);
      final parts = pos.split(',');
      final row = int.parse(parts[0]);
      final col = int.parse(parts[1]);
      for (final d in [[-1,0],[1,0],[0,-1],[0,1]]) {
        final nr = row + d[0];
        final nc = col + d[1];
        if (nr >= 0 && nr < _gridSize && nc >= 0 && nc < _gridSize &&
            _grid[nr][nc] == color && !visited.contains('$nr,$nc')) {
          queue.add('$nr,$nc');
        }
      }
    }
    return visited;
  }

  void _onTap(int r, int c) {
    if (_won || _movesLeft <= 0 || _grid[r][c] == null) return;
    final group = _findGroup(r, c);
    if (group.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need at least 3 connected tiles!'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      // Clear the group
      for (final pos in group) {
        final parts = pos.split(',');
        _grid[int.parse(parts[0])][int.parse(parts[1])] = null;
      }
      // Drop tiles down
      for (int col = 0; col < _gridSize; col++) {
        final tiles = <String?>[];
        for (int row = _gridSize - 1; row >= 0; row--) {
          if (_grid[row][col] != null) tiles.add(_grid[row][col]);
        }
        for (int row = _gridSize - 1; row >= 0; row--) {
          _grid[row][col] = row < _gridSize - tiles.length
              ? null
              : tiles[row - (_gridSize - tiles.length)];
        }
      }
      _movesLeft--;
      _won = _checkWin();
    });

    if (_won) {
      Future.delayed(const Duration(milliseconds: 500), () {
        final code = context.read<GameProvider>().activePuzzle!.colorCascade.code;
        context.read<GameProvider>().completeLevel(code);
      });
    }
  }

  bool _checkWin() {
    for (final row in _grid) {
      for (final cell in row) {
        if (cell != null) return false;
      }
    }
    return true;
  }

  int _countRemaining() {
    int count = 0;
    for (final row in _grid) {
      for (final cell in row) {
        if (cell != null) count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _countRemaining();
    final total = _gridSize * _gridSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 2 — COLOR CASCADE'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('MOVES LEFT', '$_movesLeft',
                    _movesLeft < 5 ? AppColors.error : AppColors.primary),
                _Stat('TILES LEFT', '$remaining', AppColors.accentBlue),
                _Stat('CLEARED',
                    '${total - remaining}', AppColors.success),
              ],
            ),
          ),

          // Instruction
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: const Text(
              'Tap groups of 3+ matching colors to clear them. Clear the board to get the code!',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSize,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: _gridSize * _gridSize,
                  itemBuilder: (context, idx) {
                    final r = idx ~/ _gridSize;
                    final c = idx % _gridSize;
                    final color = _grid[r][c];

                    return GestureDetector(
                      onTap: () => _onTap(r, c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: color != null
                              ? _colorMap[color]
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color != null
                                ? (_colorMap[color] ?? AppColors.surface)
                                    .withOpacity(0.5)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Out of moves
          if (_movesLeft <= 0 && !_won)
            Container(
              width: double.infinity,
              color: AppColors.error.withOpacity(0.15),
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                const Text('Out of moves!',
                    style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _grid = _generateGrid();
                    _movesLeft = _movesAllowed;
                    _won = false;
                  }),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error),
                  child: const Text('TRY AGAIN'),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  color: AppColors.textSecondary)),
        ],
      );
}