# Recent Searches — Design

## Overview

Make the recent searches list functional in PlayerSearchPage. Searches are persisted locally using `shared_preferences` (like browser localStorage). Each row is clickable and navigates directly to `/search/player/{puuid}` without re-calling the backend.

## Entity

```
RecentSearch {
  puuid: String
  gameName: String
  tagLine: String
  tier: String
  searchedAt: DateTime
}
```

## Storage

- `shared_preferences` with key `recent_searches`
- Value: JSON-encoded `List<Map>`
- Max 10 entries. Adding an 11th removes the oldest
- If player already exists (same puuid), move to top and update `searchedAt` + `tier`

## Flow

1. **Save**: On `PlayerSearchSuccess` in `BlocListener`, save the search to local storage
2. **Load**: When `PlayerSearchPage` opens, BLoC loads the list from storage
3. **Tap**: `context.go('/search/player/$puuid')` — direct navigation, no POST

## Architecture

All code stays within `player_search` feature:

- `domain/entities/recent_search.dart` — entity
- `data/models/recent_search_model.dart` — fromJson/toJson
- `data/datasources/recent_searches_local_datasource.dart` — reads/writes SharedPreferences
- `PlayerSearchBloc` — new events: `RecentSearchesLoaded`, `RecentSearchAdded(search)`
- `PlayerSearchState` — adds `List<RecentSearch> recentSearches` field
- `PlayerSearchPage` — replaces static rows with dynamic `ListView.builder`

## Widget

Reuses existing `RecentSearchRow` widget (already has `onTap` callback). Passes dynamic data and `() => context.go('/search/player/$puuid')`.

The `timeAgo` string is computed from `searchedAt` (e.g., "ha 2 min", "ha 1 hora", "ha 3 dias").

## Dependencies

- Add `shared_preferences` to pubspec.yaml
