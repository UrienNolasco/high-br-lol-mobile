# Player Profile — Overview Tab Design

## Overview

Build the PlayerProfilePage with the Overview tab, replacing the current placeholder. The user arrives here directly after a successful player search (no intermediate processing screen). The page loads data in 2 phases for better perceived performance, and includes a polling banner that tracks match processing progress.

## Navigation Flow

```
Search (POST /players/search) -> PlayerProfilePage direto
```

- Remove `/search/player/:puuid/processing` route
- `/search/player/:puuid` points to `PlayerProfilePage`
- Back button returns to search

## Data Loading (2 Phases)

**Phase 1 — Header:**
- `GET /players/{puuid}` -> shows header (name, rank, tier, LP, W/L)
- Starts polling `GET /players/{puuid}/status` every 3s

**Phase 2 — Body (parallel):**
- `Future.wait` with 4 calls:
  - `GET /players/{puuid}/summary`
  - `GET /players/{puuid}/champions`
  - `GET /players/{puuid}/roles`
  - `GET /players/{puuid}/activity`
- Phase 2 triggers after Phase 1 completes

## BLoC Architecture

### PlayerProfileBloc (page-level, shared across future tabs)

- Loads player info from `/players/{puuid}`
- Manages `/status` polling (3s interval)
- When status = IDLE -> stops polling, hides banner
- States: `ProfileLoading`, `ProfileLoaded(player, processingStatus?)`, `ProfileError(message)`
- Events: `ProfileStarted(puuid)`, `ProfileStatusPolled`, `ProfileStatusStopped`

### PlayerOverviewBloc (Overview tab specific)

- Loads summary, champions, roles, activity in parallel via `Future.wait`
- States: `OverviewLoading`, `OverviewLoaded(summary, champions, roles, activity)`, `OverviewError(message)`
- Events: `OverviewStarted(puuid)`

## Widget Tree

```
PlayerProfilePage
  BlocProvider<PlayerProfileBloc>
  BlocProvider<PlayerOverviewBloc>
  Scaffold (bgPrimary)
    Column
      BackRow ("Perfil" + arrow_back)
      BlocBuilder<PlayerProfileBloc>
        Loading -> skeleton header
        Loaded -> ProfileHeader
          Avatar (56px circle, bgTertiary)
          Name "UrienMano#BR1" (18px 700w)
          TierBadge (CH #DC2626) + "CHALLENGER 1,234 LP" (#F59E0B)
          "150W 120L" (textSecondary) + "55.6%" (accent)
        ProcessingBanner (if status=UPDATING)
          sync icon + "Processando partidas... 5/20" (accent bg, white text)
      ProfileTabs (Overview active, Champions/Matches/Atividade placeholder)
      Expanded
        BlocBuilder<PlayerOverviewBloc>
          Loading -> skeleton body
          Loaded -> OverviewContent (SingleChildScrollView)
            STATS GERAIS (5 compact cards in horizontal row)
              Games (270) | WR (55.6% accent) | KDA (3.42 blue) | CS/m (7.8) | DPM (624)
            DISTRIBUICAO DE ROLES (horizontal bars in card)
              MID 142 58% | TOP 68 52% | JGL 35 49% | BOT 18 44%
            TOP CHAMPIONS (5 rows in card)
              icon + name + games + WR%
```

## Visual Specs (from .pen)

### ProfileHeader
- Avatar: 56x56, cornerRadius 28, bgTertiary
- Name: 18px 700w, textPrimary
- TierBadge: cornerRadius 4, padding [2, 8], text 11px 700w white
- Rank text: 12px 600w, #F59E0B (gold)
- WL text: 12px normal, textSecondary; WR: 12px 600w, accent

