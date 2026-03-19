import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/puzzle_service.dart';
import '../utils/app_theme.dart';
import '../widgets/enigma_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameCtrl = TextEditingController();
  bool _nameEntered = false;

  @override
  void initState() {
    super.initState();
    final saved = context.read<GameProvider>().teamName;
    if (saved != 'Team Enigma' && saved.isNotEmpty) {
      _nameCtrl.text = saved;
      _nameEntered = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EnigmaDrawer(),
      body: SafeArea(
        child: _nameEntered ? _MissionSelect() : _NameEntry(
          controller: _nameCtrl,
          onEnter: (name) {
            context.read<GameProvider>().setTeamName(name);
            setState(() => _nameEntered = true);
          },
        ),
      ),
    );
  }
}

// Name entry screen 
class _NameEntry extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onEnter;
  const _NameEntry({required this.controller, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.background, AppColors.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.15),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.5), width: 2),
                ),
                child: const Icon(Icons.lock,
                    color: AppColors.primary, size: 52),
              ),
              const SizedBox(height: 24),
              const Text('ENIGMA ROOMS',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3)),
              const SizedBox(height: 8),
              const Text('Can you escape in time?',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 48),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('ENTER YOUR TEAM NAME',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'e.g. The Detectives',
                  hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.5), width: 2),
                  ),
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) onEnter(v.trim());
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) onEnter(name);
                  },
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: const Text('ENTER THE ROOM',
                      style: TextStyle(fontSize: 16, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mission select screen 
class _MissionSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final puzzle = PuzzleService.instance.puzzles.first;
    final game = context.watch<GameProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.background, AppColors.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome,',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                    Text(game.teamName,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings,
                      color: AppColors.textSecondary),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Mission card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mission banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.lock,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(puzzle.title,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 6),
                        Text(puzzle.description,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.5)),
                      ],
                    ),
                  ),

                  // Stats
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                          children: [
                            _StatChip(Icons.timer,
                                '${(puzzle.timeLimitSec / 60).round()} min'),
                            _StatChip(Icons.layers, '5 Levels'),
                            
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Level previews
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('LEVELS',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        ...puzzle.levels.map((l) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 6),
                              child: Row(children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary
                                        .withOpacity(0.15),
                                  ),
                                  child: Center(
                                    child: Text('${l.level}',
                                        style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(l.title,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13)),
                              ]),
                            )),
                        const SizedBox(height: 20),

                        // Play button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () => _startMission(context),
                            icon: const Icon(Icons.play_arrow,
                                size: 22),
                            label: const Text('START MISSION',
                                style: TextStyle(
                                    fontSize: 16, letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/leaderboard'),                 
                    label: const Text('Leaderboard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/achievements'),                  
                    label: const Text('Achievements'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startMission(BuildContext context) async {
    final puzzle = PuzzleService.instance.puzzles.first;
    await context.read<GameProvider>().startSession(puzzle);
    if (context.mounted) {
      Navigator.pushNamed(context, '/mission');
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      );
}