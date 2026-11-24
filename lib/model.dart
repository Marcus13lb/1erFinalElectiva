import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:characters/characters.dart';
import 'package:intl/intl.dart';

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

  bool get valid {
    if (width <= 0 || height <= 0) return false;
    final usedWords = <String>{};
    final occupied = <Location>{};
    for (final word in words) {
      if (word.word.isEmpty || !usedWords.add(word.word)) return false;
      for (final (index, letter) in word.word.characters.indexed) {
        final location = word.direction == Direction.across
            ? word.location.rightOffset(index)
            : word.location.downOffset(index);
        if (location.x < 0 ||
            location.x >= width ||
            location.y < 0 ||
            location.y >= height) {
          return false;
        }
        final cell = characters[location];
        if (cell == null || cell.character != letter) return false;
        if (word.direction == Direction.across && cell.acrossWord != word) {
          return false;
        }
        if (word.direction == Direction.down && cell.downWord != word) {
          return false;
        }
        occupied.add(location);
      }
    }
    if (occupied.length != characters.length) return false;
    for (final entry in characters.entries) {
      final location = entry.key;
      final cell = entry.value;
      if (cell.acrossWord == null && cell.downWord == null) return false;
      final right = characters[location.right];
      if (right != null &&
          (cell.acrossWord == null || cell.acrossWord != right.acrossWord)) {
        return false;
      }
      final below = characters[location.down];
      if (below != null &&
          (cell.downWord == null || cell.downWord != below.downWord)) {
        return false;
      }
    }
    return true;
  }

  Crossword? addWord({
    required Location location,
    required String word,
    required Direction direction,
    bool requireOverlap = true,
  }) {
    if (word.isEmpty || words.any((existing) => existing.word == word)) {
      return null;
    }
    var crossesExistingWord = false;
    for (final (index, letter) in word.characters.indexed) {
      final position = direction == Direction.across
          ? location.rightOffset(index)
          : location.downOffset(index);
      if (position.x < 0 ||
          position.x >= width ||
          position.y < 0 ||
          position.y >= height) {
        return null;
      }
      final cell = characters[position];
      if (cell == null) continue;
      if (cell.character != letter ||
          (direction == Direction.across && cell.acrossWord != null) ||
          (direction == Direction.down && cell.downWord != null)) {
        return null;
      }
      crossesExistingWord = true;
    }
    if (requireOverlap && words.isNotEmpty && !crossesExistingWord) return null;
    final candidate = rebuild(
      (b) => b.words.add(
        CrosswordWord.word(
          word: word,
          location: location,
          direction: direction,
        ),
      ),
    );
    return candidate.valid ? candidate : null;
  }

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

abstract class WorkQueue implements Built<WorkQueue, WorkQueueBuilder> {
  WorkQueue._();
  factory WorkQueue([void Function(WorkQueueBuilder) updates]) = _$WorkQueue;

  Crossword get crossword;
  BuiltMap<Location, Direction> get locationsToTry;
  BuiltSet<Location> get badLocations;
  BuiltSet<String> get candidateWords;
  bool get isCompleted => locationsToTry.isEmpty || candidateWords.isEmpty;

  static WorkQueue from({
    required Crossword crossword,
    required Iterable<String> candidateWords,
    required Location startLocation,
  }) {
    final locations = <Location, Direction>{};
    final cells = crossword.characters;
    if (crossword.words.isEmpty) {
      locations[startLocation] = Direction.across;
    } else {
      for (final entry in cells.entries) {
        final location = entry.key;
        final cell = entry.value;
        if (cell.acrossWord != null &&
            cell.downWord == null &&
            !cells.containsKey(location.up) &&
            !cells.containsKey(location.down)) {
          locations[location] = Direction.down;
        } else if (cell.downWord != null &&
            cell.acrossWord == null &&
            !cells.containsKey(location.left) &&
            !cells.containsKey(location.right)) {
          locations[location] = Direction.across;
        }
      }
    }
    final used = crossword.words.map((word) => word.word).toSet();
    return WorkQueue(
      (b) => b
        ..crossword.replace(crossword)
        ..locationsToTry.addAll(locations)
        ..candidateWords.addAll(
          candidateWords.where((word) => !used.contains(word)),
        ),
    );
  }

  WorkQueue remove(Location location) => rebuild(
    (b) => b
      ..locationsToTry.remove(location)
      ..badLocations.add(location),
  );

  WorkQueue updateFrom(Crossword crossword) {
    final next = WorkQueue.from(
      crossword: crossword,
      candidateWords: candidateWords,
      startLocation: Location.at(0, 0),
    );
    return next.rebuild(
      (b) => b
        ..badLocations.addAll(badLocations)
        ..locationsToTry.removeWhere(
          (location, direction) => badLocations.contains(location),
        ),
    );
  }

  static Serializer<WorkQueue> get serializer => _$workQueueSerializer;
}

abstract class DisplayInfo implements Built<DisplayInfo, DisplayInfoBuilder> {
  DisplayInfo._();
  factory DisplayInfo([void Function(DisplayInfoBuilder) updates]) =
      _$DisplayInfo;

  String get wordsInGridCount;
  String get candidateWordsCount;
  String get locationsToExploreCount;
  String get knownBadLocationsCount;
  String get gridFilledPercentage;

