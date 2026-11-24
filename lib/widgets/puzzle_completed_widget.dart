import 'package:material_ui/material_ui.dart';

class PuzzleCompletedWidget extends StatelessWidget {
  const PuzzleCompletedWidget({super.key, required this.onPlayAgain});
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 72),
        SizedBox(height: 16),
        Text(
          'Puzzle Completed!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 24),
        FilledButton(onPressed: onPlayAgain, child: Text('Nuevo crucigrama')),
      ],
    ),
  );
}
