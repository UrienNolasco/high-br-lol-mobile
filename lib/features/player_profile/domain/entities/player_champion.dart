import 'package:equatable/equatable.dart';

class PlayerChampion extends Equatable {
  const PlayerChampion({
    required this.name,
    required this.games,
    required this.winRate,
    required this.iconId,
    required this.imageUrl,
  });

  final String name;
  final int games;
  final double winRate;
  final int iconId;
  final String imageUrl;

  @override
  List<Object?> get props => [name, games, winRate, iconId, imageUrl];
}
