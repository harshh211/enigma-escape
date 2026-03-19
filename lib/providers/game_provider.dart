// lib/providers/game_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/puzzle_model.dart';
import '../models/session_model.dart';
import '../models/hint_model.dart';
import '../services/database_helper.dart';
import '../services/hint_engine.dart';
import '../utils/word_search_solver.dart';

class GameProvider extends ChangeNotifier {
  // Settings
  String _teamName = 'Team Enigma';
  String _difficulty = 'easy';
  bool _isDarkMode = true;

  String get teamName => _teamName;
  String get difficulty => _difficulty;
  bool get isDarkMode => _isDarkMode;

  // Active session 
  GameSession? _activeSession;
  Puzzle? _activePuzzle;
  List<Clue> _clues = [];
  int _timeRemaining = 0;
  Timer? _timer;
  bool _sessionComplete = false;
  bool _timedOut = false;

  GameSession? get activeSession => _activeSession;
  Puzzle? get activePuzzle => _activePuzzle;
  List<Clue> get clues => List.unmodifiable(_clues);
  int get timeRemaining => _timeRemaining;
  bool get sessionComplete => _sessionComplete;
  bool get timedOut => _timedOut;
  int get cluesFound => _clues.where((c) => c.isFound).length;
  int get totalHintsUsed => _activeSession?.hintsUsed ?? 0;
  int get totalMistakes => _activeSession?.wrongHighlights ?? 0;

  // Word Search state
  List<GridCell> _selectedCells = [];
  Set<String> _foundWords = {};
  List<String> _foundWordsInOrder = [];
  bool _wordSearchComplete = false;
  String? _passphrase;

  List<GridCell> get selectedCells => List.unmodifiable(_selectedCells);
  Set<String> get foundWords => Set.unmodifiable(_foundWords);
  List<String> get foundWordsInOrder => List.unmodifiable(_foundWordsInOrder);
  bool get wordSearchComplete => _wordSearchComplete;
  String? get passphrase => _passphrase;

  // Hint state
  HintResult? _pendingHint;
  bool _showHint = false;
  DateTime? _levelStartTime;
  bool get hintAvailable {
    if (_levelStartTime == null) return false;
    return DateTime.now().difference(_levelStartTime!).inSeconds >= 60;
  }

  int get hintCooldownRemaining {
    if (_levelStartTime == null) return 60;
    final elapsed = DateTime.now().difference(_levelStartTime!).inSeconds;
    return (60 - elapsed).clamp(0, 60);
  }

  bool get showHint => _showHint;
  HintResult? get pendingHint => _pendingHint;

  // Level progression
  int _currentLevel = 1;
  List<String> _completedLevelCodes = [];
  bool _levelComplete = false;

  int get currentLevel => _currentLevel;
  List<String> get completedLevelCodes =>
      List.unmodifiable(_completedLevelCodes);
  bool get levelComplete => _levelComplete;
  int get totalLevels => _activePuzzle?.levels.length ?? 5;

  // Leaderboard & Achievements 
  List<GameSession> _leaderboard = [];
  List<Achievement> _achievements = [];
  List<GameSession> get leaderboard => List.unmodifiable(_leaderboard);
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  

