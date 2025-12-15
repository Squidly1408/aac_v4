import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../widgets/message_strip.dart';
import '../widgets/tile_button.dart';
import 'tile_actions_sheet.dart';

class SpeakScreen extends StatelessWidget {
  const SpeakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final cats = controller.sortedCategories;
    final selected = controller.selectedCategoryId;

    return Column(
      children: [
        MessageStrip(
          text: controller.composedMessage,
          onSpeak: () => controller.speakMessage(),
          onClear: controller.clearMessage,
          onUndo: controller.backspaceToken,
        ),
        if (cats.isNotEmpty)
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = cats[i];
                final isSelected = c.id == selected;
                return ChoiceChip(
                  label: Text(c.name),
                  selected: isSelected,
                  onSelected: (_) => controller.selectCategory(c.id),
                );
              },
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final crossAxisCount = w >= 900
                    ? 7
                    : w >= 700
                        ? 6
                        : w >= 520
                            ? 5
                            : 4;

                final tiles = controller.tilesForCategory(selected);

                if (tiles.isEmpty) {
                  return Center(
                    child: Text(
                      'No tiles in this category yet.\nTap the editor icon to add some.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                }

                return GridView.builder(
                  itemCount: tiles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, i) {
                    final t = tiles[i];
                    return TileButton(
                      label: t.label,
                      onTap: () => controller.addToken(t.speakText),
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (_) => TileActionsSheet(tileId: t.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
