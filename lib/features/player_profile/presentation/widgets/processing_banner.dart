// lib/features/player_profile/presentation/widgets/processing_banner.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../player_search/domain/entities/processing_status.dart';
import 'animated_counter_builder.dart';
import 'rotating_icon.dart';
import 'wave_text.dart';

class ProcessingBanner extends StatelessWidget {
  const ProcessingBanner({super.key, required this.status});

  final ProcessingStatus status;

  static const _textStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.accent.withValues(alpha: 0.9),
      child: AnimatedCounterBuilder(
        target: status.matchesProcessed,
        builder: (context, displayValue) {
          return Row(
            children: [
              const RotatingIcon(
                icon: Icons.sync,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              WaveText(
                text: 'Processando partidas... $displayValue/${status.matchesTotal}',
                style: _textStyle,
              ),
            ],
          );
        },
      ),
    );
  }
}
