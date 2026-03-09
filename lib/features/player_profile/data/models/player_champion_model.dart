import '../../domain/entities/player_champion.dart';

class PlayerChampionModel extends PlayerChampion {
  const PlayerChampionModel({
    required super.name,
    required super.games,
    required super.winRate,
    required super.iconId,
    required super.imageUrl,
  });

  factory PlayerChampionModel.fromJson(Map<String, dynamic> json) {
    return PlayerChampionModel(
      name: json['championName'] as String,
      games: json['gamesPlayed'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      iconId: json['championId'] as int,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}
