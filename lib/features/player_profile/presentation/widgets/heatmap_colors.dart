import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

abstract final class HeatmapColors {
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

  static List<Color> scaleFor(String metric) {
    switch (metric) {
      case 'games':
        return _gamesColors;
      case 'wins':
        return _winsColors;
      case 'losses':
        return _lossesColors;
      case 'winRate':
        return _winRateColors;
      default:
        return _gamesColors;
    }
  }

  static Color forValue(double value, double maxValue, List<Color> colors) {
    if (value == 0) return AppColors.bgTertiary;
    final effectiveMax = maxValue > 0 ? maxValue : 1;
    final normalized = value / effectiveMax;
    final bucket =
        (normalized * (colors.length - 1)).ceil().clamp(0, colors.length - 1);
    return colors[bucket];
  }

  static String legendLow(String metric) {
    switch (metric) {
      case 'winRate':
        return '0%';
      default:
        return 'Poucas';
    }
  }

  static String legendHigh(String metric) {
    switch (metric) {
      case 'winRate':
        return '100%';
      default:
        return 'Muitas';
    }
  }
}
