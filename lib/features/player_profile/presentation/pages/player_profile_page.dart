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
import '../bloc/player_heatmap_bloc.dart';
import '../bloc/player_heatmap_event.dart';
import '../bloc/player_heatmap_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/processing_banner.dart';
import '../widgets/profile_tabs.dart';
import '../widgets/overview_content.dart';
import '../widgets/champions_content.dart';
import '../widgets/heatmap_cell_detail.dart';
import '../widgets/heatmap_grid.dart';
import '../widgets/heatmap_insights_panel.dart';
import '../widgets/heatmap_metric_toggle.dart';

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
        BlocProvider(
          create: (_) => getIt<PlayerHeatmapBloc>()
            ..add(HeatmapStarted(puuid: puuid)),
        ),
      ],
      child: const _PlayerProfileView(),
    );
  }
}

class _PlayerProfileView extends StatefulWidget {
  const _PlayerProfileView();

  @override
  State<_PlayerProfileView> createState() => _PlayerProfileViewState();
}

class _PlayerProfileViewState extends State<_PlayerProfileView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: BlocListener<PlayerProfileBloc, PlayerProfileState>(
        listenWhen: (prev, curr) =>
            curr is ProfileLoaded && curr.syncError != null,
        listener: (context, state) {
          if (state is ProfileLoaded && state.syncError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.syncError!),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        child: SafeArea(
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
              // Header + Banner
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
                        ProcessingBanner(
                          bannerMode: state.bannerMode,
                          status: state.processingStatus,
                          onTap: () => context
                              .read<PlayerProfileBloc>()
                              .add(const DeepSyncRequested()),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Tabs
              ProfileTabs(
                selectedIndex: _selectedTab,
                onTap: (index) => setState(() => _selectedTab = index),
              ),
              // Body
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return BlocBuilder<PlayerOverviewBloc, PlayerOverviewState>(
          builder: (context, state) {
            if (state is OverviewLoading) return const LoadingIndicator();
            if (state is OverviewError) {
              return ErrorDisplay(message: state.message);
            }
            if (state is OverviewLoaded) {
              return OverviewContent(data: state.data);
            }
            return const SizedBox.shrink();
          },
        );
      case 1:
        return BlocBuilder<PlayerOverviewBloc, PlayerOverviewState>(
          builder: (context, state) {
            if (state is OverviewLoading) return const LoadingIndicator();
            if (state is OverviewError) {
              return ErrorDisplay(message: state.message);
            }
            if (state is OverviewLoaded) {
              return ChampionsContent(champions: state.data.champions);
            }
            return const SizedBox.shrink();
          },
        );
      case 2:
        return const Center(
          child: Text(
            'Em breve',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        );
      case 3:
        return BlocBuilder<PlayerHeatmapBloc, PlayerHeatmapState>(
          builder: (context, state) {
            if (state is HeatmapLoading) return const LoadingIndicator();
            if (state is HeatmapError) {
              return ErrorDisplay(
                message: state.message,
                onRetry: () {
                  final bloc = context.read<PlayerHeatmapBloc>();
                  final profileBloc = context.read<PlayerProfileBloc>();
                  final currentState = profileBloc.state;
                  final puuid = currentState is ProfileLoaded
                      ? currentState.player.puuid
                      : '';
                  bloc.add(HeatmapStarted(puuid: puuid));
                },
              );
            }
            if (state is HeatmapLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeatmapMetricToggle(
                      selectedMetric: state.selectedMetric.name,
                      onChanged: (metric) {
                        final heatmapMetric = HeatmapMetric.values
                            .firstWhere((m) => m.name == metric);
                        context.read<PlayerHeatmapBloc>().add(
                              MetricToggled(heatmapMetric),
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                    HeatmapGrid(
                      cells: state.data.cells,
                      selectedMetric: state.selectedMetric,
                      selectedDayOfWeek: state.selectedDayOfWeek,
                      selectedHour: state.selectedHour,
                      onCellTapped: (day, hour) {
                        context.read<PlayerHeatmapBloc>().add(
                              CellTapped(dayOfWeek: day, hour: hour),
                            );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (state.selectedDayOfWeek != null &&
                        state.selectedHour != null)
                      ...(() {
                        final selectedCell = state.data.cells.firstWhere(
                          (c) =>
                              c.dayOfWeek == state.selectedDayOfWeek &&
                              c.hour == state.selectedHour,
                          orElse: () => state.data.cells.first,
                        );
                        return [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: HeatmapCellDetail(cell: selectedCell),
                          ),
                        ];
                      })(),
                    HeatmapInsightsPanel(insights: state.data.insights),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      default:
        return const Center(
          child: Text(
            'Em breve',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        );
    }
  }
}
