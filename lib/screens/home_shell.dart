import 'package:flutter/material.dart';

import 'speak_screen.dart';
import 'quick_screen.dart';
import 'keyboard_screen.dart';
import 'settings_screen.dart';
import 'editor/editor_home.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const SpeakScreen(),
      const QuickScreen(),
      const KeyboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AAC Best'),
        actions: [
          IconButton(
            tooltip: 'Editor',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditorHome()),
              );
            },
            icon: const Icon(Icons.edit_note),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Speak'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Quick'),
          NavigationDestination(icon: Icon(Icons.keyboard), label: 'Keyboard'),
        ],
      ),
    );
  }
}
