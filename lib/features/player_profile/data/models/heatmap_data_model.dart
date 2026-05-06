import '../../domain/entities/heatmap_data.dart';
import 'heatmap_cell_model.dart';
import 'heatmap_insights_model.dart';

class HeatmapDataModel extends HeatmapData {
  const HeatmapDataModel({
    required super.puuid,
    required super.patch,
    required super.cells,
    required super.insights,
  });

  factory HeatmapDataModel.fromJson(Map<String, dynamic> json) {
    final heatmapList = json['heatmap'] as List<dynamic>;
    final cells = heatmapList
        .map((e) => HeatmapCellModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return HeatmapDataModel(
      puuid: json['puuid'] as String,
      patch: json['patch'] as String,
      cells: cells,
      insights: HeatmapInsightsModel.fromJson(
        json['insights'] as Map<String, dynamic>,
      ),
    );
  }
}
