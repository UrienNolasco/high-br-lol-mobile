import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../player_search/domain/entities/processing_status.dart';

class ProcessingBanner extends StatelessWidget {
  const ProcessingBanner({super.key, required this.status});

  final ProcessingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.accent.withValues(alpha: 0.9),
      child: Row(
        children: [
          const Icon(Icons.sync, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Processando partidas... ${status.matchesProcessed}/${status.matchesTotal}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
