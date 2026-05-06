import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/heatmap_cell_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_cell.dart';

void main() {
  const tModel = HeatmapCellModel(
    dayOfWeek: 0,
    hour: 14,
    games: 5,
    wins: 3,
    losses: 2,
    winRate: 60.0,
  );

  const tJson = {
    'dayOfWeek': 0,
    'hour': 14,
    'games': 5,
    'wins': 3,
    'losses': 2,
    'winRate': 60.0,
  };

  test('should be a subclass of HeatmapCell', () {
    expect(tModel, isA<HeatmapCell>());
  });

  test('should return a valid model from JSON', () {
    final result = HeatmapCellModel.fromJson(tJson);
    expect(result, equals(tModel));
  });

  test('should handle int winRate as double', () {
    final json = {
      'dayOfWeek': 0,
      'hour': 14,
      'games': 5,
      'wins': 3,
      'losses': 2,
      'winRate': 60,
    };
    final result = HeatmapCellModel.fromJson(json);
    expect(result.winRate, 60.0);
  });
}