  Future<void> loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    _teamName = p.getString('team_name') ?? 'Team Enigma';
    _difficulty = p.getString('difficulty') ?? 'easy';
    _isDarkMode = p.getBool('dark_mode') ?? true;
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('team_name', _teamName);
    await p.setString('difficulty', _difficulty);
    await p.setBool('dark_mode', _isDarkMode);
  }

  void setTeamName(String name) {
    if (name.trim().isEmpty) return;
    _teamName = name.trim();
    _savePrefs();
    notifyListeners();
  }

  void setDifficulty(String d) {
    _difficulty = d;
    _savePrefs();
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _savePrefs();
    notifyListeners();
  }

  

  Future<void> startSession(Puzzle puzzle) async {
    _timer?.cancel();

    _activePuzzle = puzzle;
    _clues = puzzle.clues.map((c) => Clue(id: c.id, text: c.text)).toList();
    _selectedCells = [];
    _foundWords = {};
    _foundWordsInOrder = [];
    _wordSearchComplete = false;
    _passphrase = null;
    _sessionComplete = false;
    _timedOut = false;
    _showHint = false;
    _pendingHint = null;
    _timeRemaining = puzzle.timeLimitSec;
    _currentLevel = 1;
    _completedLevelCodes = [];
    _levelComplete = false;

    final id = const Uuid().v4();
    _activeSession = GameSession(
      sessionId: id,
      teamName: _teamName,
      puzzleId: puzzle.id,
      startTime: DateTime.now(),
    );

    await DatabaseHelper.instance.insertSession(_activeSession!);
    for (final c in puzzle.clues) {
      await DatabaseHelper.instance.insertClue(id, puzzle.id, c);
    }

    HintEngine.instance.clearSession(id);
    
    notifyListeners();
  }

  
  void startTimer() {
    _levelStartTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_sessionComplete) {
        _timer?.cancel();
        return;
      }
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        await _endSession(won: false);
      }
    });
  }

  // Clues 

  Future<void> findClue(String clueId) async {
    final idx = _clues.indexWhere((c) => c.id == clueId);
    if (idx == -1 || _clues[idx].isFound) return;
    _clues[idx] = _clues[idx].copyWith(
        isFound: true, foundAt: DateTime.now());
    await DatabaseHelper.instance
        .markClueFound(_activeSession!.sessionId, clueId);
    HintEngine.instance.recordActivity(_activeSession!.sessionId);
    notifyListeners();
  }

  // Word Search 

  void toggleCell(GridCell cell) {
    if (_wordSearchComplete || _sessionComplete) return;
    final list = List<GridCell>.from(_selectedCells);
    if (list.contains(cell)) {
      list.remove(cell);
    } else {
      list.add(cell);
    }
    _selectedCells = list;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCells = [];
    notifyListeners();
  }

  Future<void> submitSelection() async {
    if (_activePuzzle == null ||
        _activeSession == null ||
        _selectedCells.isEmpty) return;

    final grid = _activePuzzle!.wordsearch.grid;
    final remaining = _activePuzzle!.wordsearch.correctSequence
        .where((w) => !_foundWords.contains(w.toUpperCase()))
        .toList();

    final matched =
        WordSearchSolver.matchSelected(grid, _selectedCells, remaining);

    if (matched != null) {
      _foundWords = {..._foundWords, matched};
      _foundWordsInOrder = [..._foundWordsInOrder, matched];

      if (_foundWordsInOrder.length ==
          _activePuzzle!.wordsearch.correctSequence.length) {
        // Always use the fixed passphrase from JSON
        _passphrase = _activePuzzle!.wordsearch.passphrase;
        _wordSearchComplete = true;
        _selectedCells = [];
        notifyListeners();
        completeLevel(_passphrase!);
        return;
      }
    } else {
      _timeRemaining =
          (_timeRemaining - 10).clamp(0, _activePuzzle!.timeLimitSec);
      _activeSession!.wrongHighlights++;
      await DatabaseHelper.instance.updateSession(_activeSession!);
    }

    _selectedCells = [];
    notifyListeners();
  }

  // Hints 

  Future<void> requestHint() async {
    if (_showHint || _sessionComplete || _activeSession == null) return;
    await _fetchAndShowHint();
  }

  Future<void> _fetchAndShowHint() async {
    final result = await HintEngine.instance.selectHint(
      sessionId: _activeSession!.sessionId,
      puzzleId: _activePuzzle!.id,
      cluesFound: cluesFound,
      totalClues: _clues.length,
      wordsFound: _foundWords.length,
    );
    if (result != null) {
      _pendingHint = result;
      _showHint = true;
      _activeSession!.hintsUsed++;
      await DatabaseHelper.instance.updateSession(_activeSession!);
      notifyListeners();
    }
  }

  Future<void> rateHint(bool thumbsUp) async {
    if (_pendingHint == null) return;
    await HintEngine.instance.rateHint(_pendingHint!.hint.id, thumbsUp);
    _showHint = false;
    notifyListeners();
  }

  void dismissHint() {
    _showHint = false;
    notifyListeners();
  }

  //Level progression

   void completeLevel(String code) {
    _completedLevelCodes = [..._completedLevelCodes, code];
    _levelComplete = true;

    // Unlock level achievement
    final levelAchs = _activePuzzle?.levelAchievements ?? [];
    final levelIdx = _completedLevelCodes.length - 1;
    if (levelIdx < levelAchs.length) {
      final ach = levelAchs[levelIdx];
      DatabaseHelper.instance.isAchievementUnlocked(ach.id).then((done) {
        if (!done) {
          DatabaseHelper.instance.unlockAchievement(ach.id).then((_) {
            loadAchievements();
          });
        }
      });
    }

    // Save stats when last level is completed
    if (_completedLevelCodes.length == totalLevels) {
      _activeSession?.endTime = DateTime.now();
      _activeSession?.isCompleted = true;
      _activeSession?.score = _activeSession!
          .calculateScore(_activePuzzle?.timeLimitSec ?? 300);
      if (_activeSession != null) {
        DatabaseHelper.instance.updateSession(_activeSession!);
      }
      // Unlock achievement
      if (_activePuzzle != null) {
        DatabaseHelper.instance
            .isAchievementUnlocked(_activePuzzle!.achievement.id)
            .then((alreadyDone) {
          if (!alreadyDone) {
            DatabaseHelper.instance
                .unlockAchievement(_activePuzzle!.achievement.id)
                .then((_) => loadAchievements());
          }
        });
      }
      loadLeaderboard();
      loadAchievements();
    }
    notifyListeners();
  }

  void goToNextLevel() {
    if (_currentLevel < totalLevels) {
      _currentLevel++;
      _levelComplete = false;
      _levelStartTime = DateTime.now();
      notifyListeners();
    }
  }

  // End session

  Future<void> _endSession({required bool won}) async {
    if (_activeSession == null || _activePuzzle == null) return;
    _timer?.cancel();
    _activeSession!.endTime = DateTime.now();
    _activeSession!.isCompleted = won;
    _timedOut = !won;

    if (won) {
      _activeSession!.score =
          _activeSession!.calculateScore(_activePuzzle!.timeLimitSec);
      final alreadyDone = await DatabaseHelper.instance
          .isAchievementUnlocked(_activePuzzle!.achievement.id);
      if (!alreadyDone) {
        await DatabaseHelper.instance
            .unlockAchievement(_activePuzzle!.achievement.id);
      }
    }

    await DatabaseHelper.instance.updateSession(_activeSession!);
    _sessionComplete = true;
    await loadLeaderboard();
    await loadAchievements();
    notifyListeners();
  }

  // Load from DB 

  Future<void> loadLeaderboard() async {
    _leaderboard = await DatabaseHelper.instance.getTopSessions();
    notifyListeners();
  }

  Future<void> loadAchievements() async {
    _achievements = await DatabaseHelper.instance.getAllAchievements();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}