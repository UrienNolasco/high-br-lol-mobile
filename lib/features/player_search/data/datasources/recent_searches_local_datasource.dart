import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_search_model.dart';

@lazySingleton
class RecentSearchesLocalDataSource {
  RecentSearchesLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'recent_searches';
  static const _maxItems = 10;

  List<RecentSearchModel> getRecentSearches() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => RecentSearchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSearch(RecentSearchModel search) async {
    final searches = getRecentSearches();
    searches.removeWhere((s) => s.puuid == search.puuid);
    searches.insert(0, search);
    if (searches.length > _maxItems) {
      searches.removeRange(_maxItems, searches.length);
    }
    final jsonString = jsonEncode(searches.map((s) => s.toJson()).toList());
    await _prefs.setString(_key, jsonString);
  }
}
