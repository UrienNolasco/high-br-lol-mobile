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
      games: json['games'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      kda: (json['kda'] as num).toDouble(),
      csPerMin: (json['csPerMin'] as num).toDouble(),
      dpm: json['dpm'] as int,
    );
  }
}
