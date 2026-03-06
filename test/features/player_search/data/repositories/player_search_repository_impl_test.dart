import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/data/datasources/player_search_remote_datasource.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/player_search_result_model.dart';
import 'package:high_br_lol_mobile/features/player_search/data/repositories/player_search_repository_impl.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/processing_status_model.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';

class MockRemoteDataSource extends Mock
    implements PlayerSearchRemoteDataSource {}

void main() {
  late PlayerSearchRepositoryImpl repository;
  late MockRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockRemoteDataSource();
    repository = PlayerSearchRepositoryImpl(mockDataSource);
  });

  const tModel = PlayerSearchResultModel(
    puuid: 'test-puuid-123',
    gameName: 'BrTT',
    tagLine: 'BR1',
    profileIconId: 3789,
    summonerLevel: 492,
    matchesEnqueued: 5,
  );

  test('should return PlayerSearchResult when datasource succeeds', () async {
    when(() => mockDataSource.searchPlayer(
          gameName: any(named: 'gameName'),
          tagLine: any(named: 'tagLine'),
        )).thenAnswer((_) async => tModel);

    final result = await repository.searchPlayer(
      gameName: 'BrTT',
      tagLine: 'BR1',
    );

    expect(result, equals(tModel));
  });

  test('should rethrow ApiException when datasource fails', () async {
    when(() => mockDataSource.searchPlayer(
          gameName: any(named: 'gameName'),
          tagLine: any(named: 'tagLine'),
        )).thenThrow(const NotFoundException());

    expect(
      () => repository.searchPlayer(gameName: 'BrTT', tagLine: 'BR1'),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('should return ProcessingStatus when getPlayerStatus succeeds', () async {
    const tStatus = ProcessingStatusModel(
      status: UpdateStatus.updating,
      matchesProcessed: 5,
      matchesTotal: 20,
      message: 'Processing matches: 5/20',
    );
    when(() => mockDataSource.getPlayerStatus(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tStatus);

    final result = await repository.getPlayerStatus(puuid: 'test-puuid');

    expect(result, tStatus);
    verify(() => mockDataSource.getPlayerStatus(puuid: 'test-puuid')).called(1);
  });
}
