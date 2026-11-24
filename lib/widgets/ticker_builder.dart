import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

class TickerBuilder extends StatefulWidget {
  const TickerBuilder({super.key, required this.builder});
  final WidgetBuilder builder;

  @override
  State<TickerBuilder> createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<TickerBuilder>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker((elapsed) => setState(() {}))..start();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }
}
