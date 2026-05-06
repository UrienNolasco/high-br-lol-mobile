import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HeatmapCellWidget extends StatelessWidget {
  const HeatmapCellWidget({
    super.key,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: isSelected
              ? Border.all(color: AppColors.accent, width: 2)
              : null,
        ),
      ),
    );
  }
}
