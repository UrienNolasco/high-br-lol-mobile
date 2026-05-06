import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/heatmap_cell.dart';

class HeatmapCellDetail extends StatelessWidget {
  const HeatmapCellDetail({
    super.key,
    required this.cell,
  });

  final HeatmapCell cell;

  static const _dayMap = {
    0: 'Segunda-feira',
    1: 'Terca-feira',
    2: 'Quarta-feira',
    3: 'Quinta-feira',
    4: 'Sexta-feira',
    5: 'Sabado',
    6: 'Domingo',
  };

  String get _dayLabel => _dayMap[cell.dayOfWeek] ?? 'Desconhecido';
  String get _hourLabel => '${cell.hour}h';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_dayLabel as $_hourLabel',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Partidas', value: '${cell.games}'),
              _StatItem(
                label: 'Vitorias',
                value: '${cell.wins}',
                color: AppColors.win,
              ),
              _StatItem(
                label: 'Derrotas',
                value: '${cell.losses}',
                color: AppColors.loss,
              ),
              _StatItem(
                label: 'Win Rate',
                value: '${cell.winRate.toStringAsFixed(0)}%',
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
