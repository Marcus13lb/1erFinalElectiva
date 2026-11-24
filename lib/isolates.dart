import 'dart:async';
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';

import 'model.dart';
import 'utils.dart';

typedef _WorkerInput = (Crossword, BuiltSet<String>, Location, Direction);
typedef _WorkerResult = (Location, Direction, String?);

_WorkerResult _generateCandidate(_WorkerInput input) {
  final (crossword, words, location, direction) = input;
  final watch = Stopwatch()..start();
  final character = crossword.characters[location]?.character;
  final maxLength = direction == Direction.across
      ? crossword.width
      : crossword.height;
  final candidates =
      words
          .where(
            (word) =>
                word.isNotEmpty &&
                word.characters.length <= maxLength &&
                (character == null || word.contains(character)),
          )
          .toList()
        ..shuffle(Random());
  for (final word in candidates.take(1000)) {
    if (watch.elapsed >= const Duration(seconds: 10)) break;
    final letters = word.characters.toList(growable: false);
    final offsets = character == null
        ? [0]
        : [
            for (var i = 0; i < letters.length; i++)
              if (letters[i] == character) i,
          ];
    for (final offset in offsets) {
      if (watch.elapsed >= const Duration(seconds: 10)) break;
      final start = direction == Direction.across
          ? location.leftOffset(offset)
          : location.upOffset(offset);
      if (crossword.addWord(
            location: start,
            word: word,
            direction: direction,
          ) !=
          null) {
        return (start, direction, word);
      }
    }
  }
  return (location, direction, null);
}

Future<WorkQueue> _generate((WorkQueue, int) input) async {
  final (initial, workerCount) = input;
  if (initial.isCompleted) return initial;
  final locations = initial.locationsToTry.keys.toList()..shuffle(Random());
  final futures = <Future<_WorkerResult>>[
    for (final location in locations.take(workerCount))
      compute(_generateCandidate, (
        initial.crossword,
        initial.candidateWords,
        location,
        initial.locationsToTry[location]!,
      )),
  ];
  final results = await futures.wait;
  var queue = initial;
  for (final (location, direction, word) in results) {
    if (word == null) {
      queue = queue.remove(location);
    } else {
      // Se valida otra vez porque otro trabajador pudo modificar el tablero.
      final candidate = queue.crossword.addWord(
        location: location,
        word: word,
        direction: direction,
      );
      if (candidate != null) queue = queue.updateFrom(candidate);
    }
  }
  return queue;
}

Stream<WorkQueue> exploreCrosswordSolutions({
  required Crossword crossword,
  required BuiltSet<String> wordList,
  required int maxWorkerCount,
  bool Function()? isCancelled,
}) async* {
  if (maxWorkerCount < 1) {
    throw ArgumentError.value(maxWorkerCount, 'maxWorkerCount');
  }
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
      queue = await compute(_generate, (queue, maxWorkerCount));
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
