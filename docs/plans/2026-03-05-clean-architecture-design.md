# High BR LoL Mobile - Architecture Design

## Overview

Mobile app for League of Legends statistics targeting Brazilian players. Consumes a NestJS REST API (`high-br-lol-graph`) that provides champion stats, player profiles, match history, timelines, and player comparison analytics.

## Architecture

**Pattern:** Clean Architecture + BLoC (feature-first)

### Folder Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── di/
│   │   └── injection.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   └── api_exception.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   ├── router/
│   │   └── app_router.dart
│   └── constants/
│       └── app_constants.dart
├── features/
│   ├── player_search/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── player_search_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── player_search_result_model.dart
│   │   │   └── repositories/
│   │   │       └── player_search_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── player_search_result.dart
│   │   │   ├── repositories/
│   │   │   │   └── player_search_repository.dart
│   │   │   └── usecases/
│   │   │       └── search_player.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── player_search_bloc.dart
│   │       │   ├── player_search_event.dart
│   │       │   └── player_search_state.dart
│   │       ├── pages/
│   │       │   └── player_search_page.dart
│   │       └── widgets/
│   │           └── player_search_bar.dart
│   ├── player_profile/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/ ...
│   ├── match_history/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/ ...
│   ├── match_details/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/ ...
│   ├── champion_stats/
│   │   ├── data/ ...
│   │   ├── domain/ ...
│   │   └── presentation/ ...
│   └── player_compare/
│       ├── data/ ...
│       ├── domain/ ...
│       └── presentation/ ...
└── shared/
    └── widgets/
        ├── loading_indicator.dart
        └── error_display.dart
```

### Data Flow (per feature)

```
UI (Page/Widget)
    ↓ dispatch event
BLoC (receives event, emits state)
    ↓ calls
UseCase (pure business logic)
    ↓ calls
Repository (abstract contract in domain/)
    ↓ implemented by
RepositoryImpl (in data/, orchestrates datasources)
    ↓ calls
RemoteDataSource (HTTP request via Dio)
    ↓ returns
Model (DTO with fromJson) → converts → Entity (pure domain object)
```

## Features

| Feature | API Endpoints Consumed |
|---------|----------------------|
| player_search | `POST /api/v1/players/search` |
| player_profile | `GET /api/v1/players/:puuid`, `/summary`, `/champions`, `/roles`, `/activity` |
| match_history | `GET /api/v1/players/:puuid/matches/page` |
| match_details | `GET /api/v1/matches/:matchId`, `/timeline/gold`, `/timeline/events`, `/builds`, `/performance/:puuid` |
| champion_stats | `GET /api/v1/stats/champions`, `/api/v1/champions/current-patch` |
| player_compare | `GET /api/v1/analytics/compare?heroPuuid=...&villainPuuid=...` |

## Dependencies

### Runtime
- `flutter_bloc` - State management (BLoC/Cubit)
- `equatable` - Value equality for states/events
- `dio` - HTTP client with interceptors
- `get_it` - Service locator (DI)
- `injectable` - Code generation for get_it
- `go_router` - Declarative routing
- `freezed_annotation` - Immutable data classes annotations
- `json_annotation` - JSON serialization annotations
- `cached_network_image` - Image caching (champion splash arts)
- `shared_preferences` - Simple local key-value storage

### Dev
- `flutter_lints` - Lint rules
- `build_runner` - Code generation runner
- `freezed` - Generates immutable classes, copyWith, unions
- `json_serializable` - Generates fromJson/toJson
- `injectable_generator` - Generates get_it setup
- `bloc_test` - BLoC testing helpers
- `mocktail` - Mocking without code generation

## Theme

- **Mode:** Dark only
- **Style:** Clean/modern, neutral dark tones
- **Accent:** Blue or purple
- **Approach:** Centralized in `core/theme/` with AppColors, AppTypography, AppTheme

## Navigation

### Bottom Navigation (3 tabs)

| Tab | Icon | Root Page |
|-----|------|-----------|
| Buscar | search | PlayerSearchPage |
| Champions | shield | ChampionStatsPage |
| Comparar | compare_arrows | PlayerComparePage |

### Routes

```
/                           → PlayerSearchPage
/player/:puuid              → PlayerProfilePage
/player/:puuid/champions    → PlayerChampionsPage
/player/:puuid/matches      → MatchHistoryPage
/match/:matchId             → MatchDetailsPage
/champions                  → ChampionStatsPage
/compare                    → PlayerComparePage
```

### Navigation model
Each tab maintains its own navigation stack. Push/pop within a tab preserves state of other tabs.

## Error Handling

### BLoC States (per feature)
- `Initial` - Screen just opened
- `Loading` - API call in progress
- `Success` - Data received
- `Failure` - Error with typed message

### Error Mapping (Dio Interceptor)

| HTTP Status | App Error | User Message |
|-------------|-----------|-------------|
| 404 | PlayerNotFound | "Jogador nao encontrado." |
| 429 | RateLimited | "Muitas buscas. Tente novamente em alguns segundos." |
| 500 | ServerError | "Erro no servidor. Tente novamente." |
| No internet | NetworkError | "Sem conexao com a internet." |
| Timeout | TimeoutError | "A requisicao demorou demais." |

## Testing Strategy

| Layer | What to test | Tools |
|-------|-------------|-------|
| Unit | UseCases, Repositories, Models (fromJson) | flutter_test + mocktail |
| BLoC | Event → State transitions | bloc_test |
| Widget | Screen renders correctly per state | flutter_test + mocktail |
