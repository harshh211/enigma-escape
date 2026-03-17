// lib/models/session_model.dart

class GameSession {
  final String sessionId;
  final String teamName;
  final String puzzleId;
  final DateTime startTime;
  DateTime? endTime;
  int score;
  int hintsUsed;
  int wrongHighlights;
  bool isCompleted;

  GameSession({
    required this.sessionId,
    required this.teamName,
    required this.puzzleId,
    required this.startTime,
    this.endTime,
    this.score = 0,
    this.hintsUsed = 0,
    this.wrongHighlights = 0,
    this.isCompleted = false,
  });

  int calculateScore(int timeLimitSec) {
    final elapsed = endTime != null
        ? endTime!.difference(startTime).inSeconds
        : timeLimitSec;
    final timeBonus = ((timeLimitSec - elapsed) / timeLimitSec * 500).round().clamp(0, 500);
    final penalty = (hintsUsed * 30) + (wrongHighlights * 20);
    return (500 + timeBonus - penalty).clamp(0, 1000);
  }

  Map<String, dynamic> toMap() => {
        'session_id': sessionId,
        'team_name': teamName,
        'puzzle_id': puzzleId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'score': score,
        'hints_used': hintsUsed,
        'wrong_highlights': wrongHighlights,
        'is_completed': isCompleted ? 1 : 0,
      };

  factory GameSession.fromMap(Map<String, dynamic> m) => GameSession(
        sessionId: m['session_id'] as String,
        teamName: m['team_name'] as String,
        puzzleId: m['puzzle_id'] as String,
        startTime: DateTime.parse(m['start_time'] as String),
        endTime: m['end_time'] != null ? DateTime.tryParse(m['end_time'] as String) : null,
        score: m['score'] as int? ?? 0,
        hintsUsed: m['hints_used'] as int? ?? 0,
        wrongHighlights: m['wrong_highlights'] as int? ?? 0,
        isCompleted: (m['is_completed'] as int? ?? 0) == 1,
      );

  String get elapsedFormatted {
    if (endTime == null) return '00:00';
    final s = endTime!.difference(startTime).inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}