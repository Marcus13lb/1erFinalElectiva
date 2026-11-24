import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../providers.dart' as providers;
import '../utils.dart';
import 'ticker_builder.dart';

class CrosswordInfoWidget extends ConsumerWidget {
  const CrosswordInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(providers.displayInfoProvider);
    final workers = ref.watch(providers.workerCountProvider);
    final remaining = ref.watch(providers.expectedRemainingTimeProvider);
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Estadísticas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              _InfoRow(
                label: 'Palabras colocadas',
                value: info.wordsInGridCount,
              ),
              _InfoRow(
                label: 'Palabras candidatas',
                value: info.candidateWordsCount,
              ),
              _InfoRow(
                label: 'Cruces pendientes',
                value: info.locationsToExploreCount,
              ),
              _InfoRow(
                label: 'Posiciones descartadas',
                value: info.knownBadLocationsCount,
              ),
              _InfoRow(
                label: 'Cuadrícula ocupada',
                value: info.gridFilledPercentage,
              ),
              _InfoRow(
                label: 'Trabajadores máx.',
                value: workers.count.toString(),
              ),
              _GenerationTime(),
              _InfoRow(label: 'Restante aprox.', value: remaining.formatted),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenerationTime extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = ref.watch(providers.startTimeProvider);
    final end = ref.watch(providers.endTimeProvider);
    return switch ((start, end)) {
      (null, _) => _InfoRow(label: 'Tiempo', value: 'Sin iniciar'),
      (DateTime start, null) => TickerBuilder(
        builder: (context) => _InfoRow(
          label: 'Transcurrido',
          value: DateTime.now().difference(start).formatted,
        ),
      ),
      (DateTime start, DateTime end) => _InfoRow(
        label: 'Finalizado en',
        value: end.difference(start).formatted,
      ),
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
