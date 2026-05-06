import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HeatmapMetricToggle extends StatelessWidget {
  const HeatmapMetricToggle({
    super.key,
    required this.selectedMetric,
    required this.onChanged,
  });

  final String selectedMetric;
  final ValueChanged<String> onChanged;

  static const _metrics = [
    _MetricOption('games', 'Partidas'),
    _MetricOption('wins', 'Vitorias'),
    _MetricOption('losses', 'Derrotas'),
    _MetricOption('winRate', 'Win Rate'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _metrics.map((option) {
          final isSelected = selectedMetric == option.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(option.value),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetricOption {
  const _MetricOption(this.value, this.label);
  final String value;
  final String label;
}
