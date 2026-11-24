import 'package:flutter_test/flutter_test.dart';
import 'package:generate_crossword/model.dart' as model;

// Modelo conservado como referencia del apartado 8; el juego ya no muestra ese panel.
void main() {
  test('calcula los conteos y el porcentaje ocupado', () {
    final queue = model.WorkQueue.from(
      crossword: model.Crossword.crossword(width: 8, height: 5).addWord(
        location: model.Location.at(0, 0),
        word: 'cat',
        direction: model.Direction.across,
      )!,
      candidateWords: ['cat', 'cow'],
      startLocation: model.Location.at(0, 0),
    );
    final info = model.DisplayInfo.from(workQueue: queue);
    expect(info.wordsInGridCount, '1');
    expect(info.candidateWordsCount, '1');
    expect(info.locationsToExploreCount, '3');
    expect(info.gridFilledPercentage, '7.5%');
  });
}
