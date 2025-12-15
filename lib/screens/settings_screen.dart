import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('Text-to-Speech', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rate: ${app.ttsRate.toStringAsFixed(2)}'),
                  Slider(
                    value: app.ttsRate,
                    min: 0.2,
                    max: 0.8,
                    onChanged: (v) => app.setTts(v, app.ttsPitch),
                  ),
                  const SizedBox(height: 8),
                  Text('Pitch: ${app.ttsPitch.toStringAsFixed(2)}'),
                  Slider(
                    value: app.ttsPitch,
                    min: 0.7,
                    max: 1.4,
                    onChanged: (v) => app.setTts(app.ttsRate, v),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => app.speakMessage(override: 'Hello. This is my AAC voice.'),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Test voice'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Backup', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export backup (JSON)'),
              subtitle: const Text('Creates a JSON file in your documents folder.'),
              onTap: () async {
                final path = await app.exportBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported: $path')),
                  );
                }
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Import backup (JSON)'),
              subtitle: const Text('Pick a JSON backup file to restore boards and phrases.'),
              onTap: () async {
                final ok = await app.importBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Imported backup' : 'Import failed')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 18),
          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              title: Text('AAC Best MVP'),
              subtitle: Text('Offline-first AAC app demo built in Flutter.'),
            ),
          ),
        ],
      ),
    );
  }
}
