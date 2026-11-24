import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model.dart' as model;
import 'isolates.dart';

part 'providers.g.dart';

@riverpod
Future<BuiltSet<String>> wordList(Ref ref) async {
  final text = await rootBundle.loadString('assets/words.txt');
  final letters = RegExp(r'^[a-z]+$');
  return BuiltSet<String>(
    const LineSplitter()
        .convert(text)
        .map((word) => word.trim().toLowerCase())
        .where((word) => word.length > 2 && letters.hasMatch(word)),
  );
}

enum CrosswordSize {
  small(20, 11),
  medium(40, 22),
  large(80, 44),
  xlarge(160, 88),
  xxlarge(500, 500);

  const CrosswordSize(this.width, this.height);
  final int width;
  final int height;
  String get label => '$width x $height';
}

@Riverpod(keepAlive: true)
class Size extends _$Size {
  @override
  CrosswordSize build() => CrosswordSize.medium;
  void setSize(CrosswordSize size) => state = size;
}

const backgroundWorkerCount = 4;

@riverpod
Stream<model.WorkQueue> workQueue(Ref ref) async* {
  final size = ref.watch(sizeProvider);
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  final words = await ref.watch(wordListProvider.future);
  if (cancelled || !ref.mounted) return;
  yield* exploreCrosswordSolutions(
    crossword: model.Crossword.crossword(
      width: size.width,
      height: size.height,
    ),
    wordList: words,
    maxWorkerCount: backgroundWorkerCount,
    isCancelled: () => cancelled,
  );
}

model.CrosswordPuzzleGame _puzzleFromCrosswordTrampoline(
  (model.Crossword, BuiltSet<String>) args,
) =>
    model.CrosswordPuzzleGame.from(crossword: args.$1, candidateWords: args.$2);

model.CrosswordPuzzleGame? _puzzleSelectWordTrampoline(
  (model.CrosswordPuzzleGame, model.Location, String, model.Direction) args,
) => args.$1.selectWord(location: args.$2, word: args.$3, direction: args.$4);

@riverpod
class Puzzle extends _$Puzzle {
  bool _selecting = false;

  @override
  Future<model.CrosswordPuzzleGame?> build() async {
    final completed = ref.watch(
      workQueueProvider.select(
        (value) => value.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          data: (queue) => queue.isCompleted ? queue : null,
          error: (error, stackTrace) => null,
          loading: () => null,
        ),
      ),
    );
    if (completed == null) return null;
    return compute(_puzzleFromCrosswordTrampoline, (
      completed.crossword,
      completed.candidateWords,
    ));
  }

  Future<void> selectWord({
    required model.Location location,
    required String word,
    required model.Direction direction,
  }) async {
    final game = state.asData?.value;
    if (game == null || _selecting) return;
    _selecting = true;
    try {
      final next = await compute(_puzzleSelectWordTrampoline, (
        game,
        location,
        word,
        direction,
      ));
      if (ref.mounted && identical(state.asData?.value, game) && next != null) {
        state = AsyncData(next);
      }
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
    } finally {
      _selecting = false;
    }
  }

  void clearWord({
    required model.Location location,
    required model.Direction direction,
  }) {
    final game = state.asData?.value;
    if (game != null) {
      state = AsyncData(
        game.clearWord(location: location, direction: direction),
      );
    }
  }
}
