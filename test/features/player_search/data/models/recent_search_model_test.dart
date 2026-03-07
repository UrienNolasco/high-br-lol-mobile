import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/recent_search_model.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/recent_search.dart';

void main() {
  final tNow = DateTime(2026, 3, 6, 12, 0);

  final tModel = RecentSearchModel(
    puuid: 'test-puuid',
    gameName: 'UrienMano',
    tagLine: 'BR1',
    tier: 'CHALLENGER',
    searchedAt: tNow,
  );

  final tJson = {
    'puuid': 'test-puuid',
    'gameName': 'UrienMano',
    'tagLine': 'BR1',
    'tier': 'CHALLENGER',
    'searchedAt': '2026-03-06T12:00:00.000',
  };

  test('should be a subclass of RecentSearch', () {
    expect(tModel, isA<RecentSearch>());
  });

  test('should return a valid model from JSON', () {
    final result = RecentSearchModel.fromJson(tJson);
    expect(result.puuid, 'test-puuid');
    expect(result.gameName, 'UrienMano');
    expect(result.tagLine, 'BR1');
    expect(result.tier, 'CHALLENGER');
    expect(result.searchedAt, tNow);
  });

  test('should produce valid JSON from toJson', () {
    final result = tModel.toJson();
    expect(result['puuid'], 'test-puuid');
    expect(result['gameName'], 'UrienMano');
    expect(result['tier'], 'CHALLENGER');
    expect(result['searchedAt'], '2026-03-06T12:00:00.000');
  });

  test('should handle null tier in JSON', () {
    final jsonWithoutTier = {
      'puuid': 'test-puuid',
      'gameName': 'UrienMano',
      'tagLine': 'BR1',
      'tier': null,
      'searchedAt': '2026-03-06T12:00:00.000',
    };
    final result = RecentSearchModel.fromJson(jsonWithoutTier);
    expect(result.tier, isNull);
  });

  test('should create model from entity', () {
    final entity = RecentSearch(
      puuid: 'test-puuid',
      gameName: 'UrienMano',
      tagLine: 'BR1',
      tier: 'CHALLENGER',
      searchedAt: tNow,
    );
    final result = RecentSearchModel.fromEntity(entity);
    expect(result.puuid, entity.puuid);
    expect(result.tier, entity.tier);
  });
}
