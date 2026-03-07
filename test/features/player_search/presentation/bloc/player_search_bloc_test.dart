import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/player_search_result.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/search_player.dart';
import 'package:high_br_lol_mobile/features/player_search/data/datasources/recent_searches_local_datasource.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/recent_search_model.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/player_search_bloc.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/player_search_event.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/player_search_state.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockSearchPlayer extends Mock implements SearchPlayer {}

class MockRecentSearchesLocalDataSource extends Mock
    implements RecentSearchesLocalDataSource {}

void main() {
  late PlayerSearchBloc bloc;
  late MockSearchPlayer mockSearchPlayer;
  late MockRecentSearchesLocalDataSource mockRecentSearches;

  setUpAll(() {
    registerFallbackValue(RecentSearchModel(
      puuid: 'fallback',
      gameName: 'fallback',
      tagLine: 'fallback',
      searchedAt: DateTime(2026),
    ));
  });

  setUp(() {
    mockSearchPlayer = MockSearchPlayer();
    mockRecentSearches = MockRecentSearchesLocalDataSource();
    when(() => mockRecentSearches.getRecentSearches()).thenReturn([]);
    when(() => mockRecentSearches.saveSearch(any())).thenAnswer((_) async {});
    bloc = PlayerSearchBloc(mockSearchPlayer, mockRecentSearches);
  });

  tearDown(() => bloc.close());

  const tResult = PlayerSearchResult(
    puuid: 'test-puuid-123',
    gameName: 'BrTT',
    tagLine: 'BR1',
    profileIconId: 3789,
    summonerLevel: 492,
    matchesEnqueued: 5,
  );

  test('initial state should be PlayerSearchInitial', () {
    expect(bloc.state, const PlayerSearchInitial());
  });

  blocTest<PlayerSearchBloc, PlayerSearchState>(
    'emits [Loading, Success] when search succeeds',
    build: () {
      when(() => mockSearchPlayer(
            gameName: any(named: 'gameName'),
            tagLine: any(named: 'tagLine'),
          )).thenAnswer((_) async => tResult);
      return bloc;
    },
    act: (bloc) => bloc.add(
      const PlayerSearchSubmitted(gameName: 'BrTT', tagLine: 'BR1'),
    ),
    expect: () => [
      const PlayerSearchLoading(recentSearches: []),
      const PlayerSearchSuccess(tResult, recentSearches: []),
    ],
  );

  blocTest<PlayerSearchBloc, PlayerSearchState>(
    'emits [Loading, Failure] when search throws NotFoundException',
    build: () {
      when(() => mockSearchPlayer(
            gameName: any(named: 'gameName'),
            tagLine: any(named: 'tagLine'),
          )).thenThrow(const NotFoundException('Jogador nao encontrado.'));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const PlayerSearchSubmitted(gameName: 'Unknown', tagLine: 'BR1'),
    ),
    expect: () => [
      const PlayerSearchLoading(recentSearches: []),
      const PlayerSearchFailure('Jogador nao encontrado.', recentSearches: []),
    ],
  );

  blocTest<PlayerSearchBloc, PlayerSearchState>(
    'emits [Loading, Failure] when search throws unexpected error',
    build: () {
      when(() => mockSearchPlayer(
            gameName: any(named: 'gameName'),
            tagLine: any(named: 'tagLine'),
          )).thenThrow(Exception('unexpected'));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const PlayerSearchSubmitted(gameName: 'Test', tagLine: 'BR1'),
    ),
    expect: () => [
      const PlayerSearchLoading(recentSearches: []),
      const PlayerSearchFailure(
        'Erro inesperado. Tente novamente.',
        recentSearches: [],
      ),
    ],
  );
}
