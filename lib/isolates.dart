import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

import 'model.dart';
import 'utils.dart';

WorkQueue _advanceWorkQueue(WorkQueue queue) {
  if (queue.isCompleted) return queue;
  final random = Random();
  final location = queue.locationsToTry.keys.elementAt(
    random.nextInt(queue.locationsToTry.length),
  );
  final direction = queue.locationsToTry[location]!;
  final crossword = queue.crossword;
  final character = crossword.characters[location]?.character;
  final maxLength = direction == Direction.across
      ? crossword.width
      : crossword.height;
  final candidates =
      queue.candidateWords
          .where(
            (word) =>
                word.isNotEmpty &&
                word.characters.length <= maxLength &&
                (character == null || word.contains(character)),
          )
          .toList()
        ..shuffle(random);

  for (final word in candidates.take(1000)) {
    final letters = word.characters.toList(growable: false);
    final offsets = character == null
        ? [0]
        : [
            for (var i = 0; i < letters.length; i++)
              if (letters[i] == character) i,
          ];
    for (final offset in offsets) {
      final start = direction == Direction.across
          ? location.leftOffset(offset)
          : location.upOffset(offset);
      final candidate = crossword.addWord(
        location: start,
        word: word,
        direction: direction,
      );
      if (candidate != null) return queue.updateFrom(candidate);
    }
  }
  return queue.remove(location);
}

Stream<WorkQueue> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
  bool Function()? isCancelled,
}) async* {
  final stopwatch = Stopwatch()..start();

  var queue = WorkQueue.from(
    crossword: crossword,
    candidateWords: wordList,
    startLocation: Location.at(0, 0),
  );
  yield queue;
  try {
    while (!queue.isCompleted) {
      if (isCancelled?.call() ?? false) return;
      // Solo se envía la cola inmutable al aislamiento, sin referencias a Riverpod.
      queue = await compute(_advanceWorkQueue, queue);
      if (isCancelled?.call() ?? false) return;
      yield queue;
    }
  } finally {
    stopwatch.stop();
    debugPrint(
      'Generación ${isCancelled?.call() == true ? 'interrumpida' : 'finalizada'} en ${stopwatch.elapsed.formatted}',
    );
  }
}
