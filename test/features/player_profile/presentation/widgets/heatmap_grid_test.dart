import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/heatmap_cell.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_heatmap_event.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/widgets/heatmap_grid.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/widgets/heatmap_cell_widget.dart';

List<HeatmapCell> _generateMockCells() {
  return List.generate(
    168,
    (i) => HeatmapCell(
      dayOfWeek: i ~/ 24,
      hour: i % 24,
      games: (i % 5),
      wins: (i % 5) ~/ 2,
      losses: (i % 5) - ((i % 5) ~/ 2),
      winRate: i < 24 ? 50.0 : 60.0,
    ),
  );
}

void main() {
  group('HeatmapGrid', () {
    testWidgets('should render 7 day labels', (tester) async {
      final cells = _generateMockCells();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapGrid(
              cells: cells,
              selectedMetric: HeatmapMetric.games,
            ),
          ),
        ),
      );

      expect(find.text('Seg'), findsOneWidget);
      expect(find.text('Dom'), findsOneWidget);
    });

    testWidgets('should render 24 hour labels', (tester) async {
      final cells = _generateMockCells();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapGrid(
              cells: cells,
              selectedMetric: HeatmapMetric.games,
            ),
          ),
        ),
      );

      expect(find.text('0h'), findsOneWidget);
      expect(find.text('23h'), findsOneWidget);
    });

    testWidgets('should render cells with mock data', (tester) async {
      final cells = _generateMockCells();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapGrid(
              cells: cells,
              selectedMetric: HeatmapMetric.games,
            ),
          ),
        ),
      );

      expect(find.byType(HeatmapCellWidget), findsWidgets);
    });

    testWidgets('should show empty state when all zero games', (tester) async {
      final cells = List.generate(
        168,
        (i) => HeatmapCell(
          dayOfWeek: i ~/ 24,
          hour: i % 24,
          games: 0,
          wins: 0,
          losses: 0,
          winRate: 0.0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapGrid(
              cells: cells,
              selectedMetric: HeatmapMetric.games,
            ),
          ),
        ),
      );

      expect(
        find.text('Sem dados de atividade para este patch'),
        findsOneWidget,
      );
    });

    testWidgets('should call onCellTapped when cell is tapped',
        (tester) async {
      final cells = _generateMockCells();
      int? tappedDay;
      int? tappedHour;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeatmapGrid(
              cells: cells,
              selectedMetric: HeatmapMetric.games,
              onCellTapped: (day, hour) {
                tappedDay = day;
                tappedHour = hour;
              },
            ),
          ),
        ),
      );

      final firstCell = find.byType(HeatmapCellWidget).first;
      await tester.tap(firstCell);
      await tester.pump();

      expect(tappedDay, isNotNull);
      expect(tappedHour, isNotNull);
    });
  });
}
