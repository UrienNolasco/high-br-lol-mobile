# Recent Searches Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the recent searches list functional — persist searches locally with `shared_preferences`, display them dynamically, and navigate directly to the player profile on tap.

**Architecture:** New `RecentSearch` entity + model with toJson/fromJson. `RecentSearchesLocalDataSource` wraps `SharedPreferences`. `PlayerSearchBloc` gains new events to load/save recent searches. Page replaces static rows with dynamic `ListView.builder`. Tier info is optional (not available from search endpoint).

**Tech Stack:** shared_preferences, flutter_bloc (existing), equatable, injectable

---

### Task 1: Add shared_preferences dependency

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Add the dependency**

Add `shared_preferences: ^2.5.3` under `dependencies` in `pubspec.yaml`, after `json_annotation`:

```yaml
  shared_preferences: ^2.5.3
```

**Step 2: Install**

Run: `flutter pub get`
Expected: No errors

---

### Task 2: RecentSearch entity + model + tests

**Files:**
- Create: `lib/features/player_search/domain/entities/recent_search.dart`
- Create: `lib/features/player_search/data/models/recent_search_model.dart`
- Create: `test/features/player_search/data/models/recent_search_model_test.dart`

**Step 1: Create RecentSearch entity**

```dart
import 'package:equatable/equatable.dart';

class RecentSearch extends Equatable {
  const RecentSearch({
    required this.puuid,
    required this.gameName,
    required this.tagLine,
    this.tier,
    required this.searchedAt,
  });

  final String puuid;
  final String gameName;
  final String tagLine;
  final String? tier;
  final DateTime searchedAt;

  @override
  List<Object?> get props => [puuid, gameName, tagLine, tier, searchedAt];
}
```

**Step 2: Create RecentSearchModel with fromJson/toJson**

```dart
import '../../domain/entities/recent_search.dart';

class RecentSearchModel extends RecentSearch {
  const RecentSearchModel({
    required super.puuid,
    required super.gameName,
    required super.tagLine,
    super.tier,
    required super.searchedAt,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      puuid: json['puuid'] as String,
      gameName: json['gameName'] as String,
      tagLine: json['tagLine'] as String,
      tier: json['tier'] as String?,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'puuid': puuid,
      'gameName': gameName,
      'tagLine': tagLine,
      'tier': tier,
      'searchedAt': searchedAt.toIso8601String(),
    };
  }

  factory RecentSearchModel.fromEntity(RecentSearch entity) {
    return RecentSearchModel(
      puuid: entity.puuid,
      gameName: entity.gameName,
      tagLine: entity.tagLine,
      tier: entity.tier,
      searchedAt: entity.searchedAt,
    );
  }
}
```

**Step 3: Write tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/recent_search_model.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/recent_search.dart';

void main() {
  final tNow = DateTime(2026, 3, 6, 12, 0);

  final tModel = RecentSearchModel(
    puuid: 'test-puuid',
    gameName: 'UrienMano',
    tagLine: 'BR1',
    tier: 'CHALLENGER',
    searchedAt: tNow,
  );

  final tJson = {
    'puuid': 'test-puuid',
    'gameName': 'UrienMano',
    'tagLine': 'BR1',
    'tier': 'CHALLENGER',
    'searchedAt': '2026-03-06T12:00:00.000',
  };

  test('should be a subclass of RecentSearch', () {
    expect(tModel, isA<RecentSearch>());
  });

  test('should return a valid model from JSON', () {
    final result = RecentSearchModel.fromJson(tJson);
    expect(result.puuid, 'test-puuid');
    expect(result.gameName, 'UrienMano');
    expect(result.tagLine, 'BR1');
    expect(result.tier, 'CHALLENGER');
    expect(result.searchedAt, tNow);
  });

  test('should produce valid JSON from toJson', () {
    final result = tModel.toJson();
    expect(result['puuid'], 'test-puuid');
    expect(result['gameName'], 'UrienMano');
    expect(result['tier'], 'CHALLENGER');
    expect(result['searchedAt'], '2026-03-06T12:00:00.000');
  });

  test('should handle null tier in JSON', () {
    final jsonWithoutTier = {
      'puuid': 'test-puuid',
      'gameName': 'UrienMano',
      'tagLine': 'BR1',
      'tier': null,
      'searchedAt': '2026-03-06T12:00:00.000',
    };
    final result = RecentSearchModel.fromJson(jsonWithoutTier);
    expect(result.tier, isNull);
  });

  test('should create model from entity', () {
    final entity = RecentSearch(
      puuid: 'test-puuid',
      gameName: 'UrienMano',
      tagLine: 'BR1',
      tier: 'CHALLENGER',
      searchedAt: tNow,
    );
    final result = RecentSearchModel.fromEntity(entity);
    expect(result.puuid, entity.puuid);
    expect(result.tier, entity.tier);
  });
}
```

**Step 4: Run tests**

Run: `flutter test test/features/player_search/data/models/recent_search_model_test.dart`
Expected: 5 tests pass

---

### Task 3: RecentSearchesLocalDataSource + tests

**Files:**
- Create: `lib/features/player_search/data/datasources/recent_searches_local_datasource.dart`
- Create: `test/features/player_search/data/datasources/recent_searches_local_datasource_test.dart`

**Step 1: Create the datasource**

```dart
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_search_model.dart';

