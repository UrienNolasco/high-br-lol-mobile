import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/datasources/recent_searches_local_datasource.dart';
import '../../data/models/recent_search_model.dart';
import '../../domain/usecases/search_player.dart';
import 'player_search_event.dart';
import 'player_search_state.dart';

@injectable
class PlayerSearchBloc extends Bloc<PlayerSearchEvent, PlayerSearchState> {
  PlayerSearchBloc(this._searchPlayer, this._recentSearches)
      : super(const PlayerSearchInitial()) {
    on<PlayerSearchSubmitted>(_onSearchSubmitted);
    on<RecentSearchesLoaded>(_onRecentSearchesLoaded);
    on<RecentSearchAdded>(_onRecentSearchAdded);
  }

  final SearchPlayer _searchPlayer;
  final RecentSearchesLocalDataSource _recentSearches;

  void _onRecentSearchesLoaded(
    RecentSearchesLoaded event,
    Emitter<PlayerSearchState> emit,
  ) {
    final searches = _recentSearches.getRecentSearches();
    emit(PlayerSearchInitial(recentSearches: searches));
  }

  Future<void> _onSearchSubmitted(
    PlayerSearchSubmitted event,
    Emitter<PlayerSearchState> emit,
  ) async {
    emit(PlayerSearchLoading(recentSearches: state.recentSearches));
    try {
      final result = await _searchPlayer(
        gameName: event.gameName,
        tagLine: event.tagLine,
      );

      final search = RecentSearchModel(
        puuid: result.puuid,
        gameName: result.gameName,
        tagLine: result.tagLine,
        searchedAt: DateTime.now(),
      );
      await _recentSearches.saveSearch(search);

      final updated = _recentSearches.getRecentSearches();
      emit(PlayerSearchSuccess(result, recentSearches: updated));
    } on ApiException catch (e) {
      emit(PlayerSearchFailure(e.message, recentSearches: state.recentSearches));
    } catch (_) {
      emit(PlayerSearchFailure(
        'Erro inesperado. Tente novamente.',
        recentSearches: state.recentSearches,
      ));
    }
  }

  Future<void> _onRecentSearchAdded(
    RecentSearchAdded event,
    Emitter<PlayerSearchState> emit,
  ) async {
    final model = RecentSearchModel.fromEntity(event.search);
    await _recentSearches.saveSearch(model);
    final updated = _recentSearches.getRecentSearches();
    emit(PlayerSearchInitial(recentSearches: updated));
  }
}
