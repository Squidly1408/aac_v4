import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final cats = app.sortedCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final name = await _prompt(context, title: 'New category', hint: 'e.g., Food');
          if (name == null || name.trim().isEmpty) return;
          await app.addCategory(name);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final c = cats[i];
          return Card(
            child: ListTile(
              title: Text(c.name),
              subtitle: Text('ID: ${c.id.substring(0, 8)}…'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'rename') {
                    final name = await _prompt(context, title: 'Rename category', hint: c.name, initial: c.name);
                    if (name == null || name.trim().isEmpty) return;
                    await app.renameCategory(c.id, name);
                  } else if (v == 'delete') {
                    final ok = await _confirm(context, 'Delete "${c.name}" and its tiles?');
                    if (!ok) return;
                    await app.deleteCategory(c.id);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String?> _prompt(
    BuildContext context, {
    required String title,
    required String hint,
    String? initial,
  }) async {
    final c = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('Save')),
        ],
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String msg) async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm'),
            content: Text(msg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
        )) ??
        false;
  }
}
