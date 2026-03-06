import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_profile.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/repositories/player_profile_repository.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_profile.dart';

class MockPlayerProfileRepository extends Mock
    implements PlayerProfileRepository {}

void main() {
  late GetPlayerProfile useCase;
  late MockPlayerProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerProfileRepository();
    useCase = GetPlayerProfile(mockRepository);
  });

  const tProfile = PlayerProfile(
    puuid: 'test-puuid-123',
    gameName: 'UrienMano',
    tagLine: 'BR1',
    profileIconId: 1234,
    tier: 'CHALLENGER',
    rank: 'I',
    leaguePoints: 1234,
    wins: 150,
    losses: 120,
  );

  test('should return PlayerProfile from the repository', () async {
    when(() => mockRepository.getPlayerProfile(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tProfile);

    final result = await useCase(puuid: 'test-puuid-123');

    expect(result, tProfile);
    verify(() => mockRepository.getPlayerProfile(puuid: 'test-puuid-123'))
        .called(1);
  });
}
