import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart' as providers;
import 'crossword_generator_widget.dart';
import 'crossword_puzzle_widget.dart';
import 'puzzle_completed_widget.dart';

class CrosswordPuzzleApp extends ConsumerWidget {
  const CrosswordPuzzleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      providers.workQueueProvider.select(
        (value) => (
          loading: value.isLoading,
          error: value.error,
          completed: value.asData?.value.isCompleted ?? false,
        ),
      ),
    );
    final puzzle = ref.watch(providers.puzzleProvider);
    void newPuzzle() => ref.invalidate(providers.workQueueProvider);
    Widget body;
    if (status.error != null) {
      body = Center(
        child: Text('No se pudo generar el crucigrama.\n${status.error}'),
      );
    } else if (status.loading || !status.completed) {
      body = Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Text('Generando crucigrama…'),
          ),
          Expanded(child: CrosswordGeneratorWidget()),
        ],
      );
    } else {
      body = puzzle.when(
        data: (game) {
          if (game == null) return Center(child: CircularProgressIndicator());
          if (game.solved) return PuzzleCompletedWidget(onPlayAgain: newPuzzle);
          if (game.crossword.words.isEmpty) {
            return Center(
              child: Text(
                'No se generaron palabras. Crea un crucigrama nuevo.',
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Pulsa una celda para elegir una palabra.  ${game.selectedWords.length}/${game.crossword.words.length} colocadas',
                ),
              ),
              Expanded(child: CrosswordPuzzleWidget()),
            ],
          );
        },
        error: (error, stackTrace) =>
            Center(child: Text('No se pudo preparar el juego.\n$error')),
        loading: () => Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Crossword Puzzle'),
        actions: [
          IconButton(
            tooltip: 'Nuevo crucigrama',
            icon: Icon(Icons.refresh),
            onPressed: newPuzzle,
          ),
          MenuAnchor(
            menuChildren: [
              for (final size in providers.CrosswordSize.values)
                MenuItemButton(
                  onPressed: () =>
                      ref.read(providers.sizeProvider.notifier).setSize(size),
                  child: Text(size.label),
                ),
            ],
            builder: (context, controller, child) => IconButton(
              tooltip: 'Cambiar tamaño',
              icon: Icon(Icons.settings),
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
            ),
          ),
        ],
      ),
      body: body,
    );
  }
}
