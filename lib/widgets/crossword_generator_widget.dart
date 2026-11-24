import 'package:material_ui/material_ui.dart';

import 'crossword_widget.dart';

class CrosswordGeneratorWidget extends StatefulWidget {
  const CrosswordGeneratorWidget({super.key});
  @override
  State<CrosswordGeneratorWidget> createState() =>
      _CrosswordGeneratorWidgetState();
}

class _CrosswordGeneratorWidgetState extends State<CrosswordGeneratorWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.35, end: 1).animate(controller),
    child: CrosswordWidget(hideLetters: true),
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
