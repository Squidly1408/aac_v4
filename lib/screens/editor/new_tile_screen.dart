import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';

class NewTileScreen extends StatefulWidget {
  const NewTileScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<NewTileScreen> createState() => _NewTileScreenState();
}

class _NewTileScreenState extends State<NewTileScreen> {
  final label = TextEditingController();
  final speak = TextEditingController();

  @override
  void dispose() {
    label.dispose();
    speak.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppController>();
    final cat = app.categories.firstWhere((c) => c.id == widget.categoryId);

    return Scaffold(
      appBar: AppBar(title: Text('New tile • ${cat.name}')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: label,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Button label',
              hintText: 'e.g., Water',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: speak,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Spoken text',
              hintText: 'e.g., I want water',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              if (label.text.trim().isEmpty || speak.text.trim().isEmpty) return;
              await app.addTile(categoryId: widget.categoryId, label: label.text, speakText: speak.text);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
