import 'dart:math';

import 'package:built_collection/built_collection.dart';

final _random = Random();

extension RandomElements<E> on BuiltSet<E> {
  E randomElement() {
    if (isEmpty) throw StateError('No hay elementos para elegir.');
    return elementAt(_random.nextInt(length));
  }
}
