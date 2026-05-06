import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/get_player_heatmap.dart';
import 'player_heatmap_event.dart';
import 'player_heatmap_state.dart';

@injectable
class PlayerHeatmapBloc
    extends Bloc<PlayerHeatmapEvent, PlayerHeatmapState> {
  PlayerHeatmapBloc(this._getPlayerHeatmap) : super(const HeatmapInitial()) {
    on<HeatmapStarted>(_onStarted);
    on<MetricToggled>(_onMetricToggled);
    on<CellTapped>(_onCellTapped);
  }

  final GetPlayerHeatmap _getPlayerHeatmap;

  Future<void> _onStarted(
    HeatmapStarted event,
    Emitter<PlayerHeatmapState> emit,
  ) async {
    emit(const HeatmapLoading());
    try {
      final data = await _getPlayerHeatmap(puuid: event.puuid);
      emit(HeatmapLoaded(data: data));
    } on ApiException catch (e) {
      log('PlayerHeatmapBloc: ApiException → ${e.message}');
      emit(HeatmapError(e.message));
    } catch (e, stack) {
      log('PlayerHeatmapBloc: unexpected error → $e',
          error: e, stackTrace: stack);
      emit(const HeatmapError('Erro ao carregar dados de atividade.'));
    }
  }

  void _onMetricToggled(
    MetricToggled event,
    Emitter<PlayerHeatmapState> emit,
  ) {
    final current = state;
    if (current is HeatmapLoaded) {
      emit(current.copyWith(
        selectedMetric: event.metric,
        clearSelection: true,
      ));
    }
  }

  void _onCellTapped(
    CellTapped event,
    Emitter<PlayerHeatmapState> emit,
  ) {
    final current = state;
    if (current is HeatmapLoaded) {
      final isSameCell = current.selectedDayOfWeek == event.dayOfWeek &&
          current.selectedHour == event.hour;
      if (isSameCell) {
        emit(current.copyWith(clearSelection: true));
      } else {
        emit(current.copyWith(
          selectedDayOfWeek: event.dayOfWeek,
          selectedHour: event.hour,
        ));
      }
    }
  }
}
