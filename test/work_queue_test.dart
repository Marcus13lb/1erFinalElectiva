import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/isolates.dart';
import 'package:generate_crossword/model.dart';
import 'package:generate_crossword/utils.dart';

void main() {
  test('la cola conserva cruces disponibles, palabras pendientes y posiciones descartadas', () {
    final empty = Crossword.crossword(width: 8, height: 6);
    final queue = WorkQueue.from(
      crossword: empty,
      candidateWords: ['cat', 'cow', 'art', 'dog'],
      startLocation: Location.at(0, 0),
    );
    expect(queue.locationsToTry[Location.at(0, 0)], Direction.across);
    final across = empty.addWord(
      location: Location.at(0, 0),
      word: 'cat',
      direction: Direction.across,
    )!;
    final afterWord = queue.updateFrom(across);
    expect(afterWord.candidateWords, isNot(contains('cat')));
    expect(afterWord.locationsToTry[Location.at(1, 0)], Direction.down);
    final removed = afterWord.remove(Location.at(1, 0));
    final crossed = across.addWord(
      location: Location.at(0, 0),
      word: 'cow',
      direction: Direction.down,
    )!;
    final updated = removed.updateFrom(crossed);
    expect(updated.badLocations, contains(Location.at(1, 0)));
    expect(updated.locationsToTry.containsKey(Location.at(1, 0)), isFalse);
    expect(updated.locationsToTry.containsKey(Location.at(0, 0)), isFalse);
    expect(
      serializers.deserializeWith(
        WorkQueue.serializer,
        serializers.serializeWith(WorkQueue.serializer, updated),
      ),
      updated,
    );
    expect(Duration(seconds: 65).formatted, '1:05');
  });

  test(
    'la búsqueda guiada termina con un crucigrama válido en segundo plano',
    () async {
      final updates = await exploreCrosswordSolutions(
        crossword: Crossword.crossword(width: 8, height: 6),
        wordList: BuiltSet<String>([
          'cat',
          'cow',
          'art',
          'owl',
          'dog',
          'row',
          'tar',
        ]),
      ).toList().timeout(Duration(seconds: 10));
      expect(updates.first.crossword.words, isEmpty);
      expect(updates.last.crossword.words, isNotEmpty);
      expect(updates.every((queue) => queue.crossword.valid), isTrue);
      expect(updates.last.crossword.words.length, lessThanOrEqualTo(7));
    },
  );
}
