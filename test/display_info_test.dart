import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/model.dart' as model;
import 'package:generate_crossword/providers.dart' as providers;
import 'package:generate_crossword/widgets/crossword_generator_app.dart';
import 'package:material_ui/material_ui.dart';

model.WorkQueue sampleQueue() => model.WorkQueue.from(
  crossword: model.Crossword.crossword(width: 8, height: 5).addWord(
    location: model.Location.at(0, 0),
    word: 'cat',
    direction: model.Direction.across,
  )!,
  candidateWords: ['cat', 'cow'],
  startLocation: model.Location.at(0, 0),
);

void main() {
  test('calcula los conteos y el porcentaje ocupado', () {
    final info = model.DisplayInfo.from(workQueue: sampleQueue());
    expect(info.wordsInGridCount, '1');
    expect(info.candidateWordsCount, '1');
    expect(info.locationsToExploreCount, '3');
    expect(info.knownBadLocationsCount, '0');
    expect(info.gridFilledPercentage, '7.5%');
    expect(model.DisplayInfo.empty.wordsInGridCount, '0');
  });

  testWidgets('el menú permite ocultar y volver a mostrar las estadísticas', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          providers.wordListProvider.overrideWith(
            (ref) async => BuiltSet<String>(['cat', 'cow']),
          ),
          providers.workQueueProvider.overrideWith(
            (ref) => Stream.value(sampleQueue()),
          ),
        ],
        child: MaterialApp(home: CrosswordGeneratorApp()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('7.5%'), findsOneWidget);
    await tester.tap(find.byTooltip('Cambiar tamaño'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Display Info'));
    await tester.pumpAndSettle();
    expect(find.text('Estadísticas'), findsNothing);
    await tester.tap(find.byTooltip('Cambiar tamaño'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Display Info'));
    await tester.pumpAndSettle();
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('7.5%'), findsOneWidget);
  });
}
