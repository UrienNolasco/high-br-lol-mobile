import 'package:equatable/equatable.dart';

class PlayerProfile extends Equatable {
  const PlayerProfile({
    required this.puuid,
    required this.gameName,
    required this.tagLine,
    required this.profileIconId,
    required this.tier,
    required this.rank,
    required this.leaguePoints,
    required this.wins,
    required this.losses,
  });

  final String puuid;
  final String gameName;
  final String tagLine;
  final int profileIconId;
  final String tier;
  final String rank;
  final int leaguePoints;
  final int wins;
  final int losses;

  double get winRate => (wins + losses) > 0 ? wins / (wins + losses) * 100 : 0;

  @override
  List<Object?> get props =>
      [puuid, gameName, tagLine, profileIconId, tier, rank, leaguePoints, wins, losses];
}
