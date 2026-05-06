import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/heatmap_cell.dart';
import '../bloc/player_heatmap_event.dart';
import 'heatmap_cell_widget.dart';
import 'heatmap_legend.dart';

class HeatmapGrid extends StatelessWidget {
  const HeatmapGrid({
    super.key,
    required this.cells,
    required this.selectedMetric,
    this.selectedDayOfWeek,
    this.selectedHour,
    this.onCellTapped,
  });

  final List<HeatmapCell> cells;
  final HeatmapMetric selectedMetric;
  final int? selectedDayOfWeek;
  final int? selectedHour;
  final void Function(int dayOfWeek, int hour)? onCellTapped;

  static const _dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];

  static const _gamesColors = [
    Color(0xFF161B22),
    Color(0xFF0E4429),
    Color(0xFF006D32),
    Color(0xFF26A641),
    Color(0xFF39D353),
  ];

  static const _winsColors = [
    Color(0xFF161B22),
    Color(0xFF14532D),
    Color(0xFF16A34A),
    Color(0xFF4ADE80),
    Color(0xFF86EFAC),
  ];

  static const _lossesColors = [
    Color(0xFF161B22),
    Color(0xFF450A0A),
    Color(0xFF991B1B),
    Color(0xFFDC2626),
    Color(0xFFF87171),
  ];

  static const _winRateColors = [
    Color(0xFF3B82F6),
    Color(0xFF22D3EE),
    Color(0xFF22C55E),
    Color(0xFFEAB308),
    Color(0xFFEF4444),
  ];

  HeatmapCell? _findCell(int day, int hour) {
    try {
      return cells.firstWhere(
        (c) => c.dayOfWeek == day && c.hour == hour,
      );
    } catch (_) {
      return null;
    }
  }

  double _getValue(HeatmapCell cell) {
    switch (selectedMetric) {
      case HeatmapMetric.games:
        return cell.games.toDouble();
      case HeatmapMetric.wins:
        return cell.wins.toDouble();
      case HeatmapMetric.losses:
        return cell.losses.toDouble();
      case HeatmapMetric.winRate:
        return cell.winRate;
    }
  }

  double get _maxValue {
    if (cells.isEmpty) return 1;
    return cells.map((c) => _getValue(c)).reduce((a, b) => a > b ? a : b);
  }

  List<Color> get _currentColors {
    switch (selectedMetric) {
      case HeatmapMetric.games:
        return _gamesColors;
      case HeatmapMetric.wins:
        return _winsColors;
      case HeatmapMetric.losses:
        return _lossesColors;
      case HeatmapMetric.winRate:
        return _winRateColors;
    }
  }

  String get _legendLowLabel {
    switch (selectedMetric) {
      case HeatmapMetric.winRate:
        return '0%';
      default:
        return 'Poucas';
    }
  }

  String get _legendHighLabel {
    switch (selectedMetric) {
      case HeatmapMetric.winRate:
        return '100%';
      default:
        return 'Muitas';
    }
  }

  Color _colorForValue(double value) {
    if (value == 0) return AppColors.bgTertiary;
    final colors = _currentColors;
    final maxVal = _maxValue > 0 ? _maxValue : 1;
    final normalized = value / maxVal;
    final bucket =
        (normalized * (colors.length - 1)).ceil().clamp(0, colors.length - 1);
    return colors[bucket];
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = cells.isEmpty ||
        cells.every((c) => c.games == 0 && c.wins == 0 && c.losses == 0);

    if (isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'Sem dados de atividade para este patch',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    const cellSize = 28.0;
    const cellMargin = 2.0;
    const totalCellSize = cellSize + cellMargin * 2;

    final gridHeight = 7 * totalCellSize;
    final gridWidth = 24 * totalCellSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: gridHeight + 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  ...List.generate(7, (day) {
                    return SizedBox(
                      height: totalCellSize,
                      child: Center(
                        child: Text(
                          _dayLabels[day],
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: gridWidth + 36,
                    child: Column(
                      children: [
                        Row(
                          children: List.generate(24, (hour) {
                            return SizedBox(
                              width: totalCellSize,
                              child: Center(
                                child: Text(
                                  '${hour}h',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        Column(
                          children: List.generate(7, (day) {
                            return Row(
                              children: List.generate(24, (hour) {
                                final cell = _findCell(day, hour);
                                final value =
                                    cell != null ? _getValue(cell) : 0.0;
                                return HeatmapCellWidget(
                                  color: _colorForValue(value),
                                  isSelected: selectedDayOfWeek == day &&
                                      selectedHour == hour,
                                  onTap: () =>
                                      onCellTapped?.call(day, hour),
                                );
                              }),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        HeatmapLegend(
          colors: _currentColors,
          lowLabel: _legendLowLabel,
          highLabel: _legendHighLabel,
        ),
      ],
    );
  }
}
