import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_summary.dart';

class GeneralStatsRow extends StatelessWidget {
  const GeneralStatsRow({super.key, required this.summary});

  final PlayerSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          value: '${summary.games}',
          label: 'Games',
          valueColor: AppColors.textPrimary,
        ),
        const SizedBox(width: 6),
        _StatCard(
          value: '${summary.winRate.toStringAsFixed(1)}%',
          label: 'WR',
          valueColor: AppColors.accent,
        ),
        const SizedBox(width: 6),
        _StatCard(
          value: summary.kda.toStringAsFixed(2),
          label: 'KDA',
          valueColor: const Color(0xFF60A5FA),
        ),
        const SizedBox(width: 6),
        _StatCard(
          value: summary.csPerMin.toStringAsFixed(1),
          label: 'CS/m',
          valueColor: AppColors.textPrimary,
        ),
        const SizedBox(width: 6),
        _StatCard(
          value: '${summary.dpm}',
          label: 'DPM',
          valueColor: AppColors.textPrimary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
