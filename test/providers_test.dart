import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/model.dart' as model;
import 'package:generate_crossword/providers.dart';

void main() {
  test('genera un resultado válido y reinicia al cambiar el tamaño', () async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        wordListProvider.overrideWith(
          (ref) async => BuiltSet<String>(['cat', 'cow', 'dog']),
        ),
      ],
    );
    final events = StreamController<model.WorkQueue>();
    container.listen(workQueueProvider, (previous, next) {
      if (next case AsyncData(:final value)) events.add(value);
      if (next case AsyncError(:final error, :final stackTrace)) {
        events.addError(error, stackTrace);
      }
    });
    final iterator = StreamIterator(events.stream);
    try {
      expect(await iterator.moveNext().timeout(Duration(seconds: 10)), isTrue);
      expect(iterator.current.crossword.words, isEmpty);
      do {
        await iterator.moveNext().timeout(Duration(seconds: 10));
      } while (iterator.current.crossword.words.isEmpty);
      expect(iterator.current.crossword.valid, isTrue);
      expect(iterator.current.crossword.width, 40);
      container.read(sizeProvider.notifier).setSize(CrosswordSize.small);
      do {
        await iterator.moveNext().timeout(Duration(seconds: 10));
      } while (iterator.current.crossword.width != 20);
      expect(iterator.current.crossword.words, isEmpty);
      expect(iterator.current.crossword.height, 11);
    } finally {
      container.dispose();
      await iterator.cancel();
      await events.close();
    }
  });

  test('un diccionario vacío produce una cuadrícula vacía', () async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        wordListProvider.overrideWith((ref) async => BuiltSet<String>()),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      workQueueProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);
    final grid = await container.read(workQueueProvider.future);
    expect(grid.crossword.words, isEmpty);
    expect(grid.crossword.valid, isTrue);
  });
}
