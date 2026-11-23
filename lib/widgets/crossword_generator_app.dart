import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart';

class CrosswordGeneratorApp extends StatelessWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _EagerInitialization(
      child: Scaffold(
        appBar: AppBar(title: Text('Crossword Generator')),
        body: Consumer(
          builder: (context, ref, child) {
            final wordListAsync = ref.watch(wordListProvider);
            return wordListAsync.when(
              data: (wordList) {
                final words = wordList.toList(growable: false);
                return ListView.builder(
                  itemCount: words.length,
                  itemExtent: 56,
                  itemBuilder: (context, index) =>
                      ListTile(title: Text(words[index])),
                );
              },
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No se pudieron cargar las palabras.\n$error'),
                ),
              ),
              loading: () => Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(wordListProvider);
    return child;
  }
}
