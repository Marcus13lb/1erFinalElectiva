import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart' as providers;
import 'crossword_widget.dart';
import 'crossword_info_widget.dart';

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
        body: Stack(
          children: [
            CrosswordWidget(),
            Consumer(
              builder: (context, ref, child) {
                if (!ref.watch(providers.showDisplayInfoProvider)) {
                  return SizedBox.shrink();
                }
                return Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CrosswordInfoWidget(),
                  ),
                );
              },
            ),
          ],
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
    ref.watch(providers.wordListProvider);
    return child;
  }
}

class _CrosswordGeneratorMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(providers.sizeProvider);
    final selectedWorkers = ref.watch(providers.workerCountProvider);
    final showInfo = ref.watch(providers.showDisplayInfoProvider);
    return MenuAnchor(
      menuChildren: [
        SubmenuButton(
          leadingIcon: Icon(Icons.memory),
          menuChildren: [
            for (final workers in providers.BackgroundWorkers.values)
              MenuItemButton(
                onPressed: () => ref
                    .read(providers.workerCountProvider.notifier)
                    .setWorkerCount(workers),
                leadingIcon: Icon(
                  workers == selectedWorkers
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                child: Text('${workers.count} trabajadores'),
              ),
          ],
          child: Text('Trabajadores: ${selectedWorkers.count}'),
        ),
        MenuItemButton(
          onPressed: () =>
              ref.read(providers.showDisplayInfoProvider.notifier).toggle(),
          leadingIcon: Icon(
            showInfo ? Icons.check_box : Icons.check_box_outline_blank,
          ),
          child: Text('Display Info'),
        ),
        Divider(),
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