@lazySingleton
class RecentSearchesLocalDataSource {
  RecentSearchesLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'recent_searches';
  static const _maxItems = 10;

  List<RecentSearchModel> getRecentSearches() {
    final jsonString = _prefs.getString(_key);
    if (jsonString == null) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => RecentSearchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSearch(RecentSearchModel search) async {
    final searches = getRecentSearches();
    searches.removeWhere((s) => s.puuid == search.puuid);
    searches.insert(0, search);
    if (searches.length > _maxItems) {
      searches.removeRange(_maxItems, searches.length);
    }
    final jsonString = jsonEncode(searches.map((s) => s.toJson()).toList());
    await _prefs.setString(_key, jsonString);
  }
}
```

**Step 2: Register SharedPreferences in DI**

Create: `lib/core/di/shared_preferences_module.dart`

```dart
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class SharedPreferencesModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
```

**Step 3: Update injection.dart to use async init**

Modify `lib/core/di/injection.dart` — change `configureDependencies` to async:

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => getIt.init();
```

**Step 4: Update main.dart to await DI**

In `lib/main.dart`, change:
```dart
configureDependencies();
```
To:
```dart
await configureDependencies();
```

Make sure `main()` is `async` and `WidgetsFlutterBinding.ensureInitialized()` is called before it.

**Step 5: Write tests**

```dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:high_br_lol_mobile/features/player_search/data/datasources/recent_searches_local_datasource.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/recent_search_model.dart';

void main() {
  late RecentSearchesLocalDataSource datasource;
  final tNow = DateTime(2026, 3, 6, 12, 0);

  final tSearch = RecentSearchModel(
    puuid: 'puuid-1',
    gameName: 'UrienMano',
    tagLine: 'BR1',
    tier: 'CHALLENGER',
    searchedAt: tNow,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    datasource = RecentSearchesLocalDataSource(prefs);
  });

  test('should return empty list when no data saved', () {
    final result = datasource.getRecentSearches();
    expect(result, isEmpty);
  });

  test('should save and retrieve a search', () async {
    await datasource.saveSearch(tSearch);
    final result = datasource.getRecentSearches();
    expect(result.length, 1);
    expect(result.first.puuid, 'puuid-1');
    expect(result.first.gameName, 'UrienMano');
  });

  test('should move duplicate puuid to top', () async {
    final search2 = RecentSearchModel(
      puuid: 'puuid-2',
      gameName: 'Faker',
      tagLine: 'KR1',
      searchedAt: tNow,
    );
    await datasource.saveSearch(tSearch);
    await datasource.saveSearch(search2);

    final updated = RecentSearchModel(
      puuid: 'puuid-1',
      gameName: 'UrienMano',
      tagLine: 'BR1',
      tier: 'CHALLENGER',
      searchedAt: DateTime(2026, 3, 6, 13, 0),
    );
    await datasource.saveSearch(updated);

    final result = datasource.getRecentSearches();
    expect(result.length, 2);
    expect(result.first.puuid, 'puuid-1');
    expect(result[1].puuid, 'puuid-2');
  });

  test('should limit to 10 items', () async {
    for (var i = 0; i < 12; i++) {
      await datasource.saveSearch(RecentSearchModel(
        puuid: 'puuid-$i',
        gameName: 'Player$i',
        tagLine: 'BR1',
        searchedAt: tNow.add(Duration(minutes: i)),
      ));
    }
    final result = datasource.getRecentSearches();
    expect(result.length, 10);
    expect(result.first.puuid, 'puuid-11');
  });
}
```

**Step 6: Run tests**

Run: `flutter test test/features/player_search/data/datasources/recent_searches_local_datasource_test.dart`
Expected: 4 tests pass

---

### Task 4: Update PlayerSearchBloc (events, state, logic)

**Files:**
- Modify: `lib/features/player_search/presentation/bloc/player_search_event.dart`
- Modify: `lib/features/player_search/presentation/bloc/player_search_state.dart`
- Modify: `lib/features/player_search/presentation/bloc/player_search_bloc.dart`

**Step 1: Add new events**

Replace `lib/features/player_search/presentation/bloc/player_search_event.dart` with:

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/recent_search.dart';

sealed class PlayerSearchEvent extends Equatable {
  const PlayerSearchEvent();

