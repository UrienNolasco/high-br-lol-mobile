import 'package:equatable/equatable.dart';
import 'heatmap_cell.dart';
import 'heatmap_insights.dart';

class HeatmapData extends Equatable {
  const HeatmapData({
    required this.puuid,
    required this.patch,
    required this.cells,
    required this.insights,
  });

  final String puuid;
  final String patch;
  final List<HeatmapCell> cells;
  final HeatmapInsights insights;

  @override
  List<Object?> get props => [puuid, patch, cells, insights];
}
