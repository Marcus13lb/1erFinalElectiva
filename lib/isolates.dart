import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

import 'model.dart';

typedef _Placement = ({
  Crossword crossword,
  String word,
  Direction direction,
  Location location,
});

Crossword? _evaluatePlacement(_Placement placement) =>
    placement.crossword.addWord(
      word: placement.word,
      direction: placement.direction,
      location: placement.location,
    );

Stream<Crossword> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
  bool Function()? isCancelled,
}) async* {
  var current = crossword;
  yield current;
  final maxLength = max(current.width, current.height);
  final words = wordList
      .where((word) => word.isNotEmpty && word.characters.length <= maxLength)
      .toList(growable: false);
  if (words.isEmpty) return;
  final random = Random();
  while (current.characters.length < current.width * current.height * 0.8 &&
      current.words.length < words.length) {
    if (isCancelled?.call() ?? false) return;
    final word = words[random.nextInt(words.length)];
    final length = word.characters.length;
    final direction = length > current.height
        ? Direction.across
        : length > current.width
        ? Direction.down
        : Direction.values[random.nextInt(2)];
    final across = direction == Direction.across;
    final location = Location.at(
      random.nextInt(across ? current.width - length + 1 : current.width),
      random.nextInt(across ? current.height : current.height - length + 1),
    );
    // Solo se envían modelos y valores al aislamiento; nunca un Ref de Riverpod.
    final candidate = await compute(_evaluatePlacement, (
      crossword: current,
      word: word,
      direction: direction,
      location: location,
    ));
    if (isCancelled?.call() ?? false) return;
    if (candidate != null) {
      current = candidate;
      yield current;
    }
  }
}
