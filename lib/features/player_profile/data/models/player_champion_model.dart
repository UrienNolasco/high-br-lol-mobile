import '../../domain/entities/player_champion.dart';

class PlayerChampionModel extends PlayerChampion {
  const PlayerChampionModel({
    required super.name,
    required super.games,
    required super.winRate,
    required super.iconId,
  });

  factory PlayerChampionModel.fromJson(Map<String, dynamic> json) {
    return PlayerChampionModel(
      name: json['name'] as String,
      games: json['games'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      iconId: json['iconId'] as int,
    );
  }
}
