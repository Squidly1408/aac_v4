import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';

class QuickScreen extends StatelessWidget {
  const QuickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final favs = controller.favourites;
    final pinned = controller.pinnedPhrases;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Favourites', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (favs.isEmpty)
          Text(
            'Long-press any tile to add it to favourites.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: favs.map((t) {
              return ActionChip(
                label: Text(t.label),
                onPressed: () {
                  controller.addToken(t.speakText);
                  controller.speakMessage();
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 18),
        Text('Quick Phrases', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (pinned.isEmpty)
          Text(
            'Pin phrases from the Keyboard tab.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Column(
            children: pinned.map((p) {
              return Card(
                child: ListTile(
                  title: Text(p.text),
                  trailing: IconButton(
                    tooltip: 'Speak',
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => controller.speakMessage(override: p.text),
                  ),
                  onTap: () => controller.speakMessage(override: p.text),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
