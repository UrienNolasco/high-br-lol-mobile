import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/repositories/player_search_repository.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/get_player_status.dart';

class MockPlayerSearchRepository extends Mock
    implements PlayerSearchRepository {}

void main() {
  late GetPlayerStatus useCase;
  late MockPlayerSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerSearchRepository();
    useCase = GetPlayerStatus(mockRepository);
  });

  test('should return ProcessingStatus from the repository', () async {
    const tStatus = ProcessingStatus(
      status: UpdateStatus.updating,
      matchesProcessed: 10,
      matchesTotal: 20,
      message: 'Processing matches: 10/20',
    );
    when(() => mockRepository.getPlayerStatus(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tStatus);

    final result = await useCase(puuid: 'test-puuid');

    expect(result, tStatus);
    verify(() => mockRepository.getPlayerStatus(puuid: 'test-puuid')).called(1);
  });
}
