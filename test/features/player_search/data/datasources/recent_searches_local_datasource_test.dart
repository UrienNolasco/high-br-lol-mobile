import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:high_br_lol_mobile/features/player_search/data/datasources/recent_searches_local_datasource.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/recent_search_model.dart';

void main() {
  late RecentSearchesLocalDataSource datasource;
  final tNow = DateTime(2026, 3, 6, 12, 0);

  final tSearch = RecentSearchModel(
    puuid: 'puuid-1',
    gameName: 'UrienMano',
    tagLine: 'BR1',
    tier: 'CHALLENGER',
    searchedAt: tNow,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    datasource = RecentSearchesLocalDataSource(prefs);
  });

  test('should return empty list when no data saved', () {
    final result = datasource.getRecentSearches();
    expect(result, isEmpty);
  });

  test('should save and retrieve a search', () async {
    await datasource.saveSearch(tSearch);
    final result = datasource.getRecentSearches();
    expect(result.length, 1);
    expect(result.first.puuid, 'puuid-1');
    expect(result.first.gameName, 'UrienMano');
  });

  test('should move duplicate puuid to top', () async {
    final search2 = RecentSearchModel(
      puuid: 'puuid-2',
      gameName: 'Faker',
      tagLine: 'KR1',
      searchedAt: tNow,
    );
    await datasource.saveSearch(tSearch);
    await datasource.saveSearch(search2);

    final updated = RecentSearchModel(
      puuid: 'puuid-1',
      gameName: 'UrienMano',
      tagLine: 'BR1',
      tier: 'CHALLENGER',
      searchedAt: DateTime(2026, 3, 6, 13, 0),
    );
    await datasource.saveSearch(updated);

    final result = datasource.getRecentSearches();
    expect(result.length, 2);
    expect(result.first.puuid, 'puuid-1');
    expect(result[1].puuid, 'puuid-2');
  });

  test('should limit to 10 items', () async {
    for (var i = 0; i < 12; i++) {
      await datasource.saveSearch(RecentSearchModel(
        puuid: 'puuid-$i',
        gameName: 'Player$i',
        tagLine: 'BR1',
        searchedAt: tNow.add(Duration(minutes: i)),
      ));
    }
    final result = datasource.getRecentSearches();
    expect(result.length, 10);
    expect(result.first.puuid, 'puuid-11');
  });
}
