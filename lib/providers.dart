import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';

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

@riverpod
Stream<model.WorkQueue> workQueue(Ref ref) async* {
  final size = ref.watch(sizeProvider);
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  final words = await ref.watch(wordListProvider.future);
  if (cancelled || !ref.mounted) return;
  ref.read(startTimeProvider.notifier).start();
  ref.read(endTimeProvider.notifier).clear();
  try {
    yield* exploreCrosswordSolutions(
      crossword: model.Crossword.crossword(
        width: size.width,
        height: size.height,
      ),
      wordList: words,
      isCancelled: () => cancelled,
    );
  } finally {
    if (!cancelled && ref.mounted) ref.read(endTimeProvider.notifier).finish();
  }
}

@Riverpod(keepAlive: true)
class StartTime extends _$StartTime {
  @override
  DateTime? build() => null;
  void start() => state = DateTime.now();
}

@Riverpod(keepAlive: true)
class EndTime extends _$EndTime {
  @override
  DateTime? build() => null;
  void clear() => state = null;
  void finish() => state = DateTime.now();
}

@Riverpod(keepAlive: true)
class ShowDisplayInfo extends _$ShowDisplayInfo {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

const _estimatedTotalCoverage = 0.54;

@riverpod
Duration expectedRemainingTime(Ref ref) {
  final start = ref.watch(startTimeProvider);
  final end = ref.watch(endTimeProvider);
  final progress = ref.watch(
    workQueueProvider.select(
      (value) => value.when(
        data: (queue) => (
          filled: queue.crossword.characters.length,
          total: queue.crossword.width * queue.crossword.height,
        ),
        error: (error, stackTrace) => (filled: 0, total: 0),
        loading: () => (filled: 0, total: 0),
      ),
    ),
  );
  if (start == null ||
      end != null ||
      progress.filled == 0 ||
      progress.total == 0) {
    return Duration.zero;
  }
  final coverage = progress.filled / progress.total;
  if (coverage >= _estimatedTotalCoverage) return Duration.zero;
  final elapsed = DateTime.now().difference(start).inMilliseconds;
  return Duration(
    milliseconds: (elapsed * (_estimatedTotalCoverage / coverage - 1)).round(),
  );
}

@riverpod
class DisplayInfo extends _$DisplayInfo {
  @override
  model.DisplayInfo build() => ref.watch(
    workQueueProvider.select(
      (value) => value.when(
        data: (queue) => model.DisplayInfo.from(workQueue: queue),
        error: (error, stackTrace) => model.DisplayInfo.empty,
        loading: () => model.DisplayInfo.empty,
      ),
    ),
  );
}
