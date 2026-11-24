import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../model.dart' as model;
import '../providers.dart' as providers;

class CrosswordWidget extends ConsumerWidget {
  const CrosswordWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(providers.sizeProvider);
    final status = ref.watch(
      providers.workQueueProvider.select(
        (value) => (loading: value.isLoading, error: value.error),
      ),
    );
    if (status.loading) return Center(child: CircularProgressIndicator());
    if (status.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No se pudo cargar el crucigrama.\n${status.error}'),
        ),
      );
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      child: TableView.builder(
        key: ValueKey(size),
        diagonalDragBehavior: DiagonalDragBehavior.free,
        columnCount: size.width,
        rowCount: size.height,
        columnBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(32)),
        rowBuilder: (index) => TableSpan(extent: FixedTableSpanExtent(32)),
        cellBuilder: (context, vicinity) {
          final location = model.Location.at(vicinity.column, vicinity.row);
          return TableViewCell(
            child: Consumer(
              builder: (context, ref, child) {
                final character = ref.watch(
                  providers.workQueueProvider.select(
                    (value) => value.when(
                      data: (queue) => queue.crossword.characters[location],
                      error: (error, stackTrace) => null,
                      loading: () => null,
                    ),
                  ),
                );
                final colors = Theme.of(context).colorScheme;
                return DecoratedBox(
                  key: ValueKey('cell-${location.x}-${location.y}'),
                  decoration: BoxDecoration(
                    color: character == null
                        ? colors.surface
                        : colors.primaryContainer,
                    border: Border.all(
                      color: colors.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      character?.character ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
