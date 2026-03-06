import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/processing_status_bloc.dart';
import '../bloc/processing_status_event.dart';
import '../bloc/processing_status_state.dart';

class ProcessingStatusPage extends StatelessWidget {
  const ProcessingStatusPage({
    super.key,
    required this.puuid,
    required this.gameName,
    required this.tagLine,
  });

  final String puuid;
  final String gameName;
  final String tagLine;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProcessingStatusBloc>()
        ..add(ProcessingStarted(puuid: puuid)),
      child: _ProcessingStatusView(
        puuid: puuid,
        gameName: gameName,
        tagLine: tagLine,
      ),
    );
  }
}

class _ProcessingStatusView extends StatelessWidget {
  const _ProcessingStatusView({
    required this.puuid,
    required this.gameName,
    required this.tagLine,
  });

  final String puuid;
  final String gameName;
  final String tagLine;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessingStatusBloc, ProcessingStatusState>(
      listener: (context, state) {
        if (state is ProcessingStatusComplete) {
          context.go('/search/player/${state.puuid}');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: BlocBuilder<ProcessingStatusBloc, ProcessingStatusState>(
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Player name
                      Text(
                        '$gameName#$tagLine',
                        style: AppTypography.headlineLarge,
                      ),
                      const SizedBox(height: 32),
                      // Status indicator
                      _buildStatusIndicator(state),
                      const SizedBox(height: 24),
                      // Progress text
                      _buildProgressText(state),
                      const SizedBox(height: 16),
                      // Progress bar
                      if (state is ProcessingStatusUpdating)
                        _buildProgressBar(state),
                      // Error buttons
                      if (state is ProcessingStatusError) ...[
                        const SizedBox(height: 32),
                        _buildErrorButtons(context),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ProcessingStatusState state) {
    if (state is ProcessingStatusError) {
      return const Icon(
        Icons.error_outline,
        color: AppColors.loss,
        size: 48,
      );
    }
    return const SizedBox(
      width: 48,
      height: 48,
      child: CircularProgressIndicator(
        color: AppColors.accent,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildProgressText(ProcessingStatusState state) {
    if (state is ProcessingStatusUpdating) {
      return Text(
        'Processando ${state.matchesProcessed}/${state.matchesTotal} partidas...',
        style: AppTypography.bodyMedium,
        textAlign: TextAlign.center,
      );
    }
    if (state is ProcessingStatusError) {
      return Text(
        state.message,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.loss),
        textAlign: TextAlign.center,
      );
    }
    return const Text(
      'Buscando partidas...',
      style: AppTypography.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressBar(ProcessingStatusUpdating state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: state.progress,
        backgroundColor: AppColors.bgTertiary,
        color: AppColors.accent,
        minHeight: 6,
      ),
    );
  }

  Widget _buildErrorButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              context
                  .read<ProcessingStatusBloc>()
                  .add(ProcessingRetried(puuid: puuid));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Tentar novamente',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () => context.go('/search'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Voltar',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
