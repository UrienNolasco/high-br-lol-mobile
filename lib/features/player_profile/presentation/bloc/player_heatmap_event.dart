import 'package:equatable/equatable.dart';

sealed class PlayerHeatmapEvent extends Equatable {
  const PlayerHeatmapEvent();

  @override
  List<Object?> get props => [];
}

class HeatmapStarted extends PlayerHeatmapEvent {
  const HeatmapStarted({required this.puuid});

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}

class MetricToggled extends PlayerHeatmapEvent {
  const MetricToggled(this.metric);

  final HeatmapMetric metric;

  @override
  List<Object?> get props => [metric];
}

class CellTapped extends PlayerHeatmapEvent {
  const CellTapped({required this.dayOfWeek, required this.hour});

  final int dayOfWeek;
  final int hour;

  @override
  List<Object?> get props => [dayOfWeek, hour];
}

enum HeatmapMetric {
  games,
  wins,
  losses,
  winRate,
}
