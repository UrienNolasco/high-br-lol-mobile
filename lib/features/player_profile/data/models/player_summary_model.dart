import '../../domain/entities/player_summary.dart';

class PlayerSummaryModel extends PlayerSummary {
  const PlayerSummaryModel({
    required super.games,
    required super.winRate,
    required super.kda,
    required super.csPerMin,
    required super.dpm,
  });

  factory PlayerSummaryModel.fromJson(Map<String, dynamic> json) {
    return PlayerSummaryModel(
      games: json['gamesPlayed'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      kda: (json['avgKda'] as num).toDouble(),
      csPerMin: (json['avgCspm'] as num).toDouble(),
      dpm: (json['avgDpm'] as num).toDouble(),
    );
  }
}
