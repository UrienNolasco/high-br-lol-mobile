import 'package:equatable/equatable.dart';

class PlayerSearchResult extends Equatable {
  const PlayerSearchResult({
    required this.puuid,
    required this.gameName,
    required this.tagLine,
    required this.profileIconId,
    required this.summonerLevel,
    required this.matchesEnqueued,
  });

  final String puuid;
  final String gameName;
  final String tagLine;
  final int profileIconId;
  final int summonerLevel;
  final int matchesEnqueued;

  @override
  List<Object?> get props =>
      [puuid, gameName, tagLine, profileIconId, summonerLevel, matchesEnqueued];
}
