import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/heatmap_data_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_data.dart';

void main() {
  const tJson = {
    'puuid': 'abc123',
    'patch': 'lifetime',
    'heatmap': [
      {
        'dayOfWeek': 0,
        'hour': 14,
        'games': 5,
        'wins': 3,
        'losses': 2,
        'winRate': 60.0,
      },
    ],
    'insights': {
      'mostActiveDay': 'Saturday',
      'mostActiveDayGames': 35,
      'mostActiveHour': 23,
      'mostActiveHourGames': 15,
      'peakWinRate': 75.0,
      'peakWinRateTime': 'Sunday 14h',
      'worstWinRate': 30.0,
      'worstWinRateTime': 'Saturday 3h',
    },
  };

  test('should be a subclass of HeatmapData', () {
    final result = HeatmapDataModel.fromJson(tJson);
    expect(result, isA<HeatmapData>());
  });

  test('should parse puuid and patch from JSON', () {
    final result = HeatmapDataModel.fromJson(tJson);
    expect(result.puuid, 'abc123');
    expect(result.patch, 'lifetime');
  });

  test('should parse heatmap list with correct length', () {
    final result = HeatmapDataModel.fromJson(tJson);
    expect(result.cells.length, 1);
    expect(result.cells.first.dayOfWeek, 0);
    expect(result.cells.first.hour, 14);
    expect(result.cells.first.games, 5);
  });

  test('should parse insights object', () {
    final result = HeatmapDataModel.fromJson(tJson);
    expect(result.insights.mostActiveDay, 'Saturday');
    expect(result.insights.mostActiveHour, 23);
    expect(result.insights.peakWinRate, 75.0);
  });
}
