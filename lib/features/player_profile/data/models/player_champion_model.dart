import '../../domain/entities/player_champion.dart';

class PlayerChampionModel extends PlayerChampion {
  const PlayerChampionModel({
    required super.name,
    required super.games,
    required super.winRate,
    required super.iconId,
    required super.imageUrl,
    required super.wins,
    required super.losses,
    required super.avgKda,
    required super.avgCspm,
    required super.avgDpm,
    required super.avgGpm,
    required super.avgVisionScore,
    required super.avgCsd15,
    required super.avgGd15,
    required super.avgXpd15,
    required super.roleDistribution,
  });

  factory PlayerChampionModel.fromJson(Map<String, dynamic> json) {
    final roleMap = (json['roleDistribution'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
        {};
    return PlayerChampionModel(
      name: json['championName'] as String,
      games: json['gamesPlayed'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      iconId: json['championId'] as int,
      imageUrl: json['imageUrl'] as String? ?? '',
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      avgKda: (json['avgKda'] as num).toDouble(),
      avgCspm: (json['avgCspm'] as num).toDouble(),
      avgDpm: (json['avgDpm'] as num).toDouble(),
      avgGpm: (json['avgGpm'] as num).toDouble(),
      avgVisionScore: (json['avgVisionScore'] as num).toDouble(),
      avgCsd15: (json['avgCsd15'] as num).toDouble(),
      avgGd15: (json['avgGd15'] as num).toDouble(),
      avgXpd15: (json['avgXpd15'] as num).toDouble(),
      roleDistribution: roleMap,
    );
  }
}