  @override
  List<Object?> get props => [];
}

class PlayerSearchSubmitted extends PlayerSearchEvent {
  const PlayerSearchSubmitted({
    required this.gameName,
    required this.tagLine,
  });

  final String gameName;
  final String tagLine;

  @override
  List<Object?> get props => [gameName, tagLine];
}

class RecentSearchesLoaded extends PlayerSearchEvent {
  const RecentSearchesLoaded();
}

class RecentSearchAdded extends PlayerSearchEvent {
  const RecentSearchAdded(this.search);

  final RecentSearch search;

  @override
  List<Object?> get props => [search];
}
```

**Step 2: Add recentSearches to state**

Replace `lib/features/player_search/presentation/bloc/player_search_state.dart` with:

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/player_search_result.dart';
import '../../domain/entities/recent_search.dart';

sealed class PlayerSearchState extends Equatable {
  const PlayerSearchState({this.recentSearches = const []});

  final List<RecentSearch> recentSearches;

  @override
  List<Object?> get props => [recentSearches];
}

class PlayerSearchInitial extends PlayerSearchState {
  const PlayerSearchInitial({super.recentSearches});
}

class PlayerSearchLoading extends PlayerSearchState {
  const PlayerSearchLoading({super.recentSearches});
}

class PlayerSearchSuccess extends PlayerSearchState {
  const PlayerSearchSuccess(this.result, {super.recentSearches});

  final PlayerSearchResult result;

  @override
  List<Object?> get props => [result, recentSearches];
}

class PlayerSearchFailure extends PlayerSearchState {
  const PlayerSearchFailure(this.message, {super.recentSearches});

  final String message;

  @override
  List<Object?> get props => [message, recentSearches];
}
```

**Step 3: Update the BLoC**

Replace `lib/features/player_search/presentation/bloc/player_search_bloc.dart` with:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/datasources/recent_searches_local_datasource.dart';
import '../../data/models/recent_search_model.dart';
import '../../domain/usecases/search_player.dart';
import 'player_search_event.dart';
import 'player_search_state.dart';

@injectable
class PlayerSearchBloc extends Bloc<PlayerSearchEvent, PlayerSearchState> {
  PlayerSearchBloc(this._searchPlayer, this._recentSearches)
      : super(const PlayerSearchInitial()) {
    on<PlayerSearchSubmitted>(_onSearchSubmitted);
    on<RecentSearchesLoaded>(_onRecentSearchesLoaded);
    on<RecentSearchAdded>(_onRecentSearchAdded);
  }

  final SearchPlayer _searchPlayer;
  final RecentSearchesLocalDataSource _recentSearches;

  void _onRecentSearchesLoaded(
    RecentSearchesLoaded event,
    Emitter<PlayerSearchState> emit,
  ) {
    final searches = _recentSearches.getRecentSearches();
    emit(PlayerSearchInitial(recentSearches: searches));
  }

