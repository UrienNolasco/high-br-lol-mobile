import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';
import '../bloc/player_overview_bloc.dart';
import '../bloc/player_overview_event.dart';
import '../bloc/player_overview_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/processing_banner.dart';
import '../widgets/profile_tabs.dart';
import '../widgets/overview_content.dart';

class PlayerProfilePage extends StatelessWidget {
  const PlayerProfilePage({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<PlayerProfileBloc>()
            ..add(ProfileStarted(puuid: puuid)),
        ),
        BlocProvider(
          create: (_) => getIt<PlayerOverviewBloc>()
            ..add(OverviewStarted(puuid: puuid)),
        ),
      ],
      child: const _PlayerProfileView(),
    );
  }
}

class _PlayerProfileView extends StatelessWidget {
  const _PlayerProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Back row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Perfil',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Header
            BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const SizedBox(
                    height: 80,
                    child: LoadingIndicator(),
                  );
                }
                if (state is ProfileError) {
                  return ErrorDisplay(
                    message: state.message,
                    onRetry: () => context.read<PlayerProfileBloc>().add(
                          ProfileStarted(
                            puuid: (context.read<PlayerProfileBloc>()
                                    .state as ProfileError)
                                .message,
                          ),
                        ),
                  );
                }
                if (state is ProfileLoaded) {
                  return Column(
                    children: [
                      ProfileHeader(player: state.player),
                      if (state.isProcessing)
                        ProcessingBanner(status: state.processingStatus!),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Tabs
            const ProfileTabs(selectedIndex: 0),
            // Body
            Expanded(
              child: BlocBuilder<PlayerOverviewBloc, PlayerOverviewState>(
                builder: (context, state) {
                  if (state is OverviewLoading) {
                    return const LoadingIndicator();
                  }
                  if (state is OverviewError) {
                    return ErrorDisplay(message: state.message);
                  }
                  if (state is OverviewLoaded) {
                    return OverviewContent(data: state.data);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