### ProcessingBanner
- Fill: accent (#3B82F6), opacity 0.9, padding [8, 16]
- Icon: sync 16px white
- Text: 12px 500w white

### ProfileTabs
- 4 tabs: Overview, Champions, Matches, Atividade
- Active: 13px 600w accent, 2px underline accent
- Inactive: 13px 500w textSecondary, no underline
- Bottom border: 1px border color

### Stats Gerais
- Section label: "STATS GERAIS" 10px 600w textSecondary, letterSpacing 2
- Cards: cornerRadius 8, bgSecondary, padding [10, 8], vertical layout, gap 2
- Value: 18px 600w (color varies: accent for WR, #60A5FA for KDA, textPrimary for others)
- Label: 9px 500w textSecondary

### Role Distribution
- Section label: "DISTRIBUICAO DE ROLES" 10px 600w textSecondary, letterSpacing 2
- Container: cornerRadius 8, bgSecondary, padding 12, gap 8
- Role tag: 11px 600w textSecondary, fixed width 32
- Bar: cornerRadius 4, bgTertiary bg, accent fill (opacity varies by rank)
- Info: 10px 500w textSecondary, right aligned, fixed width 60

### Top Champions
- Section label: "TOP CHAMPIONS" 10px 600w textSecondary, letterSpacing 2
- Container: cornerRadius 8, bgSecondary, padding 10, gap 6
- Row: padding 4, gap 10
- Icon: 28x28, cornerRadius 6, bgTertiary
- Name: 13px 600w textPrimary, fill_container
- Games: 12px 500w textSecondary
- WR: 12px 600w (accent if >55%, #60A5FA if >50%, textPrimary if =50%, loss if <50%)

## Data Layer

### Entities
- `PlayerProfile` (puuid, gameName, tagLine, profileIconId, tier, rank, leaguePoints, wins, losses)
- `PlayerSummary` (games, winRate, kda, csPerMin, dpm)
- `PlayerChampion` (name, games, winRate, iconId)
- `PlayerRole` (role, games, winRate)
- `PlayerActivity` (data for heatmap — stored for future Atividade tab)
- Reuses `ProcessingStatus` from player_search

### Models
- `PlayerProfileModel` extends `PlayerProfile`, fromJson
- `PlayerSummaryModel` extends `PlayerSummary`, fromJson
- `PlayerChampionModel` extends `PlayerChampion`, fromJson
- `PlayerRoleModel` extends `PlayerRole`, fromJson
- `PlayerActivityModel` extends `PlayerActivity`, fromJson

### DataSource
- `PlayerProfileRemoteDataSource` with methods:
  - `getPlayerProfile(puuid)` -> GET /players/{puuid}
  - `getPlayerSummary(puuid)` -> GET /players/{puuid}/summary
  - `getPlayerChampions(puuid)` -> GET /players/{puuid}/champions
  - `getPlayerRoles(puuid)` -> GET /players/{puuid}/roles
  - `getPlayerActivity(puuid)` -> GET /players/{puuid}/activity
  - `getPlayerStatus(puuid)` -> GET /players/{puuid}/status

### Repository
- `PlayerProfileRepository` (abstract)
  - getPlayerProfile, getPlayerSummary, getPlayerChampions, getPlayerRoles, getPlayerActivity, getPlayerStatus
- `PlayerProfileRepositoryImpl` delegates to datasource

### UseCases
- `GetPlayerProfile(puuid)` -> calls repository.getPlayerProfile
- `GetPlayerOverview(puuid)` -> Future.wait on summary + champions + roles + activity, returns composite result
- `GetPlayerStatus(puuid)` -> calls repository.getPlayerStatus (for polling)

## Files

### Create
```
lib/features/player_profile/
  data/
    datasources/player_profile_remote_datasource.dart
    models/
      player_profile_model.dart
      player_summary_model.dart
      player_champion_model.dart
      player_role_model.dart
      player_activity_model.dart
    repositories/player_profile_repository_impl.dart
  domain/
    entities/
      player_profile.dart
      player_summary.dart
      player_champion.dart
      player_role.dart
      player_activity.dart
    repositories/player_profile_repository.dart
    usecases/
      get_player_profile.dart
      get_player_overview.dart
      get_player_status.dart
  presentation/
    bloc/
      player_profile_bloc.dart
      player_profile_event.dart
      player_profile_state.dart
      player_overview_bloc.dart
      player_overview_event.dart
      player_overview_state.dart
    pages/player_profile_page.dart
    widgets/
      profile_header.dart
      processing_banner.dart
      profile_tabs.dart
      overview_content.dart
      general_stats_row.dart
      role_distribution_card.dart
      top_champions_card.dart
```

### Modify
- `lib/core/router/app_router.dart` — remove processing route, point to PlayerProfilePage
- `lib/features/player_search/presentation/pages/player_search_page.dart` — navigate directly to `/search/player/{puuid}`

## Deferred
- Champions tab, Matches tab, Atividade tab — future iterations
- Profile icon image loading (cached_network_image) — future
- Recent searches persistence — future
- Activity heatmap visualization — future (entity fetched but not displayed)
