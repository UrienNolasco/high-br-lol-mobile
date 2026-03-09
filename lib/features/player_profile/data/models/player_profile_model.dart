import '../../domain/entities/player_profile.dart';

class PlayerProfileModel extends PlayerProfile {
  const PlayerProfileModel({
    required super.puuid,
    required super.gameName,
    required super.tagLine,
    required super.profileIconId,
    required super.tier,
    required super.rank,
    required super.leaguePoints,
    required super.wins,
    required super.losses,
  });

  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    return PlayerProfileModel(
      puuid: json['puuid'] as String,
      gameName: json['gameName'] as String,
      tagLine: json['tagLine'] as String,
      profileIconId: json['profileIconId'] as int,
      tier: json['tier'] as String,
      rank: json['rank'] as String,
      leaguePoints: json['leaguePoints'] as int,
      wins: json['rankedWins'] as int,
      losses: json['rankedLosses'] as int,
    );
  }
}
