import 'package:flutter/material.dart';

import 'manage_categories_screen.dart';
import 'manage_tiles_screen.dart';

class EditorHome extends StatelessWidget {
  const EditorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Manage categories'),
              subtitle: const Text('Add, rename, and delete categories.'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.grid_on_outlined),
              title: const Text('Manage tiles'),
              subtitle: const Text('Add, edit, and delete tiles within categories.'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageTilesScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
