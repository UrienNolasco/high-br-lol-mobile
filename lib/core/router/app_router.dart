import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/player_search/presentation/pages/player_search_page.dart';
import '../../features/player_search/presentation/pages/processing_status_page.dart';
import '../../features/player_search/domain/entities/player_search_result.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/search',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        // Tab 0: Meta
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/champions',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Champion Tier List — em construcao')),
              ),
            ),
          ],
        ),
        // Tab 1: Buscar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const PlayerSearchPage(),
              routes: [
                GoRoute(
                  path: 'player/:puuid',
                  builder: (context, state) {
                    final puuid = state.pathParameters['puuid']!;
                    return Scaffold(
                      appBar: AppBar(title: const Text('Perfil')),
                      body: Center(
                        child: Text('Player Profile: $puuid\n\nem construcao'),
                      ),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'processing',
                      builder: (context, state) {
                        final result = state.extra as PlayerSearchResult;
                        return ProcessingStatusPage(
                          puuid: result.puuid,
                          gameName: result.gameName,
                          tagLine: result.tagLine,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Compare
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/compare',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Comparar Jogadores — em construcao')),
              ),
            ),
          ],
        ),
        // Tab 3: Partidas
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/matches',
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Minhas Partidas — em construcao')),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
