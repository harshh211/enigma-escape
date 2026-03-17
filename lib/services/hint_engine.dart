// On-device, rule-based AI hint engine.
// NO cloud APIs — reads only from local SQLite.
// Two hint modes: Story (narrative) and Word Search (directional).

import '../models/hint_model.dart';
import 'database_helper.dart';

class HintEngine {
  static final HintEngine instance = HintEngine._();
  HintEngine._();

  final Map<String, DateTime> _lastActivity = {};
  final Map<String, int> _wrongStreak = {};
  final Map<String, Set<String>> _usedHintIds = {};

  void recordActivity(String sessionId) {
    _lastActivity[sessionId] = DateTime.now();
  }

  void recordWrong(String sessionId) {
    _wrongStreak[sessionId] = (_wrongStreak[sessionId] ?? 0) + 1;
  }

  void resetWrongStreak(String sessionId) {
    _wrongStreak[sessionId] = 0;
  }

  /// Returns true if the engine should auto-suggest a hint.
  bool shouldAutoTrigger(String sessionId) {
    final wrong = _wrongStreak[sessionId] ?? 0;
    if (wrong >= 3) return true;
    final last = _lastActivity[sessionId];
    if (last != null &&
        DateTime.now().difference(last).inSeconds >= 120) return true;
    return false;
  }

  /// Core selection logic:
  /// 1. Classify hint type based on wrong streak vs idle
  /// 2. Query SQLite for highest-priority unused hint of that type
  /// 3. Mark it used, build a readable reason string
  Future<HintResult?> selectHint({
    required String sessionId,
    required String puzzleId,
    required int cluesFound,
    required int totalClues,
    required int wordsFound,
  }) async {
    final wrong = _wrongStreak[sessionId] ?? 0;
    final last = _lastActivity[sessionId];
    final idleMin = last != null
        ? DateTime.now().difference(last).inMinutes
        : 0;

    final preferredType =
        wrong >= 2 ? HintType.wordSearch : HintType.story;
    final used = _usedHintIds[sessionId] ?? {};

    Hint? selected;
    for (final type in [
      preferredType,
      preferredType == HintType.wordSearch
          ? HintType.story
          : HintType.wordSearch
    ]) {
      final hints = await DatabaseHelper.instance
          .getHintsForPuzzle(puzzleId, type: type);
      final available =
          hints.where((h) => !used.contains(h.id)).toList();
      if (available.isNotEmpty) {
        selected = available.first;
        break;
      }
    }

    if (selected == null) return null;

    _usedHintIds[sessionId] = {...used, selected.id};

    final reason = selected.type == HintType.wordSearch
        ? 'Based on $wrong wrong highlight${wrong != 1 ? 's' : ''}${idleMin > 0 ? ' and ${idleMin}min idle' : ''}'
        : 'Based on $cluesFound of $totalClues clues found${idleMin > 0 ? ' and ${idleMin}min idle' : ''}';

    return HintResult(hint: selected, displayReason: reason);
  }

  Future<void> rateHint(String hintId, bool thumbsUp) async {
    await DatabaseHelper.instance
        .adjustHintPriority(hintId, thumbsUp ? 1 : -1);
  }

  void clearSession(String sessionId) {
    _lastActivity.remove(sessionId);
    _wrongStreak.remove(sessionId);
    _usedHintIds.remove(sessionId);
  }
}