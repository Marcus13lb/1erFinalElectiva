import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'model.dart' as model;
import 'utils.dart';

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
Stream<model.Crossword> crossword(Ref ref) async* {
  final size = ref.watch(sizeProvider);
  Timer? timer;
  Completer<void>? pending;
  ref.onDispose(() {
    timer?.cancel();
    final tick = pending;
    if (tick != null && !tick.isCompleted) tick.complete();
  });
  final words = await ref.watch(wordListProvider.future);
  if (!ref.mounted) return;
  final random = math.Random();
  var grid = model.Crossword.crossword(width: size.width, height: size.height);
  yield grid;
  if (words.isEmpty) return;

  while (ref.mounted &&
      grid.characters.length < size.width * size.height * 0.8) {
    final tick = Completer<void>();
    pending = tick;
    timer = Timer(const Duration(milliseconds: 100), tick.complete);
    await tick.future;
    if (!ref.mounted) return;
    final direction = model.Direction.values[random.nextInt(2)];
    final word = words.randomElement();
    final across = direction == model.Direction.across;
    if (word.length > (across ? size.width : size.height)) continue;
    final location = model.Location.at(
      random.nextInt(across ? size.width - word.length + 1 : size.width),
      random.nextInt(across ? size.height : size.height - word.length + 1),
    );
    grid = grid.addWord(location: location, word: word, direction: direction);
    yield grid;
  }
}
