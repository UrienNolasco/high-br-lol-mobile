import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/heatmap_insights.dart';

class HeatmapInsightsPanel extends StatelessWidget {
  const HeatmapInsightsPanel({super.key, required this.insights});

  final HeatmapInsights insights;

  static const _dayMap = {
    'Monday': 'Segunda',
    'Tuesday': 'Terca',
    'Wednesday': 'Quarta',
    'Thursday': 'Quinta',
    'Friday': 'Sexta',
    'Saturday': 'Sabado',
    'Sunday': 'Domingo',
  };

  String _translateDay(String day) => _dayMap[day] ?? day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Insights',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InsightCard(
              label: 'Dia mais ativo',
              value:
                  '${_translateDay(insights.mostActiveDay)} - ${insights.mostActiveDayGames} jogos',
              color: AppColors.win,
            ),
            _InsightCard(
              label: 'Horario mais ativo',
              value: '${insights.mostActiveHour}h - ${insights.mostActiveHourGames} jogos',
              color: AppColors.gold,
            ),
            _InsightCard(
              label: 'Melhor win rate',
              value: '${insights.peakWinRate.toStringAsFixed(0)}% - ${insights.peakWinRateTime}',
              color: AppColors.accent,
            ),
            _InsightCard(
              label: 'Pior win rate',
              value: '${insights.worstWinRate.toStringAsFixed(0)}% - ${insights.worstWinRateTime}',
              color: AppColors.loss,
            ),
          ],
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
