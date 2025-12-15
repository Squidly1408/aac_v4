import 'package:flutter/material.dart';

class MessageStrip extends StatelessWidget {
  const MessageStrip({
    super.key,
    required this.text,
    required this.onSpeak,
    required this.onClear,
    required this.onUndo,
  });

  final String text;
  final VoidCallback onSpeak;
  final VoidCallback onClear;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.25),
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.4)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.isEmpty ? 'Tap tiles to build a message…' : text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Undo',
            onPressed: onUndo,
            icon: const Icon(Icons.backspace_outlined),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: onClear,
            icon: const Icon(Icons.clear),
          ),
          FilledButton.icon(
            onPressed: onSpeak,
            icon: const Icon(Icons.volume_up),
            label: const Text('Speak'),
          ),
        ],
      ),
    );
  }
}
