import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/model.dart' as model;
import 'package:generate_crossword/providers.dart' as providers;
import 'package:generate_crossword/widgets/crossword_generator_app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

Future<StreamController<model.Crossword>> abrirCuadricula(
  WidgetTester tester,
) async {
  final controller = StreamController<model.Crossword>();
  addTearDown(() {
    controller.close();
  });
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        providers.wordListProvider.overrideWith(
          (ref) async => BuiltSet<String>(['cat']),
        ),
        providers.crosswordProvider.overrideWith((ref) => controller.stream),
      ],
      child: MaterialApp(home: CrosswordGeneratorApp()),
    ),
  );
  controller.add(model.Crossword.crossword(width: 40, height: 22));
  await tester.pump();
  await tester.pump();
  return controller;
}

void main() {
  testWidgets(
    'actualiza las letras sin reconstruir las celdas que no cambiaron',
    (tester) async {
      final controller = await abrirCuadricula(tester);
      final unchanged = tester.widget(find.byKey(ValueKey('cell-0-0')));
      final changed = tester.widget(find.byKey(ValueKey('cell-1-1')));
      controller.add(
        model.Crossword.crossword(width: 40, height: 22).addWord(
          location: model.Location.at(1, 1),
          word: 'cat',
          direction: model.Direction.across,
        )!,
      );
      await tester.pump();
      await tester.pump();
      expect(tester.widget(find.byKey(ValueKey('cell-0-0'))), same(unchanged));
      expect(
        tester.widget(find.byKey(ValueKey('cell-1-1'))),
        isNot(same(changed)),
      );
      expect(
        find.descendant(
          of: find.byKey(ValueKey('cell-1-1')),
          matching: find.text('c'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(ValueKey('cell-2-1')),
          matching: find.text('a'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'el menú cambia dimensiones y una cuadrícula grande sigue siendo diferida',
    (tester) async {
      await abrirCuadricula(tester);
      final initial = tester.widget<TableView>(find.byType(TableView));
      expect(initial.delegate.columnCount, 40);
      expect(initial.delegate.rowCount, 22);
      await tester.tap(find.byTooltip('Cambiar tamaño'));
      await tester.pumpAndSettle();
      for (final size in providers.CrosswordSize.values) {
        expect(find.text(size.label), findsOneWidget);
      }
      await tester.tap(find.text('500 x 500'));
      await tester.pumpAndSettle();
      final table = tester.widget<TableView>(find.byType(TableView));
      expect(table.delegate.columnCount, 500);
      expect(table.delegate.rowCount, 500);
      final cells = find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('cell-'),
      );
      expect(cells.evaluate().length, lessThan(3000));
    },
  );

  testWidgets('la cuadrícula permite desplazarse horizontal y verticalmente', (
    tester,
  ) async {
    await abrirCuadricula(tester);
    await tester.tap(find.byTooltip('Cambiar tamaño'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('500 x 500'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(TableView), Offset(-600, -600));
    await tester.pumpAndSettle();
    final positions = tester
        .stateList<ScrollableState>(
          find.byWidgetPredicate((widget) => widget is Scrollable),
        )
        .map((state) => state.position)
        .toList();
    expect(
      positions
          .singleWhere(
            (position) => position.axisDirection == AxisDirection.right,
          )
          .pixels,
      greaterThan(0),
    );
    expect(
      positions
          .singleWhere(
            (position) => position.axisDirection == AxisDirection.down,
          )
          .pixels,
      greaterThan(0),
    );
  });
}
