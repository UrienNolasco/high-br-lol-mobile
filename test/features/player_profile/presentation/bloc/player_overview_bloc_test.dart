import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/overview_data.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_summary.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_champion.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_role.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_activity.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_overview.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_overview_bloc.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_overview_event.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_overview_state.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockGetPlayerOverview extends Mock implements GetPlayerOverview {}

void main() {
  late PlayerOverviewBloc bloc;
  late MockGetPlayerOverview mockGetPlayerOverview;

  setUp(() {
    mockGetPlayerOverview = MockGetPlayerOverview();
    bloc = PlayerOverviewBloc(mockGetPlayerOverview);
  });

  tearDown(() => bloc.close());

  const tPuuid = 'test-puuid-123';

  const tOverview = OverviewData(
    summary: PlayerSummary(
      games: 270,
      winRate: 55.6,
      kda: 3.42,
      csPerMin: 7.8,
      dpm: 624,
    ),
    champions: [
      PlayerChampion(name: 'Ahri', games: 68, winRate: 61.8, iconId: 103),
    ],
    roles: [
      PlayerRole(role: 'MID', games: 142, winRate: 58.0),
    ],
    activity: PlayerActivity(raw: {}),
  );

  test('initial state should be OverviewLoading', () {
    expect(bloc.state, const OverviewLoading());
  });

  blocTest<PlayerOverviewBloc, PlayerOverviewState>(
    'emits [OverviewLoading, OverviewLoaded] when overview loads successfully',
    build: () {
      when(() => mockGetPlayerOverview(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tOverview);
      return bloc;
    },
    act: (bloc) => bloc.add(const OverviewStarted(puuid: tPuuid)),
    expect: () => [
      const OverviewLoading(),
      const OverviewLoaded(tOverview),
    ],
  );

  blocTest<PlayerOverviewBloc, PlayerOverviewState>(
    'emits [OverviewLoading, OverviewError] when overview fails with ServerException',
    build: () {
      when(() => mockGetPlayerOverview(puuid: any(named: 'puuid')))
          .thenThrow(const ServerException());
      return bloc;
    },
    act: (bloc) => bloc.add(const OverviewStarted(puuid: tPuuid)),
    expect: () => [
      const OverviewLoading(),
      const OverviewError('Erro no servidor. Tente novamente.'),
    ],
  );
}