  Future<void> _onSearchSubmitted(
    PlayerSearchSubmitted event,
    Emitter<PlayerSearchState> emit,
  ) async {
    emit(PlayerSearchLoading(recentSearches: state.recentSearches));
    try {
      final result = await _searchPlayer(
        gameName: event.gameName,
        tagLine: event.tagLine,
      );

      final search = RecentSearchModel(
        puuid: result.puuid,
        gameName: result.gameName,
        tagLine: result.tagLine,
        searchedAt: DateTime.now(),
      );
      await _recentSearches.saveSearch(search);

      final updated = _recentSearches.getRecentSearches();
      emit(PlayerSearchSuccess(result, recentSearches: updated));
    } on ApiException catch (e) {
      emit(PlayerSearchFailure(e.message, recentSearches: state.recentSearches));
    } catch (_) {
      emit(PlayerSearchFailure(
        'Erro inesperado. Tente novamente.',
        recentSearches: state.recentSearches,
      ));
    }
  }

  Future<void> _onRecentSearchAdded(
    RecentSearchAdded event,
    Emitter<PlayerSearchState> emit,
  ) async {
    final model = RecentSearchModel.fromEntity(event.search);
    await _recentSearches.saveSearch(model);
    final updated = _recentSearches.getRecentSearches();
    emit(PlayerSearchInitial(recentSearches: updated));
  }
}
```

**Step 4: Run analyzer**

Run: `flutter analyze`
Expected: No issues

---

### Task 5: Regenerate DI + Update main.dart

**Files:**
- Modify: `lib/main.dart`
- Auto-generated: `lib/core/di/injection.config.dart`

**Step 1: Create SharedPreferences module**

Already specified in Task 3, Step 2.

**Step 2: Regenerate DI**

Run: `dart run build_runner build --delete-conflicting-outputs`

**Step 3: Update main.dart**

Make sure `main.dart` has:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const App());
}
```

**Step 4: Run analyzer**

Run: `flutter analyze`
Expected: No issues

---

### Task 6: Update PlayerSearchPage (dynamic list)

**Files:**
- Modify: `lib/features/player_search/presentation/pages/player_search_page.dart`

**Step 1: Update the page**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/recent_search.dart';
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
                        separatorBuilder: (_, __) => const Divider(height: 1),
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
      'CHALLENGER' => const Color(0xFFDC2626),
      'GRANDMASTER' => const Color(0xFFDC2626),
      'MASTER' => const Color(0xFFA855F7),
      'DIAMOND' => const Color(0xFF3B82F6),
      'EMERALD' => const Color(0xFF22C55E),
      'PLATINUM' => const Color(0xFF06B6D4),
      'GOLD' => const Color(0xFFF59E0B),
      'SILVER' => const Color(0xFF7A8599),
      'BRONZE' => const Color(0xFFCD7F32),
      'IRON' => const Color(0xFF3D4654),
      _ => AppColors.textSecondary,
    };
  }
}
```

**Step 2: Run analyzer**

Run: `flutter analyze`
Expected: No issues

---

### Task 7: Update existing tests

**Files:**
- Modify: `test/features/player_search/presentation/bloc/player_search_bloc_test.dart`

**Step 1: Update tests to inject RecentSearchesLocalDataSource mock**

The `PlayerSearchBloc` constructor now takes a second parameter. Update the test file to mock `RecentSearchesLocalDataSource` and pass it to the bloc.

Add mock:
```dart
class MockRecentSearchesLocalDataSource extends Mock
    implements RecentSearchesLocalDataSource {}
```

In setUp:
```dart
late MockRecentSearchesLocalDataSource mockRecentSearches;
mockRecentSearches = MockRecentSearchesLocalDataSource();
when(() => mockRecentSearches.getRecentSearches()).thenReturn([]);
when(() => mockRecentSearches.saveSearch(any())).thenAnswer((_) async {});
```

Update bloc creation:
```dart
PlayerSearchBloc(mockSearchPlayer, mockRecentSearches)
```

Update `expect` calls to account for `recentSearches` field in states — the states now carry `recentSearches: []` by default so equality should still work.

**Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass

---

### Task 8: Full Verification

**Step 1: Run analyzer**

Run: `flutter analyze`
Expected: No issues

**Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass (existing + new model tests + datasource tests)

**Step 3: Verify file structure**

Run: `find lib/features/player_search -type f | sort`
Expected to include the new files:
```
lib/features/player_search/data/datasources/recent_searches_local_datasource.dart
lib/features/player_search/data/models/recent_search_model.dart
lib/features/player_search/domain/entities/recent_search.dart
```

And:
```
lib/core/di/shared_preferences_module.dart
```
