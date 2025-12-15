import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';

class EditTileScreen extends StatefulWidget {
  const EditTileScreen({super.key, required this.tileId});

  final String tileId;

  @override
  State<EditTileScreen> createState() => _EditTileScreenState();
}

class _EditTileScreenState extends State<EditTileScreen> {
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
    final app = context.watch<AppController>();
    final tile = app.tiles.firstWhere((t) => t.id == widget.tileId);
    final cat = app.categories.firstWhere((c) => c.id == tile.categoryId);

    label.text = tile.label;
    speak.text = tile.speakText;

    return Scaffold(
      appBar: AppBar(title: Text('Edit tile • ${cat.name}')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: label,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Button label',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: speak,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Spoken text',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    if (label.text.trim().isEmpty || speak.text.trim().isEmpty) return;
                    await app.updateTile(tileId: tile.id, label: label.text, speakText: speak.text);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => app.speakMessage(override: speak.text.trim()),
                icon: const Icon(Icons.volume_up),
                label: const Text('Test'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
