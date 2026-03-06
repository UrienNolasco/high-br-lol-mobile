# Processing Status Screen Design

## Overview

Intermediate screen between player search and player profile. After a successful search, the app navigates here and polls `/players/{puuid}/status` every 2 seconds to show match processing progress. When all matches are processed (status IDLE), navigates automatically to the player profile.

## Backend Endpoint

`GET /api/v1/players/{puuid}/status`

Response:
```json
{
  "status": "IDLE" | "UPDATING" | "ERROR",
  "matchesProcessed": 20,
  "matchesTotal": 20,
  "message": "All matches processed"
}
```

- `IDLE` — all matches processed, ready to view profile
- `UPDATING` — matches still being processed by the worker
- `ERROR` — failed to fetch match status from Riot API

## Flow

```
Search → PlayerSearchSuccess → Processing Status (polling) → IDLE → Player Profile
```

## Components

```
ProcessingStatusPage (StatelessWidget)
├── BlocProvider (injects ProcessingStatusBloc)
└── ProcessingStatusView
    └── Scaffold (bgPrimary)
        └── SafeArea > Column (center)
            ├── Player info (gameName#tagLine)
            ├── CircularProgressIndicator or check/error icon
            ├── Progress text ("Processando 5/20 partidas...")
            ├── LinearProgressIndicator (matchesProcessed / matchesTotal)
            └── [if ERROR] Two buttons: "Tentar novamente" + "Voltar"
```

## BLoC

Lives inside `player_search` feature (part of the search flow).

- **Events:** StartPolling(puuid), StopPolling, RetryPolling
- **States:** ProcessingStatusLoading, ProcessingStatusUpdating(matchesProcessed, matchesTotal), ProcessingStatusComplete(puuid), ProcessingStatusError(message)
- Timer.periodic(2s) polls the endpoint
- IDLE → emits Complete → BlocListener navigates to profile
- ERROR → emits Error → shows retry/back buttons
- Network errors during polling → silent retry on next cycle
- Timer cancelled on close()

## Data Layer

- **Entity:** ProcessingStatus (status, matchesProcessed, matchesTotal, message)
- **Model:** ProcessingStatusModel extends entity, fromJson factory
- **Datasource:** getPlayerStatus(puuid) added to PlayerSearchRemoteDataSource
- **Repository:** getPlayerStatus(puuid) added to PlayerSearchRepository
- **UseCase:** GetPlayerStatus(puuid)

## Navigation

- Route: `/search/player/:puuid/processing` (sub-route within Buscar tab)
- After successful search → navigate to processing (not profile directly)
- When complete → navigate to `/search/player/:puuid` (profile placeholder)

## Error Handling

- ERROR status → show message + "Tentar novamente" (restarts polling) + "Voltar" (back to search)
- Network error during poll → silent retry on next 2s cycle
- Endpoint timeout → same as network error (silent retry)

## Endpoint Addition

Add to api_endpoints.dart:
```dart
static String playerStatus(String puuid) => '/players/$puuid/status';
```

## Deferred

- PlayerProfilePage — future task (placeholder for now)
- Deep sync status (separate endpoint /sync-status) — future feature
