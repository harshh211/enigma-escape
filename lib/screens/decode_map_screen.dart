import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class DecodeMapScreen extends StatefulWidget {
  const DecodeMapScreen({super.key});

  @override
  State<DecodeMapScreen> createState() => _DecodeMapScreenState();
}

class _DecodeMapScreenState extends State<DecodeMapScreen> {
  late List<int> _currentOrder;
  late List<String> _pieceLabels;
  late List<int> _correctOrder;
  bool _checked = false;
  bool _correct = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    final data =
        context.read<GameProvider>().activePuzzle!.decodeMap;
    _pieceLabels = data.pieceLabels;
    _correctOrder = data.correctOrder;
    // Start with pieces in wrong order
    _currentOrder = List.generate(_pieceLabels.length, (i) => i);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      _checked = false;
      final item = _currentOrder.removeAt(oldIndex);
      _currentOrder.insert(newIndex, item);
    });
  }

  void _checkOrder() {
    final isCorrect =
        _currentOrder.toString() == _correctOrder.toString();
    setState(() {
      _checked = true;
      _correct = isCorrect;
      if (!isCorrect) _attempts++;
    });

    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 600), () {
        final code = context
            .read<GameProvider>()
            .activePuzzle!
            .decodeMap
            .code;
        context.read<GameProvider>().completeLevel(code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEVEL 5 — DECODE THE MAP'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Instruction
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.map,
                    color: AppColors.primary, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Drag the map pieces into the correct order\nto reveal the escape route.',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                if (_checked) ...[
                  const SizedBox(height: 8),
                  Text(
                    _correct
                        ? '✓ Correct order! Escape route revealed!'
                        : '✗ Wrong order — try again!',
                    style: TextStyle(
                      color:
                          _correct ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Draggable list
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentOrder.length,
              onReorder: _onReorder,
              itemBuilder: (context, idx) {
                final pieceIdx = _currentOrder[idx];
                final label = _pieceLabels[pieceIdx];

                Color borderColor = AppColors.surfaceLight;
                Color iconColor = AppColors.textSecondary;

                if (_checked) {
                  if (_correct) {
                    borderColor = AppColors.success;
                    iconColor = AppColors.success;
                  } else {
                    borderColor =
                        _currentOrder[idx] == _correctOrder[idx]
                            ? AppColors.success
                            : AppColors.error;
                    iconColor =
                        _currentOrder[idx] == _correctOrder[idx]
                            ? AppColors.success
                            : AppColors.error;
                  }
                }

                return Container(
                  key: ValueKey(pieceIdx),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      // Step number
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.15),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Map icon
                      Icon(Icons.place, color: iconColor, size: 22),
                      const SizedBox(width: 10),
                      // Label
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Drag handle
                      const Icon(Icons.drag_handle,
                          color: AppColors.textSecondary),
                    ],
                  ),
                );
              },
            ),
          ),

          // Check button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _correct ? null : _checkOrder,
                    icon: const Icon(Icons.check),
                    label: const Text('CHECK ORDER'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _correct
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}