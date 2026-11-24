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
  });

  test('acepta cruces válidos y rechaza duplicados, conflictos y posiciones inválidas', () {
    final empty = Crossword.crossword(width: 5, height: 4);
    final across = empty.addWord(
      location: Location.at(0, 0),
      word: 'cat',
      direction: Direction.across,
    )!;
    final crossed = across.addWord(
      location: Location.at(0, 0),
      word: 'cow',
      direction: Direction.down,
    )!;
    expect(empty.words, isEmpty);
    expect(across.characters, hasLength(3));
    expect(crossed.characters, hasLength(5));
    expect(crossed.valid, isTrue);
    expect(crossed.prettyPrintCrossword(), 'cat..\no....\nw....\n.....');
    expect(crossed.characters[Location.at(0, 0)]!.acrossWord!.word, 'cat');
    expect(crossed.characters[Location.at(0, 0)]!.downWord!.word, 'cow');
    expect(
      across.addWord(
        location: Location.at(0, 2),
        word: 'cat',
        direction: Direction.across,
      ),
      isNull,
    );
    expect(
      across.addWord(
        location: Location.at(0, 2),
        word: 'dog',
        direction: Direction.across,
      ),
      isNull,
    );
    expect(
      across.addWord(
        location: Location.at(0, 0),
        word: 'dog',
        direction: Direction.down,
      ),
      isNull,
    );
    expect(
      across.addWord(
        location: Location.at(0, 0),
        word: 'car',
        direction: Direction.across,
      ),
      isNull,
    );
    expect(
      empty.addWord(
        location: Location.at(-1, 0),
        word: 'cat',
        direction: Direction.across,
      ),
      isNull,
    );
    expect(
      empty.addWord(
        location: Location.at(4, 0),
        word: 'cat',
        direction: Direction.across,
      ),
      isNull,
    );
    expect(
      crossed.addWord(
        location: Location.at(0, 1),
        word: 'owl',
        direction: Direction.across,
      ),
      isNull,
    );
  });

  test('los modelos se pueden serializar y recuperar con sus direcciones', () {
    final across = Crossword.crossword(width: 5, height: 4).addWord(
      location: Location.at(0, 0),
      word: 'cat',
      direction: Direction.across,
    )!;
    final grid = across.addWord(
      location: Location.at(0, 0),
      word: 'cow',
      direction: Direction.down,
    )!;
    final data = serializers.serializeWith(Crossword.serializer, grid);
    expect(serializers.deserializeWith(Crossword.serializer, data), grid);
  });
}
