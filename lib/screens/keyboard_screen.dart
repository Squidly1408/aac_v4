import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';

class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({super.key});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final pinned = app.pinnedPhrases;
    final allPhrases = [...app.phrases]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Type', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focus,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type a message…',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  app.speakMessage(override: text);
                },
                icon: const Icon(Icons.volume_up),
                label: const Text('Speak'),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => _controller.clear(),
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text('Quick phrase chips', style: Theme.of(context).textTheme.titleLarge),
            ),
            TextButton.icon(
              onPressed: () async {
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                await app.addPhrase(text, pinned: true);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved & pinned phrase')),
                  );
                }
              },
              icon: const Icon(Icons.push_pin),
              label: const Text('Pin typed'),
            )
          ],
        ),
        const SizedBox(height: 8),
        if (pinned.isEmpty)
          Text(
            'Pin phrases for one-tap speaking.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pinned.map((p) {
              return InputChip(
                label: Text(p.text),
                onPressed: () => app.speakMessage(override: p.text),
                onDeleted: () => app.togglePinnedPhrase(p.id),
                deleteIcon: const Icon(Icons.close),
              );
            }).toList(),
          ),
        const SizedBox(height: 18),
        Text('All saved phrases', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add a new phrase'),
            subtitle: const Text('Create phrases you use often.'),
            onTap: () async {
              final text = await _prompt(context, title: 'New phrase', hint: 'e.g., I need help please');
              if (text == null || text.trim().isEmpty) return;
              await app.addPhrase(text);
            },
          ),
        ),
        const SizedBox(height: 8),
        ...allPhrases.map((p) {
          return Card(
            child: ListTile(
              title: Text(p.text),
              leading: IconButton(
                tooltip: p.pinned ? 'Unpin' : 'Pin',
                icon: Icon(p.pinned ? Icons.push_pin : Icons.push_pin_outlined),
                onPressed: () => app.togglePinnedPhrase(p.id),
              ),
              trailing: IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => app.deletePhrase(p.id),
              ),
              onTap: () => app.speakMessage(override: p.text),
            ),
          );
        }),
      ],
    );
  }

  Future<String?> _prompt(BuildContext context, {required String title, required String hint}) async {
    final c = TextEditingController();
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
          FilledButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
