// lib/services/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/session_model.dart';
import '../models/puzzle_model.dart';
import '../models/hint_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;
  DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDB('enigma_rooms.db');
    return _db!;
  }

  Future<Database> _initDB(String name) async {
    final path = join(await getDatabasesPath(), name);
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE puzzles (
        puzzle_id      TEXT PRIMARY KEY,
        title          TEXT NOT NULL,
        description    TEXT NOT NULL,
        difficulty     TEXT NOT NULL,
        time_limit_sec INTEGER NOT NULL,
        chapter_id     INTEGER NOT NULL,
        wordsearch_id  TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE wordsearch_puzzles (
        ws_id            TEXT PRIMARY KEY,
        grid_size        INTEGER NOT NULL,
        grid_data        TEXT NOT NULL,
        word_list        TEXT NOT NULL,
        correct_sequence TEXT NOT NULL,
        passphrase       TEXT NOT NULL,
        hint_starts      TEXT NOT NULL
      )''');

    await db.execute('''
      CREATE TABLE sessions (
        session_id       TEXT PRIMARY KEY,
        team_name        TEXT NOT NULL,
        puzzle_id        TEXT NOT NULL,
        start_time       TEXT NOT NULL,
        end_time         TEXT,
        score            INTEGER DEFAULT 0,
        hints_used       INTEGER DEFAULT 0,
        wrong_highlights INTEGER DEFAULT 0,
        is_completed     INTEGER DEFAULT 0
      )''');

    await db.execute('''
      CREATE TABLE clues (
        clue_id    TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        puzzle_id  TEXT NOT NULL,
        clue_text  TEXT NOT NULL,
        is_found   INTEGER DEFAULT 0,
        found_at   TEXT
      )''');

    await db.execute('''
      CREATE TABLE achievements (
        achievement_id TEXT PRIMARY KEY,
        name           TEXT NOT NULL,
        description    TEXT NOT NULL,
        puzzle_id      TEXT NOT NULL,
        is_unlocked    INTEGER DEFAULT 0,
        unlocked_at    TEXT
      )''');

    await db.execute('''
      CREATE TABLE hints (
        hint_id   TEXT PRIMARY KEY,
        puzzle_id TEXT NOT NULL,
        type      TEXT NOT NULL,
        text      TEXT NOT NULL,
        reason    TEXT NOT NULL,
        priority  INTEGER DEFAULT 5
      )''');

      // new add may cahneg 
      await db.insert('hints', {
      'hint_id': 'level6_hint1',
      'puzzle_id': 'puzzle_001',
      'type': 'wordSearch',
      'text': 'The number is between 1 - 5.',
      'reason': 'Level 6 hint',
      'priority': 10,
});
  }

  // ── Sessions ───────────────────────────────────────────────────────────────

  Future<void> insertSession(GameSession s) async {
    final db = await database;
    await db.insert('sessions', s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSession(GameSession s) async {
    final db = await database;
    await db.update('sessions', s.toMap(),
        where: 'session_id = ?', whereArgs: [s.sessionId]);
  }

  Future<List<GameSession>> getTopSessions({int limit = 25}) async {
    final db = await database;
    final rows = await db.query('sessions',
        where: 'is_completed = 1', orderBy: 'score DESC', limit: limit);
    return rows.map(GameSession.fromMap).toList();
  }

  // ── Clues ──────────────────────────────────────────────────────────────────

  Future<void> insertClue(String sessionId, String puzzleId, Clue c) async {
    final db = await database;
    await db.insert('clues', {
      'clue_id': '${sessionId}_${c.id}',
      'session_id': sessionId,
      'puzzle_id': puzzleId,
      'clue_text': c.text,
      'is_found': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> markClueFound(String sessionId, String clueId) async {
    final db = await database;
    await db.update(
      'clues',
      {'is_found': 1, 'found_at': DateTime.now().toIso8601String()},
      where: 'clue_id = ?',
      whereArgs: ['${sessionId}_$clueId'],
    );
  }

  // ── Achievements ───────────────────────────────────────────────────────────

  Future<void> insertAchievementIfNew(Achievement a, String puzzleId) async {
    final db = await database;
    await db.insert('achievements', {
      'achievement_id': a.id,
      'name': a.name,
      'description': a.description,
      'puzzle_id': puzzleId,
      'is_unlocked': 0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> unlockAchievement(String id) async {
    final db = await database;
    await db.update('achievements',
        {'is_unlocked': 1, 'unlocked_at': DateTime.now().toIso8601String()},
        where: 'achievement_id = ?', whereArgs: [id]);
  }

  Future<bool> isAchievementUnlocked(String id) async {
    final db = await database;
    final rows = await db.query('achievements',
        where: 'achievement_id = ? AND is_unlocked = 1', whereArgs: [id]);
    return rows.isNotEmpty;
  }

  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final rows = await db.query('achievements',
        orderBy: 'is_unlocked DESC, achievement_id ASC');
    return rows.map(Achievement.fromMap).toList();
  }

  // ── Hints ──────────────────────────────────────────────────────────────────

  Future<void> insertHint(Hint h) async {
    final db = await database;
    await db.insert('hints', h.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Hint>> getHintsForPuzzle(String puzzleId,
      {HintType? type}) async {
    final db = await database;
    final List<Map<String, dynamic>> rows;
    if (type != null) {
      rows = await db.query('hints',
          where: 'puzzle_id = ? AND type = ?',
          whereArgs: [puzzleId, type.name],
          orderBy: 'priority DESC');
    } else {
      rows = await db.query('hints',
          where: 'puzzle_id = ?',
          whereArgs: [puzzleId],
          orderBy: 'priority DESC');
    }
    return rows.map(Hint.fromMap).toList();
  }

  Future<void> adjustHintPriority(String hintId, int delta) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE hints SET priority = MAX(1, MIN(10, priority + ?)) WHERE hint_id = ?',
        [delta, hintId]);
  }

  Future<void> close() async => (await database).close();
}