  factory DisplayInfo.from({required WorkQueue workQueue}) {
    final format = NumberFormat.decimalPattern();
    final grid = workQueue.crossword;
    final total = grid.width * grid.height;
    final percentage = total == 0 ? 0.0 : grid.characters.length / total * 100;
    return DisplayInfo(
      (b) => b
        ..wordsInGridCount = format.format(grid.words.length)
        ..candidateWordsCount = format.format(workQueue.candidateWords.length)
        ..locationsToExploreCount = format.format(
          workQueue.locationsToTry.length,
        )
        ..knownBadLocationsCount = format.format(workQueue.badLocations.length)
        ..gridFilledPercentage = '${percentage.toStringAsFixed(1)}%',
    );
  }

  static DisplayInfo get empty => DisplayInfo(
    (b) => b
      ..wordsInGridCount = '0'
      ..candidateWordsCount = '0'
      ..locationsToExploreCount = '0'
      ..knownBadLocationsCount = '0'
      ..gridFilledPercentage = '0.0%',
  );

  static Serializer<DisplayInfo> get serializer => _$displayInfoSerializer;
}

abstract class CrosswordPuzzleGame
    implements Built<CrosswordPuzzleGame, CrosswordPuzzleGameBuilder> {
  CrosswordPuzzleGame._();
  factory CrosswordPuzzleGame([
    void Function(CrosswordPuzzleGameBuilder) updates,
  ]) = _$CrosswordPuzzleGame;

  Crossword get crossword;
  BuiltMap<Location, BuiltMap<Direction, BuiltList<String>>> get alternateWords;
  BuiltList<CrosswordWord> get selectedWords;

  factory CrosswordPuzzleGame.from({
    required Crossword crossword,
    required BuiltSet<String> candidateWords,
  }) {
    final lengths = crossword.words
        .map((word) => word.word.characters.length)
        .toSet();
    final used = crossword.words.map((word) => word.word).toSet();
    final buckets = <int, List<String>>{
      for (final length in lengths) length: [],
    };
    for (final word in candidateWords) {
      if (!used.contains(word)) buckets[word.characters.length]?.add(word);
    }
    final random = Random();
    final choices = <Location, BuiltMap<Direction, BuiltList<String>>>{};
    for (final slot in crossword.words) {
      final pool = buckets[slot.word.characters.length]!;
      pool.shuffle(random);
      final alternatives = pool.take(4).toList()..sort();
      final previous =
          choices[slot.location] ?? BuiltMap<Direction, BuiltList<String>>();
      choices[slot.location] = previous.rebuild(
        (b) => b[slot.direction] = BuiltList<String>(alternatives),
      );
    }
    return CrosswordPuzzleGame(
      (b) => b
        ..crossword.replace(crossword)
        ..alternateWords.addAll(choices),
    );
  }

  Crossword? _buildSelection(Iterable<CrosswordWord> selection) {
    var grid = Crossword.crossword(
      width: crossword.width,
      height: crossword.height,
    );
    for (final selected in selection) {
      final next = grid.addWord(
        location: selected.location,
        word: selected.word,
        direction: selected.direction,
        requireOverlap: false,
      );
      if (next == null) return null;
      grid = next;
    }
    return grid;
  }

  @memoized
  Crossword get crosswordFromSelectedWords =>
      _buildSelection(selectedWords) ??
      (throw StateError('La selección de palabras no es válida.'));

  bool get solved =>
      crossword.words.isNotEmpty &&
      selectedWords.length == crossword.words.length &&
      crosswordFromSelectedWords.valid;

  bool canSelectWord({
    required Location location,
    required String word,
    required Direction direction,
  }) {
    final slot = crossword.words
        .where(
          (slot) => slot.location == location && slot.direction == direction,
        )
        .firstOrNull;
    if (slot == null) return false;
    if (word != slot.word &&
        !(alternateWords[location]?[direction]?.contains(word) ?? false)) {
      return false;
    }
    final selection =
        selectedWords
            .where(
              (selected) =>
                  selected.location != location ||
                  selected.direction != direction,
            )
            .toList()
          ..add(
            CrosswordWord.word(
              word: word,
              location: location,
              direction: direction,
            ),
          );
    return _buildSelection(selection) != null;
  }

  CrosswordPuzzleGame? selectWord({
    required Location location,
    required String word,
    required Direction direction,
  }) {
    if (!canSelectWord(location: location, word: word, direction: direction)) {
      return null;
    }
    return rebuild(
      (b) => b.selectedWords
        ..removeWhere(
          (selected) =>
              selected.location == location && selected.direction == direction,
        )
        ..add(
          CrosswordWord.word(
            word: word,
            location: location,
            direction: direction,
          ),
        ),
    );
  }

  CrosswordPuzzleGame clearWord({
    required Location location,
    required Direction direction,
  }) => rebuild(
    (b) => b.selectedWords
      ..removeWhere(
        (selected) =>
            selected.location == location && selected.direction == direction,
      ),
  );

  static Serializer<CrosswordPuzzleGame> get serializer =>
      _$crosswordPuzzleGameSerializer;
}

@SerializersFor([
  Location,
  Crossword,
  CrosswordWord,
  CrosswordCharacter,
  WorkQueue,
  DisplayInfo,
  CrosswordPuzzleGame,
])
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
