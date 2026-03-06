import '../../domain/entities/player_search_result.dart';

class PlayerSearchResultModel extends PlayerSearchResult {
  const PlayerSearchResultModel({
    required super.puuid,
    required super.gameName,
    required super.tagLine,
    required super.profileIconId,
    required super.summonerLevel,
    required super.matchesEnqueued,
  });

  factory PlayerSearchResultModel.fromJson(Map<String, dynamic> json) {
    return PlayerSearchResultModel(
      puuid: json['puuid'] as String,
      gameName: json['gameName'] as String,
      tagLine: json['tagLine'] as String,
      profileIconId: json['profileIconId'] as int,
      summonerLevel: json['summonerLevel'] as int,
      matchesEnqueued: json['matchesEnqueued'] as int,
    );
  }
}
