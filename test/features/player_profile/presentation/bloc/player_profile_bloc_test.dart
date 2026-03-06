import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_profile.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_profile.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_bloc.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_event.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_state.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/get_player_status.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockGetPlayerProfile extends Mock implements GetPlayerProfile {}

class MockGetPlayerStatus extends Mock implements GetPlayerStatus {}

void main() {
  late PlayerProfileBloc bloc;
  late MockGetPlayerProfile mockGetPlayerProfile;
  late MockGetPlayerStatus mockGetPlayerStatus;

  setUp(() {
    mockGetPlayerProfile = MockGetPlayerProfile();
    mockGetPlayerStatus = MockGetPlayerStatus();
    bloc = PlayerProfileBloc(mockGetPlayerProfile, mockGetPlayerStatus);
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

  test('initial state should be ProfileLoading', () {
    expect(bloc.state, const ProfileLoading());
  });

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'emits [ProfileLoaded] when profile loads successfully, then polls status',
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
      const ProfileLoaded(player: tProfile),
      const ProfileLoaded(player: tProfile, processingStatus: tStatusUpdating),
    ],
  );

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'emits [ProfileLoaded] with null status when polling returns IDLE',
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
      // Only one emission because the idle poll produces an equal state
      // (processingStatus: null) which BLoC deduplicates.
      const ProfileLoaded(player: tProfile),
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
      const ProfileLoaded(player: tProfile),
    ],
  );
}
