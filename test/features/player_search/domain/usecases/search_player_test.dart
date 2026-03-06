import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/player_search_result.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/repositories/player_search_repository.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/search_player.dart';

class MockPlayerSearchRepository extends Mock
    implements PlayerSearchRepository {}

void main() {
  late SearchPlayer useCase;
  late MockPlayerSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerSearchRepository();
    useCase = SearchPlayer(mockRepository);
  });

  const tResult = PlayerSearchResult(
    puuid: 'test-puuid-123',
    gameName: 'BrTT',
    tagLine: 'BR1',
    profileIconId: 3789,
    summonerLevel: 492,
    matchesEnqueued: 5,
  );

  test('should return PlayerSearchResult from the repository', () async {
    when(() => mockRepository.searchPlayer(
          gameName: any(named: 'gameName'),
          tagLine: any(named: 'tagLine'),
        )).thenAnswer((_) async => tResult);

    final result = await useCase(gameName: 'BrTT', tagLine: 'BR1');

    expect(result, equals(tResult));
    verify(() => mockRepository.searchPlayer(
          gameName: 'BrTT',
          tagLine: 'BR1',
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
