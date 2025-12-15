import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import 'editor/edit_tile_screen.dart';

class TileActionsSheet extends StatelessWidget {
  const TileActionsSheet({super.key, required this.tileId});

  final String tileId;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AppController>();
    final tile = controller.tiles.firstWhere((t) => t.id == tileId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(tile.label, style: Theme.of(context).textTheme.titleLarge),
              subtitle: Text('Speaks: "${tile.speakText}"'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(tile.isFavourite ? Icons.star : Icons.star_border),
              title: Text(tile.isFavourite ? 'Remove from Favourites' : 'Add to Favourites'),
              onTap: () async {
                await controller.toggleFavourite(tileId);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Speak now'),
              onTap: () async {
                await controller.speakMessage(override: tile.speakText);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit tile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditTileScreen(tileId: tileId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
