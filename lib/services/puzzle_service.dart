// lib/services/puzzle_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/puzzle_model.dart';
import '../models/hint_model.dart';
import 'database_helper.dart';

class PuzzleService {
  static final PuzzleService instance = PuzzleService._();
  PuzzleService._();

  List<Puzzle> _puzzles = [];
  List<Puzzle> get puzzles => List.unmodifiable(_puzzles);

  Puzzle? getById(String id) {
    try {
      return _puzzles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadPuzzles() async {
    final raw = await rootBundle.loadString('assets/puzzles/puzzles.json');
    final list = json.decode(raw) as List<dynamic>;
    _puzzles = list.map((j) => Puzzle.fromJson(j as Map<String, dynamic>)).toList();

    for (final p in _puzzles) {
      await DatabaseHelper.instance.insertAchievementIfNew(p.achievement, p.id);
      await _seedHints(p);
    }
  }

  Future<void> _seedHints(Puzzle p) async {
    final db = DatabaseHelper.instance;

    final wsHints = [
      Hint(
        id: '${p.id}_ws_1',
        puzzleId: p.id,
        type: HintType.wordSearch,
        text: 'Scan each row from left to right — the next word runs horizontally.',
        reason: 'Most words in this puzzle run left to right.',
        priority: 6,
      ),
      Hint(
        id: '${p.id}_ws_2',
        puzzleId: p.id,
        type: HintType.wordSearch,
        text: 'The next word starts near the top-left of the grid.',
        reason: 'Based on your current position in the word sequence.',
        priority: 5,
      ),
      Hint(
        id: '${p.id}_ws_3',
        puzzleId: p.id,
        type: HintType.wordSearch,
        text: 'Every word runs in one straight line — try highlighting in a single direction.',
        reason: 'Common mistake: words only go one direction at a time.',
        priority: 4,
      ),
    ];

    final storyHints = p.clues.asMap().entries.map((e) => Hint(
          id: '${p.id}_story_${e.key}',
          puzzleId: p.id,
          type: HintType.story,
          text: 'Clue ${e.key + 1} hint: "${e.value.text}"',
          reason: 'Based on clues you haven\'t discovered yet.',
          priority: 5 - e.key,
        ));

    for (final h in [...wsHints, ...storyHints]) {
      await db.insertHint(h);
    }
  }
}