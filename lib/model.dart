import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:characters/characters.dart';

part 'model.g.dart';

abstract class Location implements Built<Location, LocationBuilder> {
  Location._();
  factory Location([void Function(LocationBuilder) updates]) = _$Location;
  factory Location.at(int x, int y) => Location(
    (b) => b
      ..x = x
      ..y = y,
  );

  int get x;
  int get y;
  Location get left => leftOffset(1);
  Location get right => rightOffset(1);
  Location get up => upOffset(1);
  Location get down => downOffset(1);
  Location leftOffset(int offset) => Location.at(x - offset, y);
  Location rightOffset(int offset) => Location.at(x + offset, y);
  Location upOffset(int offset) => Location.at(x, y - offset);
  Location downOffset(int offset) => Location.at(x, y + offset);
  String prettyPrint() => '($x, $y)';
  static Serializer<Location> get serializer => _$locationSerializer;
}

enum Direction {
  across,
  down;

  @override
  String toString() => name;
}

abstract class CrosswordWord
    implements Built<CrosswordWord, CrosswordWordBuilder> {
  CrosswordWord._();
  factory CrosswordWord([void Function(CrosswordWordBuilder) updates]) =
      _$CrosswordWord;
  factory CrosswordWord.word({
    required String word,
    required Location location,
    required Direction direction,
  }) => CrosswordWord(
    (b) => b
      ..word = word
      ..location = location.toBuilder()
      ..direction = direction,
  );

  String get word;
  Location get location;
  Direction get direction;

  static int locationComparator(CrosswordWord a, CrosswordWord b) {
    final row = a.location.y.compareTo(b.location.y);
    if (row != 0) return row;
    final column = a.location.x.compareTo(b.location.x);
    if (column != 0) return column;
    final direction = a.direction.index.compareTo(b.direction.index);
    return direction != 0 ? direction : a.word.compareTo(b.word);
  }

  static Serializer<CrosswordWord> get serializer => _$crosswordWordSerializer;
}

abstract class CrosswordCharacter
    implements Built<CrosswordCharacter, CrosswordCharacterBuilder> {
  CrosswordCharacter._();
  factory CrosswordCharacter([
    void Function(CrosswordCharacterBuilder) updates,
  ]) = _$CrosswordCharacter;
  factory CrosswordCharacter.character({
    required String character,
    CrosswordWord? acrossWord,
    CrosswordWord? downWord,
  }) => CrosswordCharacter(
    (b) => b
      ..character = character
      ..acrossWord = acrossWord?.toBuilder()
      ..downWord = downWord?.toBuilder(),
  );

  String get character;
  CrosswordWord? get acrossWord;
  CrosswordWord? get downWord;
  static Serializer<CrosswordCharacter> get serializer =>
      _$crosswordCharacterSerializer;
}

abstract class Crossword implements Built<Crossword, CrosswordBuilder> {
  Crossword._();
  factory Crossword([void Function(CrosswordBuilder) updates]) = _$Crossword;
  factory Crossword.crossword({required int width, required int height}) =>
      Crossword(
        (b) => b
          ..width = width
          ..height = height,
      );

  int get width;
  int get height;
  BuiltList<CrosswordWord> get words;
  BuiltMap<Location, CrosswordCharacter> get characters;

  Crossword addWord({
    required Location location,
    required String word,
    required Direction direction,
  }) => rebuild(
    (b) => b.words.add(
      CrosswordWord.word(word: word, location: location, direction: direction),
    ),
  );

  @BuiltValueHook(finalizeBuilder: true)
  static void _fillCharacters(CrosswordBuilder b) {
    b.characters.clear();
    for (final word in b.words.build()) {
      for (final (index, character) in word.word.characters.indexed) {
        final location = switch (word.direction) {
          Direction.across => word.location.rightOffset(index),
          Direction.down => word.location.downOffset(index),
        };
        final previous = b.characters[location];
        b.characters[location] = CrosswordCharacter.character(
          character: character,
          acrossWord: word.direction == Direction.across
              ? word
              : previous?.acrossWord,
          downWord: word.direction == Direction.down
              ? word
              : previous?.downWord,
        );
      }
    }
  }

  String prettyPrintCrossword() => [
    for (var y = 0; y < height; y++)
      [
        for (var x = 0; x < width; x++)
          characters[Location.at(x, y)]?.character ?? '.',
      ].join(),
  ].join('\n');

  static Serializer<Crossword> get serializer => _$crosswordSerializer;
}

@SerializersFor([Location, Crossword, CrosswordWord, CrosswordCharacter])
final Serializers serializers =
    (_$serializers.toBuilder()..add(_DirectionSerializer())).build();

class _DirectionSerializer implements PrimitiveSerializer<Direction> {
  @override
  Iterable<Type> get types => const [Direction];
  @override
  String get wireName => 'Direction';
  @override
  Object serialize(
    Serializers serializers,
    Direction object, {
    FullType specifiedType = FullType.unspecified,
  }) => object.name;
  @override
  Direction deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => Direction.values.byName(serialized as String);
}
