import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart' as providers;
import 'crossword_widget.dart';

class CrosswordGeneratorApp extends StatelessWidget {
  const CrosswordGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return _EagerInitialization(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Crossword Generator'),
          actions: [_CrosswordGeneratorMenu()],
        ),
        // Antes: se mostraba la lista de palabras del apartado 4.
        body: CrosswordWidget(),
      ),
    );
  }
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(providers.wordListProvider);
    return child;
  }
}

class _CrosswordGeneratorMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(providers.sizeProvider);
    return MenuAnchor(
      menuChildren: [
        for (final size in providers.CrosswordSize.values)
          MenuItemButton(
            onPressed: () =>
                ref.read(providers.sizeProvider.notifier).setSize(size),
            leadingIcon: size == selected
                ? Icon(Icons.check)
                : SizedBox(width: 24),
            child: Text(size.label),
          ),
      ],
      builder: (context, controller, child) => IconButton(
        tooltip: 'Cambiar tamaño',
        icon: Icon(Icons.settings),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
