import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart' as providers;
import 'crossword_widget.dart';

// Vista del generador conservada para consultar los apartados anteriores.
class CrosswordGeneratorApp extends StatelessWidget {
  const CrosswordGeneratorApp({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Crossword Generator'),
      actions: [
        Consumer(
          builder: (context, ref, child) => MenuAnchor(
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
        ),
      ],
    ),
    body: CrosswordWidget(),
  );
}
