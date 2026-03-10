# Deep-Sync Banner Design

## Overview

Refactor the `ProcessingBanner` widget to never disappear. Instead of hiding when processing completes, it transitions to a clickable "Buscar mais partidas" button that triggers a deep-sync of up to 100 ranked matches.

## Banner States

The banner cycles through 3 visual states:

```
Ready → (tap) → Triggering → Processing → Ready → ...
```

| State | Icon | Text | Clickable |
|-------|------|------|-----------|
| **Processing** | `Icons.sync` (rotating) | "Processando partidas... X/Y" | No |
| **Ready** | `Icons.manage_search` (static) | "Buscar mais partidas" | Yes (chevron `>` at end) |
| **Triggering** | `Icons.sync` (rotating) | "Iniciando busca..." | No |

All states share the same container style: full-width, `AppColors.accent` with alpha 0.9.

## Backend Endpoints

Two separate endpoint pairs for two separate flows:

### Initial search processing
- Status: `GET /api/v1/players/:puuid/status`
- Returns: `{ status: 'IDLE' | 'UPDATING', matchesProcessed, matchesTotal, message }`

### Deep-sync
- Trigger: `POST /api/v1/players/:puuid/sync`
- Status: `GET /api/v1/players/:puuid/sync-status`
- Returns: `{ puuid, status: 'IDLE' | 'SYNCING' | 'DONE' | 'ERROR', matchesProcessed, matchesTotal, startedAt, message }`

## Polling Strategy

Polling is NOT continuous. It starts and stops based on context:

1. **Initial search**: Polling on `/status` every 3s. Stops when `status == IDLE`. Banner transitions to **Ready**.
2. **Deep-sync triggered**: New polling on `/sync-status` every 3s. Stops when `status == DONE` or `status == IDLE`. Banner transitions to **Ready**.
3. **While Ready**: No polling running.

## Full Flow

1. User opens profile -> polling starts on `/status`
2. Matches being processed -> banner shows **Processing** with progress from `/status`
3. Processing completes (`IDLE`) -> polling stops -> banner shows **Ready**
4. User taps "Buscar mais partidas" -> banner shows **Triggering** -> `POST /sync` is called
5. Backend responds successfully -> start polling on `/sync-status` -> banner shows **Processing** with progress from `/sync-status`
6. Deep-sync completes (`DONE`) -> polling stops -> banner shows **Ready**
7. If `POST /sync` fails -> show snackbar with error message -> banner returns to **Ready**

## BLoC Changes (`PlayerProfileBloc`)

### New Event
- `DeepSyncRequested` — triggers `POST /sync`, starts sync-status polling

### State Changes
- `ProfileLoaded` always includes a `bannerState` (processing/ready/triggering) instead of nullable `processingStatus`
- When initial polling detects `IDLE`, emit state with banner in `ready` mode (not `null`)

### Polling Logic
- Reuse the existing timer mechanism
- When switching from initial-status to sync-status, swap which endpoint the timer calls
- Timer always cancels on idle/done, restarts on deep-sync trigger

## Error Handling

- `POST /sync` failure: Show snackbar via the page, banner returns to **Ready**
- `/sync-status` returns `ERROR`: Stop polling, show snackbar, banner returns to **Ready**

## Files Impacted

| File | Change |
|------|--------|
| `processing_banner.dart` | Add Ready and Triggering states, make tappable with `onTap` callback, add chevron icon for Ready state |
| `player_profile_bloc.dart` | New `DeepSyncRequested` event, dual polling logic (status vs sync-status), banner always emitted (never null) |
| `processing_status.dart` | Add new enum values or create a `BannerState` enum (ready, processing, triggering) |
| `player_profile_page.dart` | Remove `isProcessing` conditional — banner always visible. Wire `onTap` to dispatch `DeepSyncRequested`. Listen for errors to show snackbar |
| Datasource / Repository | New methods: `triggerDeepSync(puuid)` and `getDeepSyncStatus(puuid)` |
| Use cases | New: `TriggerDeepSync` and `GetDeepSyncStatus` |
