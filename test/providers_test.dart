import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/model.dart' as model;
import 'package:generate_crossword/providers.dart';

void main() {
  testWidgets('genera cada 100 ms y reinicia al cambiar el tamaño', (
    tester,
  ) async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        wordListProvider.overrideWith(
          (ref) async => BuiltSet<String>(['cat', 'dog', 'bird']),
        ),
      ],
    );
    final updates = <model.Crossword>[];
    container.listen(crosswordProvider, (previous, next) {
      if (next case AsyncData(:final value)) updates.add(value);
    });
    expect(container.read(sizeProvider), CrosswordSize.medium);
    await tester.pump();
    expect(updates.last.words, isEmpty);
    expect(updates.last.width, 40);
    for (var tick = 0; tick < 3; tick++) {
      await tester.pump(Duration(milliseconds: 100));
    }
    expect(updates.last.words, hasLength(3));
    final previous = updates.last;
    expect(
      previous.characters.keys.every(
        (location) =>
            location.x >= 0 &&
            location.x < 40 &&
            location.y >= 0 &&
            location.y < 22,
      ),
      isTrue,
    );
    container.read(sizeProvider.notifier).setSize(CrosswordSize.small);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(updates.last.width, 20);
    expect(updates.last.height, 11);
    expect(updates.last.words, isEmpty);
    await tester.pump(Duration(milliseconds: 100));
    expect(updates.last.words, hasLength(1));
    expect(previous.words, hasLength(3));
    container.dispose();
    await tester.pump();
  });

  testWidgets('la generación se detiene al llenar al menos el 80 por ciento', (
    tester,
  ) async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        wordListProvider.overrideWith(
          (ref) async => BuiltSet<String>(['abcdefghijklmnopqrst']),
        ),
      ],
    );
    container.read(sizeProvider.notifier).setSize(CrosswordSize.small);
    final updates = <model.Crossword>[];
    container.listen(crosswordProvider, (previous, next) {
      if (next case AsyncData(:final value)) updates.add(value);
    });
    await tester.pump();
    for (
      var tick = 0;
      tick < 500 && updates.last.characters.length < 176;
      tick++
    ) {
      await tester.pump(Duration(milliseconds: 100));
    }
    expect(updates.last.characters.length, greaterThanOrEqualTo(176));
    final count = updates.length;
    await tester.pump(Duration(seconds: 1));
    expect(updates, hasLength(count));
    container.dispose();
    await tester.pump();
  });
}
