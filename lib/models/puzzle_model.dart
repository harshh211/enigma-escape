// lib/models/puzzle_model.dart

class Clue {
  final String id;
  final String text;
  bool isFound;
  DateTime? foundAt;

  Clue({required this.id, required this.text, this.isFound = false, this.foundAt});

  factory Clue.fromJson(Map<String, dynamic> j) =>
      Clue(id: j['id'] as String, text: j['text'] as String);

  Clue copyWith({bool? isFound, DateTime? foundAt}) => Clue(
        id: id,
        text: text,
        isFound: isFound ?? this.isFound,
        foundAt: foundAt ?? this.foundAt,
      );
}

class HintStart {
  final String word;
  final int row;
  final int col;
  final String direction;

  HintStart({required this.word, required this.row, required this.col, required this.direction});

  factory HintStart.fromJson(Map<String, dynamic> j) => HintStart(
        word: j['word'] as String,
        row: j['row'] as int,
        col: j['col'] as int,
        direction: j['direction'] as String,
      );
}

class WordSearchPuzzle {
  final String id;
  final int gridSize;
  final List<List<String>> grid;
  final List<String> words;
  final List<String> correctSequence;
  final String passphrase;
  final List<HintStart> hintStarts;

  WordSearchPuzzle({
    required this.id,
    required this.gridSize,
    required this.grid,
    required this.words,
    required this.correctSequence,
    required this.passphrase,
    required this.hintStarts,
  });

  factory WordSearchPuzzle.fromJson(Map<String, dynamic> j) {
    final rawGrid = j['grid'] as List<dynamic>;
    final grid = rawGrid
        .map((row) => (row as List<dynamic>).map((c) => c.toString()).toList())
        .toList();
    return WordSearchPuzzle(
      id: j['id'] as String,
      gridSize: j['grid_size'] as int,
      grid: grid,
      words: List<String>.from(j['words'] as List),
      correctSequence: List<String>.from(j['correct_sequence'] as List),
      passphrase: j['passphrase'] as String,
      hintStarts: (j['hint_starts'] as List<dynamic>)
          .map((h) => HintStart.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> j) =>
      Achievement(id: j['id'] as String, name: j['name'] as String, description: j['description'] as String);

  factory Achievement.fromMap(Map<String, dynamic> m) => Achievement(
        id: m['achievement_id'] as String,
        name: m['name'] as String,
        description: m['description'] as String,
        isUnlocked: (m['is_unlocked'] as int? ?? 0) == 1,
        unlockedAt: m['unlocked_at'] != null ? DateTime.tryParse(m['unlocked_at'] as String) : null,
      );
}

class Puzzle {
  final String id;
  final String title;
  final String description;
  final String difficulty;
  final int timeLimitSec;
  final int chapterId;
  final List<Clue> clues;
  final WordSearchPuzzle wordsearch;
  final String storyReveal;
  final Achievement achievement;

  Puzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.timeLimitSec,
    required this.chapterId,
    required this.clues,
    required this.wordsearch,
    required this.storyReveal,
    required this.achievement,
  });

  factory Puzzle.fromJson(Map<String, dynamic> j) => Puzzle(
        id: j['id'] as String,
        title: j['title'] as String,
        description: j['description'] as String,
        difficulty: j['difficulty'] as String,
        timeLimitSec: j['time_limit_sec'] as int,
        chapterId: j['chapter_id'] as int,
        clues: (j['clues'] as List<dynamic>)
            .map((c) => Clue.fromJson(c as Map<String, dynamic>))
            .toList(),
        wordsearch: WordSearchPuzzle.fromJson(j['wordsearch'] as Map<String, dynamic>),
        storyReveal: j['story_reveal'] as String,
        achievement: Achievement.fromJson(j['achievement'] as Map<String, dynamic>),
      );
}