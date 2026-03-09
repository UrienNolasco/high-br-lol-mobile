import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_summary.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_champion.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_role.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_activity.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/repositories/player_profile_repository.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_overview.dart';

class MockPlayerProfileRepository extends Mock
    implements PlayerProfileRepository {}

void main() {
  late GetPlayerOverview useCase;
  late MockPlayerProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerProfileRepository();
    useCase = GetPlayerOverview(mockRepository);
  });

  const tPuuid = 'test-puuid-123';

  const tSummary = PlayerSummary(
    games: 270, winRate: 55.6, kda: 3.42, csPerMin: 7.8, dpm: 624,
  );
  const tChampions = [
    PlayerChampion(
      name: 'Ahri', games: 68, winRate: 61.8, iconId: 103,
      imageUrl: 'https://ddragon.leagueoflegends.com/cdn/15.23.1/img/champion/Ahri.png',
      wins: 42, losses: 26, avgKda: 3.21, avgCspm: 7.5, avgDpm: 890.0,
      avgGpm: 420.0, avgVisionScore: 25.3, avgCsd15: 5.2, avgGd15: 320.0,
      avgXpd15: 150.0, roleDistribution: {'MIDDLE': 60, 'BOTTOM': 8},
    ),
  ];
  const tRoles = [
    PlayerRole(role: 'MID', games: 142, winRate: 58.0),
  ];
  const tActivity = PlayerActivity(raw: {});

  test('should call all 4 repository methods and return OverviewData', () async {
    when(() => mockRepository.getPlayerSummary(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tSummary);
    when(() => mockRepository.getPlayerChampions(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tChampions);
    when(() => mockRepository.getPlayerRoles(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tRoles);
    when(() => mockRepository.getPlayerActivity(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tActivity);

    final result = await useCase(puuid: tPuuid);

    expect(result.summary, tSummary);
    expect(result.champions, tChampions);
    expect(result.roles, tRoles);
    expect(result.activity, tActivity);
    verify(() => mockRepository.getPlayerSummary(puuid: tPuuid)).called(1);
    verify(() => mockRepository.getPlayerChampions(puuid: tPuuid)).called(1);
    verify(() => mockRepository.getPlayerRoles(puuid: tPuuid)).called(1);
    verify(() => mockRepository.getPlayerActivity(puuid: tPuuid)).called(1);
  });

  test('should throw when any parallel call fails', () async {
    when(() => mockRepository.getPlayerSummary(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tSummary);
    when(() => mockRepository.getPlayerChampions(puuid: any(named: 'puuid')))
        .thenThrow(Exception('Network error'));
    when(() => mockRepository.getPlayerRoles(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tRoles);
    when(() => mockRepository.getPlayerActivity(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tActivity);

    expect(() => useCase(puuid: tPuuid), throwsA(isA<Exception>()));
  });
}
