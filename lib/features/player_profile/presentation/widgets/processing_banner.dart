import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../player_search/domain/entities/processing_status.dart';
import '../bloc/player_profile_state.dart';
import 'animated_counter_builder.dart';
import 'rotating_icon.dart';
import 'wave_text.dart';

class ProcessingBanner extends StatelessWidget {
  const ProcessingBanner({
    super.key,
    required this.bannerMode,
    this.status,
    this.onTap,
  });

  final BannerMode bannerMode;
  final ProcessingStatus? status;
  final VoidCallback? onTap;

  static const _textStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: bannerMode == BannerMode.ready ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: AppColors.accent.withValues(alpha: 0.9),
        child: switch (bannerMode) {
          BannerMode.processing => _buildProcessing(),
          BannerMode.ready => _buildReady(),
          BannerMode.triggering => _buildTriggering(),
        },
      ),
    );
  }

  Widget _buildProcessing() {
    return AnimatedCounterBuilder(
      target: status?.matchesProcessed ?? 0,
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
              text: 'Processando partidas... $displayValue/${status?.matchesTotal ?? 0}',
              style: _textStyle,
            ),
          ],
        );
      },
    );
  }

  Widget _buildReady() {
    return const Row(
      children: [
        Icon(
          Icons.manage_search,
          size: 16,
          color: Colors.white,
        ),
        SizedBox(width: 8),
        Text(
          'Buscar mais partidas',
          style: _textStyle,
        ),
        Spacer(),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildTriggering() {
    return const Row(
      children: [
        RotatingIcon(
          icon: Icons.sync,
          size: 16,
          color: Colors.white,
        ),
        SizedBox(width: 8),
        WaveText(
          text: 'Iniciando busca...',
          style: _textStyle,
        ),
      ],
    );
  }
}
