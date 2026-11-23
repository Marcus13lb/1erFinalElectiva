import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/model.dart';

void main() {
  test('las ubicaciones tienen igualdad por valor y permiten desplazarse', () {
    final location = Location.at(3, 4);
    expect(location, Location.at(3, 4));
    expect({location: 'letra'}[Location.at(3, 4)], 'letra');
    expect(location.left, Location.at(2, 4));
    expect(location.right, Location.at(4, 4));
    expect(location.up, Location.at(3, 3));
    expect(location.down, Location.at(3, 5));
    expect(location.leftOffset(2), Location.at(1, 4));
    expect(location.rightOffset(2), Location.at(5, 4));
    expect(location.upOffset(2), Location.at(3, 2));
    expect(location.downOffset(2), Location.at(3, 6));
    expect(location.prettyPrint(), '(3, 4)');
  });

  test(
    'agrega palabras sin modificar las anteriores y registra los cruces',
    () {
      final empty = Crossword.crossword(width: 5, height: 4);
      final across = empty.addWord(
        location: Location.at(0, 0),
        word: 'cat',
        direction: Direction.across,
      );
      final crossed = across.addWord(
        location: Location.at(0, 0),
        word: 'cow',
        direction: Direction.down,
      );
      expect(empty.words, isEmpty);
      expect(empty.characters, isEmpty);
      expect(across.words, hasLength(1));
      expect(across.characters, hasLength(3));
      expect(crossed.words, hasLength(2));
      expect(crossed.characters, hasLength(5));
      final crossing = crossed.characters[Location.at(0, 0)]!;
      expect(crossing.character, 'c');
      expect(crossing.acrossWord!.word, 'cat');
      expect(crossing.downWord!.word, 'cow');
      expect(crossed.prettyPrintCrossword(), 'cat..\no....\nw....\n.....');
      expect(
        CrosswordWord.locationComparator(
          across.words.first,
          CrosswordWord.word(
            word: 'dog',
            location: Location.at(0, 1),
            direction: Direction.across,
          ),
        ),
        lessThan(0),
      );
    },
  );

  test('los modelos se pueden serializar y recuperar con sus direcciones', () {
    final grid = Crossword.crossword(width: 5, height: 4)
        .addWord(
          location: Location.at(0, 0),
          word: 'cat',
          direction: Direction.across,
        )
        .addWord(
          location: Location.at(0, 0),
          word: 'cow',
          direction: Direction.down,
        );
    final data = serializers.serializeWith(Crossword.serializer, grid);
    final restored = serializers.deserializeWith(Crossword.serializer, data);
    expect(restored, grid);
    expect(
      restored!.characters[Location.at(0, 0)]!.downWord!.direction,
      Direction.down,
    );
  });
}
