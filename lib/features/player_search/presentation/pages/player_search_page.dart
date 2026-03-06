import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/player_search_bloc.dart';
import '../bloc/player_search_event.dart';
import '../bloc/player_search_state.dart';
import '../widgets/player_search_bar.dart';
import '../widgets/recent_search_row.dart';

class PlayerSearchPage extends StatelessWidget {
  const PlayerSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PlayerSearchBloc>(),
      child: const _PlayerSearchView(),
    );
  }
}

class _PlayerSearchView extends StatelessWidget {
  const _PlayerSearchView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerSearchBloc, PlayerSearchState>(
      listener: (context, state) {
        if (state is PlayerSearchSuccess) {
          context.go(
            '/search/player/${state.result.puuid}/processing',
            extra: state.result,
          );
        } else if (state is PlayerSearchFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.loss,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Header
                const Text('Buscar Jogador', style: AppTypography.headlineLarge),
                const SizedBox(height: 16),
                // Search bar
                BlocBuilder<PlayerSearchBloc, PlayerSearchState>(
                  buildWhen: (previous, current) =>
                      current is PlayerSearchLoading ||
                      current is PlayerSearchInitial ||
                      current is PlayerSearchSuccess ||
                      current is PlayerSearchFailure,
                  builder: (context, state) {
                    return PlayerSearchBar(
                      isLoading: state is PlayerSearchLoading,
                      onSearch: (gameName, tagLine) {
                        context.read<PlayerSearchBloc>().add(
                              PlayerSearchSubmitted(
                                gameName: gameName,
                                tagLine: tagLine,
                              ),
                            );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Recent searches label
                Text(
                  'BUSCAS RECENTES',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                // Recent searches list (static placeholder)
                const RecentSearchRow(
                  playerName: 'UrienMano#BR1',
                  timeAgo: 'ha 2 min',
                  tierLabel: 'CH',
                  tierColor: Color(0xFFDC2626),
                ),
                const Divider(),
                const RecentSearchRow(
                  playerName: 'Faker#KR1',
                  timeAgo: 'ha 15 min',
                  tierLabel: 'CH',
                  tierColor: Color(0xFFDC2626),
                ),
                const Divider(),
                const RecentSearchRow(
                  playerName: 'Robo#BR1',
                  timeAgo: 'ha 1 hora',
                  tierLabel: 'GM',
                  tierColor: Color(0xFFF59E0B),
                ),
                const Divider(),
                const RecentSearchRow(
                  playerName: 'TinoWins#BR1',
                  timeAgo: 'ha 3 horas',
                  tierLabel: 'MA',
                  tierColor: Color(0xFF3B82F6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
