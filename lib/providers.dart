import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
