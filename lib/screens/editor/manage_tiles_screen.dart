import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_controller.dart';
import 'new_tile_screen.dart';
import 'edit_tile_screen.dart';

class ManageTilesScreen extends StatelessWidget {
  const ManageTilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final cats = app.sortedCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Tiles')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: cats.map((c) {
          final tiles = app.tilesForCategory(c.id);
          return Card(
            child: ExpansionTile(
              title: Text(c.name),
              subtitle: Text('${tiles.length} tiles'),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 12, 8),
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => NewTileScreen(categoryId: c.id)),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add tile'),
                    ),
                  ),
                ),
                ...tiles.map((t) {
                  return ListTile(
                    title: Text(t.label),
                    subtitle: Text('Speaks: "${t.speakText}"'),
                    leading: IconButton(
                      tooltip: t.isFavourite ? 'Unfavourite' : 'Favourite',
                      icon: Icon(t.isFavourite ? Icons.star : Icons.star_border),
                      onPressed: () => app.toggleFavourite(t.id),
                    ),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final ok = await _confirm(context, 'Delete "${t.label}"?');
                        if (!ok) return;
                        await app.deleteTile(t.id);
                      },
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => EditTileScreen(tileId: t.id)),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          );
        }).toList(),
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
