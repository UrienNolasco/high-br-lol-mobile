import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_data.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_cell.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_insights.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/repositories/player_profile_repository.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_heatmap.dart';

class MockPlayerProfileRepository extends Mock
    implements PlayerProfileRepository {}

void main() {
  late GetPlayerHeatmap useCase;
  late MockPlayerProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerProfileRepository();
    useCase = GetPlayerHeatmap(mockRepository);
  });

  const tPuuid = 'test-puuid-123';

  final tHeatmapData = HeatmapData(
    puuid: tPuuid,
    patch: 'lifetime',
    cells: const [
      HeatmapCell(
        dayOfWeek: 0,
        hour: 14,
        games: 5,
        wins: 3,
        losses: 2,
        winRate: 60.0,
      ),
    ],
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

  test('should call repository and return HeatmapData', () async {
    when(() => mockRepository.getPlayerHeatmap(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tHeatmapData);

    final result = await useCase(puuid: tPuuid);

    expect(result, tHeatmapData);
    verify(() => mockRepository.getPlayerHeatmap(puuid: tPuuid)).called(1);
  });

  test('should propagate repository errors', () async {
    when(() => mockRepository.getPlayerHeatmap(puuid: any(named: 'puuid')))
        .thenThrow(Exception('Network error'));

    expect(() => useCase(puuid: tPuuid), throwsA(isA<Exception>()));
  });
}
