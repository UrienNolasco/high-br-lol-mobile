# PlayerSearchPage UI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the PlayerSearchPage UI with BottomNavBar, connecting the existing BLoC to a real screen that matches the .pen design.

**Architecture:** UI-only changes. All domain/data/BLoC layers already exist. We create the presentation widgets, wire up the router with StatefulShellRoute for tab navigation, and connect the BLoC via BlocListener for search-triggered navigation.

**Tech Stack:** Flutter widgets, go_router (StatefulShellRoute), flutter_bloc (BlocProvider/BlocListener), existing AppColors/AppTypography

---

### Task 1: ScaffoldWithNavBar + BottomNavBar

**Files:**
- Create: `lib/shared/widgets/scaffold_with_nav_bar.dart`

**Step 1: Create the shell scaffold with BottomNavigationBar**

This widget wraps every tab's content with a shared BottomNavigationBar. GoRouter's `StatefulShellRoute` passes the navigation shell to this widget.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Meta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.compare_arrows),
              label: 'Compare',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports),
              label: 'Partidas',
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues found

**Hora do commit** — adicionamos o ScaffoldWithNavBar com BottomNavigationBar de 4 tabs.

---

### Task 2: Router with StatefulShellRoute

**Files:**
- Modify: `lib/core/router/app_router.dart`

**Step 1: Replace router with StatefulShellRoute**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/player_search/presentation/pages/player_search_page.dart';
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
```

> Note: PlayerSearchPage does not exist yet. This task will show an analyzer warning until Task 4 creates it. That is expected — we build bottom-up.

**Hora do commit** — adicionamos StatefulShellRoute com 4 tabs e rota de player profile placeholder.

---

### Task 3: PlayerSearchBar widget

**Files:**
- Create: `lib/features/player_search/presentation/widgets/player_search_bar.dart`

**Step 1: Create the search bar matching .pen design**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PlayerSearchBar extends StatefulWidget {
  const PlayerSearchBar({
    super.key,
    required this.onSearch,
    this.isLoading = false,
  });

  final void Function(String gameName, String tagLine) onSearch;
  final bool isLoading;

  @override
  State<PlayerSearchBar> createState() => _PlayerSearchBarState();
}

class _PlayerSearchBarState extends State<PlayerSearchBar> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;

    final parts = text.split('#');
    final gameName = parts[0].trim();
    final tagLine = parts.length > 1 ? parts[1].trim() : 'BR1';

    if (gameName.isEmpty) return;
    widget.onSearch(gameName, tagLine);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _controller,
        style: AppTypography.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Jogador#BR1',
          prefixIcon: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                )
              : const Icon(Icons.search, color: AppColors.textMuted, size: 20),
        ),
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}
```

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues found

**Hora do commit** — adicionamos o widget PlayerSearchBar com loading state.

---

### Task 4: RecentSearchRow widget

**Files:**
- Create: `lib/features/player_search/presentation/widgets/recent_search_row.dart`

**Step 1: Create the recent search row matching .pen design**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class RecentSearchRow extends StatelessWidget {
  const RecentSearchRow({
    super.key,
    required this.playerName,
    required this.timeAgo,
    required this.tierLabel,
    required this.tierColor,
    this.onTap,
  });

  final String playerName;
  final String timeAgo;
  final String tierLabel;
  final Color tierColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Avatar placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 12),
            // Name + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgo,
                    style: AppTypography.navLabel.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Tier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: tierColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tierLabel,
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Chevron
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues found

**Hora do commit** — adicionamos o widget RecentSearchRow com avatar, tier badge e chevron.

---

### Task 5: PlayerSearchPage (connects everything)

**Files:**
- Create: `lib/features/player_search/presentation/pages/player_search_page.dart`

**Step 1: Create the page connecting BLoC, SearchBar, and RecentSearches**

```dart
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
                // Header
                Text('Buscar Jogador', style: AppTypography.headlineLarge),
                const SizedBox(height: 16),
                // Search bar
                BlocBuilder<PlayerSearchBloc, PlayerSearchState>(
                  buildWhen: (previous, current) =>
                      current is PlayerSearchLoading ||
                      current is PlayerSearchInitial ||
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
```

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues found

Run: `flutter test`
Expected: All 9 tests pass (no existing tests broken)

**Hora do commit** — adicionamos a PlayerSearchPage conectando BLoC, SearchBar, buscas recentes e navegacao.

---

### Task 6: Visual verification

**Step 1: Run the app**

Run: `flutter run` (on Android emulator)

**Step 2: Verify visually**

Check:
- [ ] Dark background (#0A0E13)
- [ ] "Buscar Jogador" title in JetBrains Mono bold
- [ ] Search bar with search icon and placeholder "Jogador#BR1"
- [ ] "BUSCAS RECENTES" label with letter-spacing
- [ ] 4 recent search rows with avatar, name, time, tier badge, chevron
- [ ] BottomNavBar with 4 tabs (Meta, Buscar, Compare, Partidas)
- [ ] "Buscar" tab is highlighted in blue
- [ ] Tapping other tabs shows placeholder text
- [ ] Typing a name and pressing Enter shows loading spinner in search bar
- [ ] After loading, shows error SnackBar (backend not running) OR navigates to profile placeholder

**Step 3: Fix any visual issues**

Compare with .pen design screenshot and adjust spacing/colors if needed.

**Hora do commit** — tela PlayerSearchPage finalizada e verificada visualmente.
