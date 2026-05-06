import 'package:equatable/equatable.dart';
import '../../domain/entities/heatmap_data.dart';
import 'player_heatmap_event.dart';

sealed class PlayerHeatmapState extends Equatable {
  const PlayerHeatmapState();

  @override
  List<Object?> get props => [];
}

class HeatmapInitial extends PlayerHeatmapState {
  const HeatmapInitial();
}

class HeatmapLoading extends PlayerHeatmapState {
  const HeatmapLoading();
}

class HeatmapLoaded extends PlayerHeatmapState {
  const HeatmapLoaded({
    required this.data,
    this.selectedMetric = HeatmapMetric.games,
    this.selectedDayOfWeek,
    this.selectedHour,
  });

  final HeatmapData data;
  final HeatmapMetric selectedMetric;
  final int? selectedDayOfWeek;
  final int? selectedHour;

  @override
  List<Object?> get props => [
        data,
        selectedMetric,
        selectedDayOfWeek,
        selectedHour,
      ];

  HeatmapLoaded copyWith({
    HeatmapData? data,
    HeatmapMetric? selectedMetric,
    int? selectedDayOfWeek,
    int? selectedHour,
    bool clearSelection = false,
  }) {
    return HeatmapLoaded(
      data: data ?? this.data,
      selectedMetric: selectedMetric ?? this.selectedMetric,
      selectedDayOfWeek:
          clearSelection ? null : (selectedDayOfWeek ?? this.selectedDayOfWeek),
      selectedHour:
          clearSelection ? null : (selectedHour ?? this.selectedHour),
    );
  }
}

class HeatmapError extends PlayerHeatmapState {
  const HeatmapError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
