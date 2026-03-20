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

class PuzzleLevel {
  final int level;
  final String type;
  final String title;
  final String instruction;

  PuzzleLevel({
    required this.level,
    required this.type,
    required this.title,
    required this.instruction,
  });

  factory PuzzleLevel.fromJson(Map<String, dynamic> j) => PuzzleLevel(
        level: j['level'] as int? ?? 0,
        type: j['type'] as String? ?? '',
        title: j['title'] as String? ?? '',
        instruction: j['instruction'] as String? ?? '',
      );
}

class InterrogationQuestion {
  final String question;
  final List<String> options;
  final int correct;

  InterrogationQuestion({
    required this.question,
    required this.options,
    required this.correct,
  });

  factory InterrogationQuestion.fromJson(Map<String, dynamic> j) =>
      InterrogationQuestion(
        question: j['question'] as String,
        options: List<String>.from(j['options'] as List),
        correct: j['correct'] as int,
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

class ColorCascadeData {
  final int gridSize;
  final List<String> colors;
  final int movesAllowed;
  final String code;

  ColorCascadeData({
    required this.gridSize,
    required this.colors,
    required this.movesAllowed,
    required this.code,
  });

  factory ColorCascadeData.fromJson(Map<String, dynamic> j) => ColorCascadeData(
        gridSize: j['grid_size'] as int,
        colors: List<String>.from(j['colors'] as List),
        movesAllowed: j['moves_allowed'] as int,
        code: j['code'] as String,
      );
}

class InterrogationData {
  final List<InterrogationQuestion> questions;
  final String code;

  InterrogationData({required this.questions, required this.code});

  factory InterrogationData.fromJson(Map<String, dynamic> j) => InterrogationData(
        questions: (j['questions'] as List<dynamic>)
            .map((q) => InterrogationQuestion.fromJson(q as Map<String, dynamic>))
            .toList(),
        code: j['code'] as String,
      );
}

class MemoryGridData {
  final int gridSize;
  final int sequenceLength;
  final List<int> sequence;
  final String code;

  MemoryGridData({
    required this.gridSize,
    required this.sequenceLength,
    required this.sequence,
    required this.code,
  });

  factory MemoryGridData.fromJson(Map<String, dynamic> j) => MemoryGridData(
        gridSize: j['grid_size'] as int,
        sequenceLength: j['sequence_length'] as int,
        sequence: List<int>.from(j['sequence'] as List),
        code: j['code'] as String,
      );
}

class DecodeMapData {
  final List<int> correctOrder;
  final String code;

  DecodeMapData({
    required this.correctOrder,
    required this.code,
  });

  factory DecodeMapData.fromJson(Map<String, dynamic> j) => DecodeMapData(
        correctOrder: List<int>.from(j['correct_order'] as List? ?? []),
        code: j['code'] as String? ?? '',
      );
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
  final List<PuzzleLevel> levels;
  final List<Clue> clues;
  final WordSearchPuzzle wordsearch;
  final ColorCascadeData colorCascade;
  final InterrogationData interrogation;
  final MemoryGridData memoryGrid;
  final DecodeMapData decodeMap;
  final String finalPassphrase;
  final String storyReveal;
  final List<String> chapterReveals;
  final Achievement achievement;
  final List<Achievement> levelAchievements;

  Puzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.timeLimitSec,
    required this.chapterId,
    required this.levels,
    required this.clues,
    required this.wordsearch,
    required this.colorCascade,
    required this.interrogation,
    required this.memoryGrid,
    required this.decodeMap,
    required this.finalPassphrase,
    required this.storyReveal,
    required this.chapterReveals,
    required this.achievement,
     required this.levelAchievements,
  });

  factory Puzzle.fromJson(Map<String, dynamic> j) => Puzzle(
       id: j['id'] as String? ?? '',
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        difficulty: j['difficulty'] as String? ?? 'easy',
        timeLimitSec: j['time_limit_sec'] as int? ?? 360,
        chapterId: j['chapter_id'] as int? ?? 1,
        levels: (j['levels'] as List<dynamic>)
            .map((l) => PuzzleLevel.fromJson(l as Map<String, dynamic>))
            .toList(),
        clues: (j['clues'] as List<dynamic>)
            .map((c) => Clue.fromJson(c as Map<String, dynamic>))
            .toList(),
        wordsearch: WordSearchPuzzle.fromJson(j['wordsearch'] as Map<String, dynamic>),
        colorCascade: ColorCascadeData.fromJson(j['color_cascade'] as Map<String, dynamic>),
        interrogation: InterrogationData.fromJson(j['interrogation'] as Map<String, dynamic>),
        memoryGrid: MemoryGridData.fromJson(j['memory_grid'] as Map<String, dynamic>),
        decodeMap: DecodeMapData.fromJson(j['decode_map'] as Map<String, dynamic>),
        finalPassphrase: j['final_passphrase'] as String? ?? '',
        storyReveal: j['story_reveal'] as String? ?? '',
        chapterReveals: List<String>.from(j['chapter_reveals'] as List? ?? []),
        achievement: Achievement.fromJson(j['achievement'] as Map<String, dynamic>),
        levelAchievements: (j['level_achievements'] as List<dynamic>? ?? [])
            .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
}