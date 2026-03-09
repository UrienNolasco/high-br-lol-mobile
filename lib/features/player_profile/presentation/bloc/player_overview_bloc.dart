import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/get_player_overview.dart';
import 'player_overview_event.dart';
import 'player_overview_state.dart';

@injectable
class PlayerOverviewBloc
    extends Bloc<PlayerOverviewEvent, PlayerOverviewState> {
  PlayerOverviewBloc(this._getPlayerOverview)
      : super(const OverviewLoading()) {
    on<OverviewStarted>(_onStarted);
  }

  final GetPlayerOverview _getPlayerOverview;

  Future<void> _onStarted(
    OverviewStarted event,
    Emitter<PlayerOverviewState> emit,
  ) async {
    emit(const OverviewLoading());
    try {
      final data = await _getPlayerOverview(puuid: event.puuid);
      emit(OverviewLoaded(data));
    } on ApiException catch (e) {
      log('PlayerOverviewBloc: ApiException → ${e.message}');
      emit(OverviewError(e.message));
    } catch (e, stack) {
      log('PlayerOverviewBloc: unexpected error → $e', error: e, stackTrace: stack);
      emit(const OverviewError('Erro ao carregar dados.'));
    }
  }
}
