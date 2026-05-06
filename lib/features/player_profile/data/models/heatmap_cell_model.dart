import '../../domain/entities/heatmap_cell.dart';

class HeatmapCellModel extends HeatmapCell {
  const HeatmapCellModel({
    required super.dayOfWeek,
    required super.hour,
    required super.games,
    required super.wins,
    required super.losses,
    required super.winRate,
  });

  factory HeatmapCellModel.fromJson(Map<String, dynamic> json) {
    return HeatmapCellModel(
      dayOfWeek: json['dayOfWeek'] as int,
      hour: json['hour'] as int,
      games: json['games'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
      winRate: (json['winRate'] as num).toDouble(),
    );
  }
}
