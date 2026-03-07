import '../../domain/entities/recent_search.dart';

class RecentSearchModel extends RecentSearch {
  const RecentSearchModel({
    required super.puuid,
    required super.gameName,
    required super.tagLine,
    super.tier,
    required super.searchedAt,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      puuid: json['puuid'] as String,
      gameName: json['gameName'] as String,
      tagLine: json['tagLine'] as String,
      tier: json['tier'] as String?,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puuid': puuid,
      'gameName': gameName,
      'tagLine': tagLine,
      'tier': tier,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }

  factory RecentSearchModel.fromEntity(RecentSearch entity) {
    return RecentSearchModel(
      puuid: entity.puuid,
      gameName: entity.gameName,
      tagLine: entity.tagLine,
      tier: entity.tier,
      searchedAt: entity.searchedAt,
    );
  }
}
