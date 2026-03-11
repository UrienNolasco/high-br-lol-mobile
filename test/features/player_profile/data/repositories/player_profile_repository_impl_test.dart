import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/datasources/player_profile_remote_datasource.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_profile_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_summary_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_champion_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_role_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_activity_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/sync_trigger_result_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/repositories/player_profile_repository_impl.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/processing_status_model.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';

class MockRemoteDataSource extends Mock
    implements PlayerProfileRemoteDataSource {}

void main() {
  late PlayerProfileRepositoryImpl repository;
  late MockRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockRemoteDataSource();
    repository = PlayerProfileRepositoryImpl(mockDataSource);
  });

  const tPuuid = 'test-puuid-123';

  const tProfile = PlayerProfileModel(
    puuid: tPuuid,
    gameName: 'UrienMano',
    tagLine: 'BR1',
    profileIconId: 1234,
    tier: 'CHALLENGER',
    rank: 'I',
    leaguePoints: 1234,
    wins: 150,
    losses: 120,
  );

  const tSummary = PlayerSummaryModel(
    games: 270,
    winRate: 55.6,
    kda: 3.42,
    csPerMin: 7.8,
    dpm: 624,
  );

  test('should return PlayerProfile when getPlayerProfile succeeds', () async {
    when(() => mockDataSource.getPlayerProfile(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tProfile);

    final result = await repository.getPlayerProfile(puuid: tPuuid);

    expect(result, tProfile);
    verify(() => mockDataSource.getPlayerProfile(puuid: tPuuid)).called(1);
  });

  test('should return PlayerSummary when getPlayerSummary succeeds', () async {
    when(() => mockDataSource.getPlayerSummary(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tSummary);

    final result = await repository.getPlayerSummary(puuid: tPuuid);

    expect(result, tSummary);
    verify(() => mockDataSource.getPlayerSummary(puuid: tPuuid)).called(1);
  });

  test('should return champion list when getPlayerChampions succeeds',
      () async {
    const tChampions = [
      PlayerChampionModel(
        name: 'Ahri', games: 68, winRate: 61.8, iconId: 103,
        imageUrl: 'https://ddragon.leagueoflegends.com/cdn/15.23.1/img/champion/Ahri.png',
        wins: 42, losses: 26, avgKda: 3.21, avgCspm: 7.5, avgDpm: 890.0,
        avgGpm: 420.0, avgVisionScore: 25.3, avgCsd15: 5.2, avgGd15: 320.0,
        avgXpd15: 150.0, roleDistribution: {'MIDDLE': 60, 'BOTTOM': 8},
      ),
    ];
    when(() => mockDataSource.getPlayerChampions(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tChampions);

    final result = await repository.getPlayerChampions(puuid: tPuuid);

    expect(result, tChampions);
  });

  test('should return role list when getPlayerRoles succeeds', () async {
    const tRoles = [
      PlayerRoleModel(role: 'MID', games: 142, winRate: 58.0),
    ];
    when(() => mockDataSource.getPlayerRoles(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tRoles);

    final result = await repository.getPlayerRoles(puuid: tPuuid);

    expect(result, tRoles);
  });

  test('should return activity when getPlayerActivity succeeds', () async {
    const tActivity = PlayerActivityModel(raw: {});
    when(() => mockDataSource.getPlayerActivity(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tActivity);

    final result = await repository.getPlayerActivity(puuid: tPuuid);

    expect(result, tActivity);
  });

  test('should trigger deep sync via datasource', () async {
    const tResult = SyncTriggerResultModel(
      puuid: tPuuid,
      status: 'SYNCING',
      matchesEnqueued: 5,
      matchesTotal: 42,
      matchesAlreadyInDb: 37,
      message: 'Sync started',
    );
    when(() => mockDataSource.triggerDeepSync(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tResult);

    final result = await repository.triggerDeepSync(puuid: tPuuid);

    expect(result, tResult);
    verify(() => mockDataSource.triggerDeepSync(puuid: tPuuid)).called(1);
  });

  test('should get deep sync status via datasource', () async {
    const tSyncStatus = ProcessingStatusModel(
      status: UpdateStatus.updating,
      matchesProcessed: 30,
      matchesTotal: 42,
      message: 'Sync in progress',
    );
    when(() => mockDataSource.getDeepSyncStatus(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tSyncStatus);

    final result = await repository.getDeepSyncStatus(puuid: tPuuid);

    expect(result, tSyncStatus);
    verify(() => mockDataSource.getDeepSyncStatus(puuid: tPuuid)).called(1);
  });
}
