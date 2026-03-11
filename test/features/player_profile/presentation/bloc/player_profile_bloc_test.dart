import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_profile.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/sync_trigger_result.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_profile.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/trigger_deep_sync.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_deep_sync_status.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_bloc.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_event.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_state.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/get_player_status.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockGetPlayerProfile extends Mock implements GetPlayerProfile {}
class MockGetPlayerStatus extends Mock implements GetPlayerStatus {}
class MockTriggerDeepSync extends Mock implements TriggerDeepSync {}
class MockGetDeepSyncStatus extends Mock implements GetDeepSyncStatus {}

void main() {
  late PlayerProfileBloc bloc;
  late MockGetPlayerProfile mockGetPlayerProfile;
  late MockGetPlayerStatus mockGetPlayerStatus;
  late MockTriggerDeepSync mockTriggerDeepSync;
  late MockGetDeepSyncStatus mockGetDeepSyncStatus;

  setUp(() {
    mockGetPlayerProfile = MockGetPlayerProfile();
    mockGetPlayerStatus = MockGetPlayerStatus();
    mockTriggerDeepSync = MockTriggerDeepSync();
    mockGetDeepSyncStatus = MockGetDeepSyncStatus();
    bloc = PlayerProfileBloc(
      mockGetPlayerProfile,
      mockGetPlayerStatus,
      mockTriggerDeepSync,
      mockGetDeepSyncStatus,
    );
  });

  tearDown(() => bloc.close());

  const tPuuid = 'test-puuid-123';

  const tProfile = PlayerProfile(
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

  const tStatusUpdating = ProcessingStatus(
    status: UpdateStatus.updating,
    matchesProcessed: 5,
    matchesTotal: 20,
    message: 'Processing',
  );

  const tStatusIdle = ProcessingStatus(
    status: UpdateStatus.idle,
    matchesProcessed: 20,
    matchesTotal: 20,
    message: 'Done',
  );

  const tSyncResult = SyncTriggerResult(
    puuid: tPuuid,
    status: 'SYNCING',
    matchesEnqueued: 5,
    matchesTotal: 42,
    matchesAlreadyInDb: 37,
    message: 'Sync started',
  );

  test('initial state should be ProfileLoading', () {
    expect(bloc.state, const ProfileLoading());
  });

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'emits [ProfileLoaded(processing)] when profile loads, then polls status',
    build: () {
      when(() => mockGetPlayerProfile(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tProfile);
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tStatusUpdating);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProfileStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 200),
    expect: () => [
      const ProfileLoaded(player: tProfile, bannerMode: BannerMode.processing),
      const ProfileLoaded(
        player: tProfile,
        bannerMode: BannerMode.processing,
        processingStatus: tStatusUpdating,
      ),
    ],
  );

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'emits [ProfileLoaded(ready)] when polling returns IDLE',
    build: () {
      when(() => mockGetPlayerProfile(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tProfile);
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tStatusIdle);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProfileStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 200),
    expect: () => [
      const ProfileLoaded(player: tProfile, bannerMode: BannerMode.processing),
      const ProfileLoaded(
        player: tProfile,
        bannerMode: BannerMode.ready,
        processingStatus: tStatusIdle,
      ),
    ],
  );

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'emits [ProfileError] when profile load fails',
    build: () {
      when(() => mockGetPlayerProfile(puuid: any(named: 'puuid')))
          .thenThrow(const NotFoundException());
      return bloc;
    },
    act: (bloc) => bloc.add(const ProfileStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProfileError('Recurso nao encontrado.'),
    ],
  );

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'silently retries when status polling throws',
    build: () {
      when(() => mockGetPlayerProfile(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tProfile);
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenThrow(const ServerException());
      return bloc;
    },
    act: (bloc) => bloc.add(const ProfileStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 200),
    expect: () => [
      const ProfileLoaded(player: tProfile, bannerMode: BannerMode.processing),
    ],
  );

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'deep sync: emits triggering then starts sync polling',
    build: () {
      when(() => mockGetPlayerProfile(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tProfile);
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tStatusIdle);
      when(() => mockTriggerDeepSync(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tSyncResult);
      when(() => mockGetDeepSyncStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tStatusUpdating);
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const ProfileStarted(puuid: tPuuid));
      await Future.delayed(const Duration(milliseconds: 300));
      bloc.add(const DeepSyncRequested());
    },
    wait: const Duration(milliseconds: 600),
    expect: () => [
      const ProfileLoaded(player: tProfile, bannerMode: BannerMode.processing),
      const ProfileLoaded(
        player: tProfile,
        bannerMode: BannerMode.ready,
        processingStatus: tStatusIdle,
      ),
      // After DeepSyncRequested:
      const ProfileLoaded(
        player: tProfile,
        bannerMode: BannerMode.triggering,
        processingStatus: tStatusIdle,
      ),
      const ProfileLoaded(
        player: tProfile,
        bannerMode: BannerMode.processing,
        processingStatus: tStatusUpdating,
      ),
    ],
  );

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'deep sync: ignores request when not in ready mode',
    seed: () => const ProfileLoaded(
      player: tProfile,
      bannerMode: BannerMode.processing,
      processingStatus: tStatusUpdating,
    ),
    build: () => bloc,
    act: (bloc) => bloc.add(const DeepSyncRequested()),
    expect: () => [],
  );
}
