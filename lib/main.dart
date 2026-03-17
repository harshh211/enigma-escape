import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'services/puzzle_service.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/mission_screen.dart';
import 'screens/level_router_screen.dart';
import 'screens/word_search_screen.dart';
import 'screens/level_router_screen.dart';
import 'screens/clue_tracker_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PuzzleService.instance.loadPuzzles();
  runApp(const EnigmaRoomsApp());
}

class EnigmaRoomsApp extends StatelessWidget {
  const EnigmaRoomsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()
        ..loadPrefs()
        ..loadLeaderboard()
        ..loadAchievements(),
      child: Consumer<GameProvider>(
        builder: (context, game, _) => MaterialApp(
          title: 'ENIGMA ROOMS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode:
              game.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/':             (_) => const HomeScreen(),
            '/mission':      (_) => const MissionScreen(),
            '/wordsearch':   (_) => const WordSearchScreen(),
            '/levels':       (_) => const LevelRouterScreen(),
            '/clues':        (_) => const ClueTrackerScreen(),
            '/achievements': (_) => const AchievementsScreen(),
            '/leaderboard':  (_) => const LeaderboardScreen(),
            '/settings':     (_) => const SettingsScreen(),
          },
        ),
      ),
    );
  }
}