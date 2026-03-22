// lib/models/hint_model.dart

enum HintType { story, wordSearch }

class Hint {
  final String id;
  final String puzzleId;
  final HintType type;
  final String text;
  final String reason;
  int priority;

  Hint({
    required this.id,
    required this.puzzleId,
    required this.type,
    required this.text,
    required this.reason,
    this.priority = 6,
  });

  Map<String, dynamic> toMap() => {
        'hint_id': id,
        'puzzle_id': puzzleId,
        'type': type.name,
        'text': text,
        'reason': reason,
        'priority': priority,
      };

  factory Hint.fromMap(Map<String, dynamic> m) => Hint(
        id: m['hint_id'] as String,
        puzzleId: m['puzzle_id'] as String,
        type: (m['type'] as String) == 'story' ? HintType.story : HintType.wordSearch,
        text: m['text'] as String,
        reason: m['reason'] as String,
        priority: m['priority'] as int? ?? 6,
      );
}

class HintResult {
  final Hint hint;
  final String displayReason;
  HintResult({required this.hint, required this.displayReason});
}