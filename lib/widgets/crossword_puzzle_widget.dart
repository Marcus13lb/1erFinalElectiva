import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../model.dart' as model;
import '../providers.dart' as providers;

class CrosswordPuzzleWidget extends ConsumerWidget {
  const CrosswordPuzzleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solution = ref.watch(
      providers.puzzleProvider.select(
        (value) => value.asData?.value?.crossword,
      ),
    );
    if (solution == null) return SizedBox.shrink();
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      child: TableView.builder(
        key: ValueKey(solution),
        diagonalDragBehavior: DiagonalDragBehavior.free,
        columnCount: solution.width,
        rowCount: solution.height,
        columnBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(32)),
        rowBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(32)),
        cellBuilder: (context, vicinity) {
          final location = model.Location.at(vicinity.column, vicinity.row);
          final cell = solution.characters[location];
          return TableViewCell(
            child: cell == null
                ? ColoredBox(color: Theme.of(context).colorScheme.surface)
                : _PuzzleCell(location: location, definition: cell),
          );
        },
      ),
    );
  }
}

class _PuzzleCell extends ConsumerWidget {
  const _PuzzleCell({required this.location, required this.definition});
  final model.Location location;
  final model.CrosswordCharacter definition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.read(providers.puzzleProvider).asData?.value;
    if (game == null) return SizedBox.shrink();
    final letter = ref.watch(
      providers.puzzleProvider.select(
        (value) => value
            .asData
            ?.value
            ?.crosswordFromSelectedWords
            .characters[location]
            ?.character,
      ),
    );
    final colors = Theme.of(context).colorScheme;
    final slots = [
      if (definition.acrossWord != null) definition.acrossWord!,
      if (definition.downWord != null) definition.downWord!,
    ];
    return MenuAnchor(
      menuChildren: [
        for (final slot in slots) ...[
          MenuItemButton(
            child: Text(
              '${slot.direction == model.Direction.across ? 'Horizontal' : 'Vertical'} (${slot.word.length})',
            ),
          ),
          for (final word in ({
            slot.word,
            ...?game.alternateWords[slot.location]?[slot.direction],
          }).toList()..sort())
            _WordSelectMenuItem(slot: slot, word: word),
          _ClearWordMenuItem(slot: slot),
          Divider(),
        ],
      ],
      builder: (context, controller, child) => InkWell(
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: Container(
          key: ValueKey('puzzle-cell-${location.x}-${location.y}'),
          decoration: BoxDecoration(
            color: letter == null
                ? colors.surfaceContainerHighest
                : colors.primaryContainer,
            border: Border.all(color: colors.outlineVariant, width: 0.5),
          ),
          child: Center(
            child: Text(
              letter ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _WordSelectMenuItem extends ConsumerWidget {
  const _WordSelectMenuItem({required this.slot, required this.word});
  final model.CrosswordWord slot;
  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      providers.puzzleProvider.select(
        (value) =>
            value.asData?.value?.canSelectWord(
              location: slot.location,
              word: word,
              direction: slot.direction,
            ) ??
            false,
      ),
    );
    final selected = ref.watch(
      providers.puzzleProvider.select(
        (value) =>
            value.asData?.value?.selectedWords.any(
              (choice) =>
                  choice.location == slot.location &&
                  choice.direction == slot.direction &&
                  choice.word == word,
            ) ??
            false,
      ),
    );
    return MenuItemButton(
      leadingIcon: selected ? Icon(Icons.check) : SizedBox(width: 24),
      onPressed: enabled
          ? () => ref
                .read(providers.puzzleProvider.notifier)
                .selectWord(
                  location: slot.location,
                  word: word,
                  direction: slot.direction,
                )
          : null,
      child: Text(word),
    );
  }
}

class _ClearWordMenuItem extends ConsumerWidget {
  const _ClearWordMenuItem({required this.slot});
  final model.CrosswordWord slot;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      providers.puzzleProvider.select(
        (value) =>
            value.asData?.value?.selectedWords.any(
              (choice) =>
                  choice.location == slot.location &&
                  choice.direction == slot.direction,
            ) ??
            false,
      ),
    );
    return MenuItemButton(
      onPressed: selected
          ? () => ref
                .read(providers.puzzleProvider.notifier)
                .clearWord(location: slot.location, direction: slot.direction)
          : null,
      child: Text(
        'Borrar ${slot.direction == model.Direction.across ? 'horizontal' : 'vertical'}',
      ),
    );
  }
}
