import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({
    super.key,
    required this.colors,
    required this.lowLabel,
    required this.highLabel,
  });

  final List<Color> colors;
  final String lowLabel;
  final String highLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            lowLabel,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            highLabel,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
