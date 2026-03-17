import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: context.read<GameProvider>().teamName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Team 
          _SectionLabel('TEAM'),
          Container(
            decoration: _box,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(
                          color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Team Name',
                        border: InputBorder.none,
                        filled: false,
                      ),
                      onSubmitted: (v) => _saveName(context, v),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle,
                        color: AppColors.success),
                    onPressed: () =>
                        _saveName(context, _ctrl.text),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Difficulty 
          _SectionLabel('DIFFICULTY'),
          Container(
            decoration: _box,
            child: Column(
              children: [
                _RadioTile(
                  title: 'Easy',
                  subtitle: '8×8 grid · 10 min timer',
                  value: 'easy',
                  group: game.difficulty,
                  onChange: (v) =>
                      context.read<GameProvider>().setDifficulty(v!),
                ),
                const Divider(
                    height: 1, color: AppColors.background),
                _RadioTile(
                  title: 'Hard',
                  subtitle: '12×12 grid · 8 min timer',
                  value: 'hard',
                  group: game.difficulty,
                  onChange: (v) =>
                      context.read<GameProvider>().setDifficulty(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Display 
          _SectionLabel('DISPLAY'),
          Container(
            decoration: _box,
            child: SwitchListTile(
              title: const Text('Dark Mode',
                  style: TextStyle(color: AppColors.textPrimary)),
              subtitle: const Text(
                  'Recommended for escape room play',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12)),
              value: game.isDarkMode,
              activeColor: AppColors.primary,
              onChanged: (_) =>
                  context.read<GameProvider>().toggleDarkMode(),
            ),
          ),
          const SizedBox(height: 20),

          // About 
          _SectionLabel('ABOUT'),
          Container(
            decoration: _box,
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.extension,
                      color: AppColors.textSecondary),
                  title: Text('ENIGMA ROOMS',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Mystery Puzzle & Escape Room Companion\nGSU Mobile App Dev — Group Project 1',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                ),
                Divider(height: 1, color: AppColors.background),
                ListTile(
                  leading: Icon(Icons.storage,
                      color: AppColors.textSecondary),
                  title: Text('Local Storage',
                      style:
                          TextStyle(color: AppColors.textPrimary)),
                  subtitle: Text(
                      'All data: SQLite (6 tables) + SharedPreferences\nFully offline — no internet required.',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                ),
                Divider(height: 1, color: AppColors.background),
                ListTile(
                  leading: Icon(Icons.psychology,
                      color: AppColors.textSecondary),
                  title: Text('AI Game Master',
                      style:
                          TextStyle(color: AppColors.textPrimary)),
                  subtitle: Text(
                      'On-device, rule-based hint engine. No cloud APIs.',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveName(BuildContext context, String val) {
    context.read<GameProvider>().setTeamName(val);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Team name saved!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2)),
    );
    FocusScope.of(context).unfocus();
  }

  BoxDecoration get _box => BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold)),
      );
}

class _RadioTile extends StatelessWidget {
  final String title, subtitle, value, group;
  final ValueChanged<String?> onChange;
  const _RadioTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.group,
    required this.onChange,
  });
  @override
  Widget build(BuildContext context) => RadioListTile<String>(
        title: Text(title,
            style:
                const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        value: value,
        groupValue: group,
        activeColor: AppColors.primary,
        onChanged: onChange,
      );
}