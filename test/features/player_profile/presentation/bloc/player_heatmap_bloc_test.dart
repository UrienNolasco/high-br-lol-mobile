import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_data.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_cell.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_insights.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_heatmap.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_heatmap_bloc.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_heatmap_event.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_heatmap_state.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockGetPlayerHeatmap extends Mock implements GetPlayerHeatmap {}

void main() {
  late PlayerHeatmapBloc bloc;
  late MockGetPlayerHeatmap mockGetPlayerHeatmap;

  setUp(() {
    mockGetPlayerHeatmap = MockGetPlayerHeatmap();
    bloc = PlayerHeatmapBloc(mockGetPlayerHeatmap);
  });

  tearDown(() => bloc.close());

  const tPuuid = 'test-puuid-123';

  final tHeatmapData = HeatmapData(
    puuid: tPuuid,
    patch: 'lifetime',
    cells: List.generate(
      168,
      (i) => HeatmapCell(
        dayOfWeek: i ~/ 24,
        hour: i % 24,
        games: i < 10 ? i : 0,
        wins: i < 10 ? i ~/ 2 : 0,
        losses: i < 10 ? (i - i ~/ 2) : 0,
        winRate: i < 10 ? 50.0 : 0.0,
      ),
    ),
    insights: const HeatmapInsights(
      mostActiveDay: 'Saturday',
      mostActiveDayGames: 35,
      mostActiveHour: 23,
      mostActiveHourGames: 15,
      peakWinRate: 75.0,
      peakWinRateTime: 'Sunday 14h',
      worstWinRate: 30.0,
      worstWinRateTime: 'Saturday 3h',
    ),
  );

  blocTest<PlayerHeatmapBloc, PlayerHeatmapState>(
    'should emit [Loading, Loaded] when HeatmapStarted succeeds',
    build: () => bloc,
    setUp: () {
      when(() => mockGetPlayerHeatmap(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tHeatmapData);
    },
    act: (bloc) => bloc.add(const HeatmapStarted(puuid: tPuuid)),
    expect: () => [
      const HeatmapLoading(),
      HeatmapLoaded(data: tHeatmapData),
    ],
    verify: (_) {
      verify(() => mockGetPlayerHeatmap(puuid: tPuuid)).called(1);
    },
  );

  blocTest<PlayerHeatmapBloc, PlayerHeatmapState>(
    'should emit [Loading, Error] when HeatmapStarted fails with ApiException',
    build: () => bloc,
    setUp: () {
      when(() => mockGetPlayerHeatmap(puuid: any(named: 'puuid')))
          .thenThrow(ServerException());
    },
    act: (bloc) => bloc.add(const HeatmapStarted(puuid: tPuuid)),
    expect: () => [
      const HeatmapLoading(),
      const HeatmapError('Erro no servidor. Tente novamente.'),
    ],
  );

  blocTest<PlayerHeatmapBloc, PlayerHeatmapState>(
    'should handle MetricToggled event',
    build: () => bloc,
    seed: () => HeatmapLoaded(data: tHeatmapData),
    act: (bloc) => bloc.add(const MetricToggled(HeatmapMetric.wins)),
    expect: () => [
      HeatmapLoaded(
        data: tHeatmapData,
        selectedMetric: HeatmapMetric.wins,
      ),
    ],
  );

  blocTest<PlayerHeatmapBloc, PlayerHeatmapState>(
    'should handle CellTapped event selecting a cell',
    build: () => bloc,
    seed: () => HeatmapLoaded(data: tHeatmapData),
    act: (bloc) => bloc.add(const CellTapped(dayOfWeek: 1, hour: 5)),
    expect: () => [
      HeatmapLoaded(
        data: tHeatmapData,
        selectedDayOfWeek: 1,
        selectedHour: 5,
      ),
    ],
  );

  blocTest<PlayerHeatmapBloc, PlayerHeatmapState>(
    'should clear selection when tapping same cell twice',
    build: () => bloc,
    seed: () => HeatmapLoaded(
      data: tHeatmapData,
      selectedDayOfWeek: 1,
      selectedHour: 5,
    ),
    act: (bloc) => bloc.add(const CellTapped(dayOfWeek: 1, hour: 5)),
    expect: () => [
      HeatmapLoaded(data: tHeatmapData),
    ],
  );
}
