import '../../domain/entities/heatmap_insights.dart';

class HeatmapInsightsModel extends HeatmapInsights {
  const HeatmapInsightsModel({
    required super.mostActiveDay,
    required super.mostActiveDayGames,
    required super.mostActiveHour,
    required super.mostActiveHourGames,
    required super.peakWinRate,
    required super.peakWinRateTime,
    required super.worstWinRate,
    required super.worstWinRateTime,
  });

  factory HeatmapInsightsModel.fromJson(Map<String, dynamic> json) {
    return HeatmapInsightsModel(
      mostActiveDay: json['mostActiveDay'] as String,
      mostActiveDayGames: json['mostActiveDayGames'] as int,
      mostActiveHour: json['mostActiveHour'] as int,
      mostActiveHourGames: json['mostActiveHourGames'] as int,
      peakWinRate: (json['peakWinRate'] as num).toDouble(),
      peakWinRateTime: json['peakWinRateTime'] as String,
      worstWinRate: (json['worstWinRate'] as num).toDouble(),
      worstWinRateTime: json['worstWinRateTime'] as String,
    );
  }
}
