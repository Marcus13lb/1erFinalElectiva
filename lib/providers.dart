import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
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

@riverpod
Stream<model.Crossword> crossword(Ref ref) async* {
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
    isCancelled: () => cancelled,
  );
}
