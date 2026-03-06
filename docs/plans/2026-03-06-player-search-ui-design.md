# PlayerSearchPage UI Design

## Overview

Build the PlayerSearchPage UI connecting the existing BLoC to a real screen matching the .pen design. Includes BottomNavBar with 4 tabs and navigation to player profile on successful search.

## Components

```
PlayerSearchPage (StatelessWidget)
├── BlocProvider (injects PlayerSearchBloc from get_it)
└── Scaffold
    ├── AppBar: "Buscar Jogador"
    ├── Body:
    │   ├── PlayerSearchBar (TextField with search icon)
    │   ├── BlocListener
    │   │   ├── Loading → loading indicator on search button
    │   │   ├── Success → navigates to /player/:puuid (placeholder)
    │   │   └── Failure → SnackBar with error message
    │   └── RecentSearches (static placeholder)
    │       ├── Label "BUSCAS RECENTES"
    │       └── Hardcoded list with 3-4 fake items
    └── BottomNavBar (4 tabs)
```

## Navigation

StatefulShellRoute with 4 tabs, each maintaining its own navigation stack:

- Tab 0: Meta → /champions (placeholder)
- Tab 1: Buscar → / (PlayerSearchPage) → /player/:puuid (placeholder)
- Tab 2: Compare → /compare (placeholder)
- Tab 3: Partidas → /matches (placeholder)

Successful search pushes /player/:puuid within the Buscar tab. BottomNavBar stays visible. Other tabs preserve their state.

## BLoC Integration

Uses BlocListener (not BlocBuilder) because search success triggers a navigation action, not a UI rebuild. BlocBuilder is only used for the loading state on the search button.

## Files

Create:
- `lib/features/player_search/presentation/pages/player_search_page.dart`
- `lib/features/player_search/presentation/widgets/player_search_bar.dart`
- `lib/features/player_search/presentation/widgets/recent_search_row.dart`
- `lib/shared/widgets/app_bottom_nav_bar.dart`
- `lib/shared/widgets/scaffold_with_nav_bar.dart`

Modify:
- `lib/core/router/app_router.dart`

No changes to domain/, data/, or BLoC layers.

## Design Reference

Screen/PlayerSearch in `docs/pencil.dev/pencil-new.pen` (node ID: AJEJk)

### Visual specs (from .pen):
- SearchBar: height 48, cornerRadius 12, bg #14141A, border #2A2A34, icon search #3F3F46
- Recent row: avatar circle 40x40, player name 14px 600w, time 11px normal, tier badge rounded 4px
- Tier badge colors: CH=#DC2626, GM=#F59E0B, MA=#3B82F6
- BottomNav: 4 tabs, height 64, bg #14141A, active=#3B82F6, inactive=#71717A
- Section label: "BUSCAS RECENTES" 10px 600w letterSpacing 2

## Deferred

- Recent searches persistence (shared_preferences) — future task
- PlayerProfilePage — future task (placeholder for now)
