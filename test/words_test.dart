import 'dart:async';
import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/providers.dart';
import 'package:generate_crossword/widgets/crossword_generator_app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'el diccionario real se carga desde el recurso y queda normalizado',
    () async {
      rootBundle.evict('assets/words.txt');
      final container = ProviderContainer(retry: (retryCount, error) => null);
      addTearDown(container.dispose);
      final words = await container.read(wordListProvider.future);
      expect(words.length, greaterThan(267000));
      expect(words, contains('aardvark'));
      expect(words, contains('zebra'));
      expect(
        words.every((word) => RegExp(r'^[a-z]{3,}$').hasMatch(word)),
        isTrue,
      );
      debugPrint('Palabras válidas cargadas: ${words.length}');
    },
  );

  test(
    'normaliza espacios y mayúsculas, elimina duplicados y palabras inválidas',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      rootBundle.evict('assets/words.txt');
      messenger.setMockMessageHandler('flutter/assets', (message) async {
        final path = utf8.decode(
          message!.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ),
        );
        if (path != 'assets/words.txt') return null;
        return ByteData.sublistView(
          Uint8List.fromList(
            utf8.encode(
              ' CAT \r\ncat\r\nDOG\napple\n zebra \na\nto\n\nabc123\nfoo-bar\nárbol\n',
            ),
          ),
        );
      });
      addTearDown(() {
        messenger.setMockMessageHandler('flutter/assets', null);
        rootBundle.evict('assets/words.txt');
      });
      final container = ProviderContainer(retry: (retryCount, error) => null);
      addTearDown(container.dispose);
      final words = await container.read(wordListProvider.future);
      expect(words.toSet(), {'cat', 'dog', 'apple', 'zebra'});
    },
  );

  testWidgets('muestra carga y luego la cuadrícula de palabras', (
    tester,
  ) async {
    final pendingWords = Completer<BuiltSet<String>>();
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          wordListProvider.overrideWith((ref) => pendingWords.future),
        ],
        child: MaterialApp(home: CrosswordGeneratorApp()),
      ),
    );
    expect(find.text('Crossword Generator'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pendingWords.complete(BuiltSet<String>(['cat', 'dog', 'bird']));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(TableView), findsOneWidget);
    await tester.pumpWidget(SizedBox.shrink());
    await tester.pump();
  });
  testWidgets('muestra un mensaje cuando falla la carga', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          wordListProvider.overrideWith(
            (ref) async => throw StateError('Error de prueba'),
          ),
        ],
        child: MaterialApp(home: CrosswordGeneratorApp()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('No se pudo cargar el crucigrama.'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
