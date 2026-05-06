import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/heatmap_insights_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_insights.dart';

void main() {
  const tModel = HeatmapInsightsModel(
    mostActiveDay: 'Saturday',
    mostActiveDayGames: 35,
    mostActiveHour: 23,
    mostActiveHourGames: 15,
    peakWinRate: 75.0,
    peakWinRateTime: 'Sunday 14h',
    worstWinRate: 30.0,
    worstWinRateTime: 'Saturday 3h',
  );

  const tJson = {
    'mostActiveDay': 'Saturday',
    'mostActiveDayGames': 35,
    'mostActiveHour': 23,
    'mostActiveHourGames': 15,
    'peakWinRate': 75.0,
    'peakWinRateTime': 'Sunday 14h',
    'worstWinRate': 30.0,
    'worstWinRateTime': 'Saturday 3h',
  };

  test('should be a subclass of HeatmapInsights', () {
    expect(tModel, isA<HeatmapInsights>());
  });

  test('should return a valid model from JSON', () {
    final result = HeatmapInsightsModel.fromJson(tJson);
    expect(result, equals(tModel));
  });
}
