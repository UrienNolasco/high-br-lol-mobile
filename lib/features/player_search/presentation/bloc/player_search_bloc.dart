import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/search_player.dart';
import 'player_search_event.dart';
import 'player_search_state.dart';

@injectable
class PlayerSearchBloc extends Bloc<PlayerSearchEvent, PlayerSearchState> {
  PlayerSearchBloc(this._searchPlayer) : super(const PlayerSearchInitial()) {
    on<PlayerSearchSubmitted>(_onSearchSubmitted);
  }

  final SearchPlayer _searchPlayer;

  Future<void> _onSearchSubmitted(
    PlayerSearchSubmitted event,
    Emitter<PlayerSearchState> emit,
  ) async {
    emit(const PlayerSearchLoading());
    try {
      final result = await _searchPlayer(
        gameName: event.gameName,
        tagLine: event.tagLine,
      );
      emit(PlayerSearchSuccess(result));
    } on ApiException catch (e) {
      emit(PlayerSearchFailure(e.message));
    } catch (_) {
      emit(const PlayerSearchFailure('Erro inesperado. Tente novamente.'));
    }
  }
}
