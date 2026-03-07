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
      create: (_) => getIt<PlayerSearchBloc>()
        ..add(const RecentSearchesLoaded()),
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
          context.go('/search/player/${state.result.puuid}');
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
                const Text('Buscar Jogador', style: AppTypography.headlineLarge),
                const SizedBox(height: 16),
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
                Expanded(
                  child: BlocBuilder<PlayerSearchBloc, PlayerSearchState>(
                    buildWhen: (previous, current) =>
                        previous.recentSearches != current.recentSearches,
                    builder: (context, state) {
                      final searches = state.recentSearches;
                      if (searches.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'Nenhuma busca recente',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: searches.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final search = searches[index];
                          return RecentSearchRow(
                            playerName: '${search.gameName}#${search.tagLine}',
                            timeAgo: _formatTimeAgo(search.searchedAt),
                            tierLabel: _tierAbbrev(search.tier),
                            tierColor: _tierColor(search.tier),
                            onTap: () => context.go('/search/player/${search.puuid}'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'ha ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'ha $h ${h == 1 ? 'hora' : 'horas'}';
    }
    final d = diff.inDays;
    return 'ha $d ${d == 1 ? 'dia' : 'dias'}';
  }

  static String _tierAbbrev(String? tier) {
    if (tier == null) return '??';
    return switch (tier.toUpperCase()) {
      'CHALLENGER' => 'CH',
      'GRANDMASTER' => 'GM',
      'MASTER' => 'MA',
      'DIAMOND' => 'DI',
      'EMERALD' => 'EM',
      'PLATINUM' => 'PL',
      'GOLD' => 'GO',
      'SILVER' => 'SI',
      'BRONZE' => 'BR',
      'IRON' => 'IR',
      _ => tier.substring(0, 2).toUpperCase(),
    };
  }

  static Color _tierColor(String? tier) {
    if (tier == null) return AppColors.textSecondary;
    return switch (tier.toUpperCase()) {
      'CHALLENGER' => AppColors.rankChallenger,
      'GRANDMASTER' => AppColors.rankGrandmaster,
      'MASTER' => AppColors.rankMaster,
      'DIAMOND' => AppColors.rankDiamond,
      'EMERALD' => AppColors.rankEmerald,
      'PLATINUM' => AppColors.rankPlatinum,
      'GOLD' => AppColors.rankGold,
      'SILVER' => AppColors.rankSilver,
      'BRONZE' => AppColors.rankBronze,
      'IRON' => AppColors.rankIron,
      _ => AppColors.textSecondary,
    };
  }
}
