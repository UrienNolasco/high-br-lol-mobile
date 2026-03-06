import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_summary_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_summary.dart';

void main() {
  const tModel = PlayerSummaryModel(
    games: 270,
    winRate: 55.6,
    kda: 3.42,
    csPerMin: 7.8,
    dpm: 624,
  );

  const tJson = {
    'games': 270,
    'winRate': 55.6,
    'kda': 3.42,
    'csPerMin': 7.8,
    'dpm': 624,
  };

  test('should be a subclass of PlayerSummary', () {
    expect(tModel, isA<PlayerSummary>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerSummaryModel.fromJson(tJson);
    expect(result, equals(tModel));
  });

  test('should handle int values for double fields', () {
    final json = {
      'games': 270,
      'winRate': 55,
      'kda': 3,
      'csPerMin': 7,
      'dpm': 624,
    };
    final result = PlayerSummaryModel.fromJson(json);
    expect(result.winRate, 55.0);
    expect(result.kda, 3.0);
  });
}
