import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/timer_widget.dart';

class ColorCascadeScreen extends StatefulWidget {
  const ColorCascadeScreen({super.key});

  @override
  State<ColorCascadeScreen> createState() => _ColorCascadeScreenState();
}
void _confirmBack(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Return to briefing?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Your level progress will be lost.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('STAY',
                  style: TextStyle(color: AppColors.accent))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/mission', (_) => false);
              },
              child: const Text('GO BACK',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
class _ColorCascadeScreenState extends State<ColorCascadeScreen> {
  static const _colorMap = {
    'red':    Color(0xFFE05555),
    'blue':   Color(0xFF5588E0),
    'green':  Color(0xFF50C878),
    'yellow': Color(0xFFE8B86D),
    'purple': Color(0xFFB86DE8),
  };

  late List<String> _leftColors;
  late List<String> _rightColors;

  // connections[leftIndex] = rightIndex or null
  Map<int, int> _connections = {};
  int? _draggingFrom;
  bool _checked = false;
  bool _won = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    final puzzle = context.read<GameProvider>().activePuzzle!;
    final colors = puzzle.colorCascade.colors.take(4).toList();
    _leftColors = colors;
    _rightColors = [...colors]..shuffle();
  }

  void _checkConnections() {
    bool allCorrect = true;
    for (int i = 0; i < _leftColors.length; i++) {
      final connectedRight = _connections[i];
      if (connectedRight == null ||
          _rightColors[connectedRight] != _leftColors[i]) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      _checked = true;
      _won = allCorrect;
      if (!allCorrect) _attempts++;
    });

    if (allCorrect) {
      Future.delayed(const Duration(milliseconds: 600), () {
        final code = context
            .read<GameProvider>()
            .activePuzzle!
            .colorCascade
            .code;
        context.read<GameProvider>().completeLevel(code);
      });
    }
  }

  void _reset() {
    setState(() {
      _connections = {};
      _checked = false;
      _won = false;
      _rightColors = [..._leftColors]..shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            title: const Text('LEVEL 2 — WIRE MATCH'),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _confirmBack(context),
            ),
      ),
      body: Column(
        children: [
          const LevelTimerBar(),
          // Instruction bar
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const Text(
                  'Connect each color on the left to its match on the right.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                if (_checked) ...[
                  const SizedBox(height: 8),
                  Text(
                    _won
                        ? '✓ All wires connected! Code unlocked!'
                        : '✗ Wrong connections — try again!',
                    style: TextStyle(
                      color: _won ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Game area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Left column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _leftColors.asMap().entries.map((e) {
                      final idx = e.key;
                      final color = _colorMap[e.value]!;
                      final isConnected = _connections.containsKey(idx);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _draggingFrom = idx;
                            _checked = false;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: _draggingFrom == idx
                                  ? Colors.white
                                  : isConnected
                                      ? Colors.white.withOpacity(0.6)
                                      : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: _draggingFrom == idx
                              ? const Icon(Icons.radio_button_checked,
                                  color: Colors.white, size: 28)
                              : isConnected
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 24)
                                  : null,
                        ),
                      );
                    }).toList(),
                  ),

                  // Lines in the middle
                  Expanded(
                    child: CustomPaint(
                      painter: _WirePainter(
                        connections: _connections,
                        leftColors: _leftColors,
                        rightColors: _rightColors,
                        colorMap: _colorMap,
                        itemCount: _leftColors.length,
                      ),
                    ),
                  ),

                  // Right column
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _rightColors.asMap().entries.map((e) {
                      final idx = e.key;
                      final color = _colorMap[e.value]!;
                      final isConnectedTo = _connections.values.contains(idx);

                      return GestureDetector(
                        onTap: () {
                          if (_draggingFrom != null) {
                            setState(() {
                              // Remove any existing connection to this right node
                              _connections.removeWhere(
                                  (k, v) => v == idx);
                              _connections[_draggingFrom!] = idx;
                              _draggingFrom = null;
                              _checked = false;
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: isConnectedTo
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: isConnectedTo
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 24)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          if (_draggingFrom != null)
            Container(
              color: AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _colorMap[_leftColors[_draggingFrom!]],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Now tap the matching color on the right',
                      style: TextStyle(
                          color: AppColors.primary, fontSize: 13)),
                ],
              ),
            ),

          // Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              children: [
                if (_attempts > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Attempts: $_attempts',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                  ),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('RESET'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _connections.length < _leftColors.length
                          ? null
                          : _checkConnections,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('CHECK WIRES'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Draws lines between connected nodes
class _WirePainter extends CustomPainter {
  final Map<int, int> connections;
  final List<String> leftColors;
  final List<String> rightColors;
  final Map<String, Color> colorMap;
  final int itemCount;

  _WirePainter({
    required this.connections,
    required this.leftColors,
    required this.rightColors,
    required this.colorMap,
    required this.itemCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final itemHeight = size.height / itemCount;

    connections.forEach((leftIdx, rightIdx) {
      final color = colorMap[leftColors[leftIdx]] ?? Colors.white;
      final paint = Paint()
        ..color = color.withOpacity(0.8)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      final startY = itemHeight * leftIdx + itemHeight / 2;
      final endY = itemHeight * rightIdx + itemHeight / 2;

      final path = Path()
        ..moveTo(0, startY)
        ..cubicTo(
          size.width * 0.4, startY,
          size.width * 0.6, endY,
          size.width, endY,
        );

      canvas.drawPath(path, paint);
    });
  }

  @override
  bool shouldRepaint(_WirePainter old) => true;
}