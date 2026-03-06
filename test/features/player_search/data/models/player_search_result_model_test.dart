import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/player_search_result_model.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/player_search_result.dart';

void main() {
  const tModel = PlayerSearchResultModel(
    puuid: 'test-puuid-123',
    gameName: 'BrTT',
    tagLine: 'BR1',
    profileIconId: 3789,
    summonerLevel: 492,
    matchesEnqueued: 5,
  );

  const tJson = {
    'puuid': 'test-puuid-123',
    'gameName': 'BrTT',
    'tagLine': 'BR1',
    'profileIconId': 3789,
    'summonerLevel': 492,
    'matchesEnqueued': 5,
  };

  test('should be a subclass of PlayerSearchResult', () {
    expect(tModel, isA<PlayerSearchResult>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerSearchResultModel.fromJson(tJson);
    expect(result, equals(tModel));
  });
}
