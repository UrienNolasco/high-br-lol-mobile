import 'package:equatable/equatable.dart';

class HeatmapInsights extends Equatable {
  const HeatmapInsights({
    required this.mostActiveDay,
    required this.mostActiveDayGames,
    required this.mostActiveHour,
    required this.mostActiveHourGames,
    required this.peakWinRate,
    required this.peakWinRateTime,
    required this.worstWinRate,
    required this.worstWinRateTime,
  });

  final String mostActiveDay;
  final int mostActiveDayGames;
  final int mostActiveHour;
  final int mostActiveHourGames;
  final double peakWinRate;
  final String peakWinRateTime;
  final double worstWinRate;
  final String worstWinRateTime;

  @override
  List<Object?> get props => [
        mostActiveDay,
        mostActiveDayGames,
        mostActiveHour,
        mostActiveHourGames,
        peakWinRate,
        peakWinRateTime,
        worstWinRate,
        worstWinRateTime,
      ];
}
