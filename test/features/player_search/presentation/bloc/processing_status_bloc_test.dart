import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/get_player_status.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/processing_status_bloc.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/processing_status_event.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/processing_status_state.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockGetPlayerStatus extends Mock implements GetPlayerStatus {}

void main() {
  late ProcessingStatusBloc bloc;
  late MockGetPlayerStatus mockGetPlayerStatus;

  setUp(() {
    mockGetPlayerStatus = MockGetPlayerStatus();
    bloc = ProcessingStatusBloc(mockGetPlayerStatus);
  });

  tearDown(() => bloc.close());

  const tPuuid = 'test-puuid-123';

  const tUpdating = ProcessingStatus(
    status: UpdateStatus.updating,
    matchesProcessed: 5,
    matchesTotal: 20,
    message: 'Processing matches: 5/20',
  );

  const tIdle = ProcessingStatus(
    status: UpdateStatus.idle,
    matchesProcessed: 20,
    matchesTotal: 20,
    message: 'All matches processed',
  );

  const tError = ProcessingStatus(
    status: UpdateStatus.error,
    matchesProcessed: 0,
    matchesTotal: 0,
    message: 'Failed to fetch match status from Riot API',
  );

  test('initial state should be ProcessingStatusLoading', () {
    expect(bloc.state, const ProcessingStatusLoading());
  });

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits [Updating] when started and status is UPDATING',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tUpdating);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProcessingStatusUpdating(matchesProcessed: 5, matchesTotal: 20),
    ],
  );

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits [Complete] when started and status is IDLE',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tIdle);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProcessingStatusComplete(tPuuid),
    ],
  );

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits [Error] when started and status is ERROR',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tError);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProcessingStatusError('Failed to fetch match status from Riot API'),
    ],
  );

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits nothing extra when API throws (silent retry)',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenThrow(const ServerException());
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [],
  );

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits [Loading, Updating] when retried',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tUpdating);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingRetried(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProcessingStatusLoading(),
      const ProcessingStatusUpdating(matchesProcessed: 5, matchesTotal: 20),
    ],
  );
}
