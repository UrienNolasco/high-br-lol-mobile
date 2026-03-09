import 'package:equatable/equatable.dart';

class PlayerChampion extends Equatable {
  const PlayerChampion({
    required this.name,
    required this.games,
    required this.winRate,
    required this.iconId,
    required this.imageUrl,
    required this.wins,
    required this.losses,
    required this.avgKda,
    required this.avgCspm,
    required this.avgDpm,
    required this.avgGpm,
    required this.avgVisionScore,
    required this.avgCsd15,
    required this.avgGd15,
    required this.avgXpd15,
    required this.roleDistribution,
  });

  final String name;
  final int games;
  final double winRate;
  final int iconId;
  final String imageUrl;
  final int wins;
  final int losses;
  final double avgKda;
  final double avgCspm;
  final double avgDpm;
  final double avgGpm;
  final double avgVisionScore;
  final double avgCsd15;
  final double avgGd15;
  final double avgXpd15;
  final Map<String, int> roleDistribution;

  String get primaryRole {
    if (roleDistribution.isEmpty) return '';
    return roleDistribution.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        name, games, winRate, iconId, imageUrl,
        wins, losses, avgKda, avgCspm, avgDpm,
        avgGpm, avgVisionScore, avgCsd15, avgGd15,
        avgXpd15, roleDistribution,
      ];
}
