# Clean Architecture + BLoC Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Scaffold the Flutter app with Clean Architecture + BLoC, including the complete player_search feature (domain + data + BLoC layers) as a working reference. Stops before UI/screens to allow the developer to learn incrementally.

**Architecture:** Clean Architecture with 3 layers per feature (data/domain/presentation). BLoC for state management. get_it + injectable for DI. go_router for navigation. Dio for HTTP.

**Tech Stack:** Flutter 3.41.4, Dart 3.11.1, flutter_bloc, dio, get_it + injectable, go_router, equatable

**Design Reference:** `docs/pencil.dev/pencil-new.pen` — 8 screens designed with JetBrains Mono font, dark navy theme, blue accent.

---

### Task 1: Update dependencies

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Replace pubspec.yaml with production dependencies**

```yaml
name: high_br_lol_mobile
description: "High BR LoL - League of Legends stats for Brazilian players."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.11.1

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
  dio: ^5.8.0+1
  get_it: ^8.0.3
  injectable: ^2.5.0
  go_router: ^14.8.1
  json_annotation: ^4.9.0
  cached_network_image: ^3.4.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  build_runner: ^2.4.15
  json_serializable: ^6.9.5
  injectable_generator: ^2.7.0
  bloc_test: ^9.1.8
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
  fonts:
    - family: JetBrainsMono
      fonts:
        - asset: assets/fonts/JetBrainsMono-Regular.ttf
        - asset: assets/fonts/JetBrainsMono-Medium.ttf
          weight: 500
        - asset: assets/fonts/JetBrainsMono-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/JetBrainsMono-Bold.ttf
          weight: 700
```

> Note: Download JetBrains Mono from https://www.jetbrains.com/lp/mono/ and place the .ttf files in `assets/fonts/`.

**Step 2: Install dependencies**

Run: `flutter pub get`
Expected: "Got dependencies!" with no errors

**Hora do commit** — adicionamos todas as dependencias do projeto e a configuracao da font JetBrains Mono.

---

### Task 2: Core - Constants

**Files:**
- Create: `lib/core/constants/app_constants.dart`

**Step 1: Create constants file**

```dart
abstract final class AppConstants {
  static const String appName = 'High BR LoL';
  static const String apiBaseUrl = 'http://10.0.2.2:3000/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
```

> `10.0.2.2` is the Android emulator alias for host machine's localhost. For iOS simulator, use `127.0.0.1`. We will make this configurable later via environment.

**Hora do commit** — adicionamos as constantes do app (nome, URL da API, timeouts).

---

### Task 3: Core - Theme (based on .pen design)

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_typography.dart`
- Create: `lib/core/theme/app_theme.dart`

**Step 1: Create color palette (extracted from the .pen file variables)**

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const Color bgPrimary = Color(0xFF0A0E13);
  static const Color bgSecondary = Color(0xFF131920);
  static const Color bgTertiary = Color(0xFF1C2430);
  static const Color surface = Color(0xFF252D3A);

  // Border
  static const Color border = Color(0xFF1E293B);

  // Accent
  static const Color accent = Color(0xFF3B82F6);

  // Text
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF7A8599);
  static const Color textMuted = Color(0xFF3D4654);

  // Semantic
  static const Color win = Color(0xFF22C55E);
  static const Color loss = Color(0xFFEF4444);
  static const Color gold = Color(0xFFEAB308);
  static const Color cyan = Color(0xFF22D3EE);

  // Champion Tier colors
  static const Color tierSPlus = Color(0xFFFF4757);
  static const Color tierS = Color(0xFFFF6B81);
  static const Color tierA = Color(0xFFFFA502);
  static const Color tierB = Color(0xFF3B82F6);
  static const Color tierC = Color(0xFF7A8599);
  static const Color tierD = Color(0xFF3D4654);
}
```

**Step 2: Create typography (JetBrains Mono as per design)**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static const String _fontFamily = 'JetBrainsMono';

  // Headline — used for screen titles ("Champion Tier List", "Buscar Jogador")
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Section titles — ("STATS GERAIS", "DISTRIBUICAO DE ROLES")
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.2,
  );

  // Status bar time
  static const TextStyle statusBar = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body — main content text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Body medium — secondary content
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Small — captions, labels, metadata
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Large stat numbers — ("55.7%", "2.54", "270")
  static const TextStyle statLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Bottom nav labels
  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
```

**Step 3: Create theme**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      fontFamily: 'JetBrainsMono',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.bgSecondary,
        error: AppColors.loss,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineLarge,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.navLabel,
        unselectedLabelStyle: AppTypography.navLabel,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'JetBrainsMono',
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
```

**Hora do commit** — adicionamos o design system completo (cores do .pen, tipografia JetBrains Mono, tema dark).

---

### Task 4: Core - Network (Error handling + API client)

**Files:**
- Create: `lib/core/network/api_exception.dart`
- Create: `lib/core/network/api_endpoints.dart`
- Create: `lib/core/network/api_client.dart`

**Step 1: Create typed exceptions**

```dart
sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException() : super('Sem conexao com a internet.');
}

class TimeoutException extends ApiException {
  const TimeoutException() : super('A requisicao demorou demais.');
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Recurso nao encontrado.'])
      : super(message);
}

class RateLimitedException extends ApiException {
  const RateLimitedException()
      : super('Muitas buscas. Tente novamente em alguns segundos.');
}

class ServerException extends ApiException {
  const ServerException() : super('Erro no servidor. Tente novamente.');
}

class UnknownApiException extends ApiException {
  const UnknownApiException([String message = 'Erro desconhecido.'])
      : super(message);
}
```

**Step 2: Create endpoints**

```dart
abstract final class ApiEndpoints {
  // Players
  static const String searchPlayer = '/players/search';
  static String playerProfile(String puuid) => '/players/$puuid';
  static String playerSummary(String puuid) => '/players/$puuid/summary';
  static String playerChampions(String puuid) => '/players/$puuid/champions';
  static String playerRoles(String puuid) => '/players/$puuid/roles';
  static String playerActivity(String puuid) => '/players/$puuid/activity';
  static String playerMatches(String puuid) => '/players/$puuid/matches/page';
  static String playerSyncStatus(String puuid) => '/players/$puuid/sync-status';

  // Matches
  static String matchDetails(String matchId) => '/matches/$matchId';
  static String matchGoldTimeline(String matchId) =>
      '/matches/$matchId/timeline/gold';
  static String matchEvents(String matchId) =>
      '/matches/$matchId/timeline/events';
  static String matchBuilds(String matchId) => '/matches/$matchId/builds';
  static String matchPerformance(String matchId, String puuid) =>
      '/matches/$matchId/performance/$puuid';

  // Champions
  static const String champions = '/champions';
  static const String currentPatch = '/champions/current-patch';
  static const String championStats = '/stats/champions';
  static String championStatsByName(String name) => '/stats/champions/$name';

  // Analytics
  static const String compareAnalytics = '/analytics/compare';
}
```

**Step 3: Create Dio API client with error interceptor**

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import 'api_exception.dart';

@lazySingleton
class ApiClient {
  ApiClient() : _dio = Dio(_baseOptions) {
    _dio.interceptors.add(_errorInterceptor);
  }

  final Dio _dio;

  Dio get dio => _dio;

  static final BaseOptions _baseOptions = BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    headers: {'Content-Type': 'application/json'},
  );

  static final InterceptorsWrapper _errorInterceptor = InterceptorsWrapper(
    onError: (DioException error, ErrorInterceptorHandler handler) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw const TimeoutException();
        case DioExceptionType.connectionError:
          throw const NetworkException();
        case DioExceptionType.badResponse:
          _handleBadResponse(error.response!.statusCode!);
        default:
          throw UnknownApiException(error.message ?? 'Erro desconhecido.');
      }
    },
  );

  static Never _handleBadResponse(int statusCode) {
    switch (statusCode) {
      case 404:
        throw const NotFoundException();
      case 429:
        throw const RateLimitedException();
      case >= 500:
        throw const ServerException();
      default:
        throw UnknownApiException('Erro HTTP $statusCode');
    }
  }
}
```

> Note a annotation `@lazySingleton` no ApiClient. O injectable vai registrar automaticamente no get_it.

**Hora do commit** — adicionamos o cliente HTTP (Dio) com interceptor de erros tipados e todos os endpoints da API.

---

### Task 5: Core - Dependency Injection (injectable)

**Files:**
- Create: `lib/core/di/injection.dart`

**Step 1: Create DI entry point**

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```

**Step 2: Generate the config file**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Creates `lib/core/di/injection.config.dart` automatically. It will contain the registration for `ApiClient` (the only `@lazySingleton` so far).

**Hora do commit** — adicionamos o setup de injecao de dependencia com injectable + get_it.

---

### Task 6: Core - Router (structure only)

**Files:**
- Create: `lib/core/router/app_router.dart`

**Step 1: Create router with placeholder routes**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Player Search — em construcao')),
      ),
    ),
  ],
);
```

> Routes will be connected to real pages as each feature's UI is built. For now, placeholder only.

**Hora do commit** — adicionamos a configuracao do GoRouter com rota placeholder.

---

### Task 7: Shared Widgets

**Files:**
- Create: `lib/shared/widgets/loading_indicator.dart`
- Create: `lib/shared/widgets/error_display.dart`

**Step 1: Create loading indicator**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}
```

**Step 2: Create error display with retry**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.loss, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

**Hora do commit** — adicionamos widgets compartilhados (loading e error display).

---

### Task 8: App entry point

**Files:**
- Create: `lib/app.dart`
- Modify: `lib/main.dart`

**Step 1: Create app.dart**

```dart
import 'package:flutter/material.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
```

**Step 2: Replace main.dart**

```dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const App());
}
```

**Step 3: Delete old test**

Run: `rm test/widget_test.dart`

The old template test references `MyApp` which no longer exists.

**Step 4: Verify**

Run: `flutter analyze`
Expected: No issues found

Run: `flutter test`
Expected: No test files found (or passes if empty)

**Hora do commit** — substituimos o template padrao pelo entry point da clean architecture. App roda com tema dark e rota placeholder.

---

### Task 9: player_search - Domain Layer (TDD)

**Files:**
- Create: `lib/features/player_search/domain/entities/player_search_result.dart`
- Create: `lib/features/player_search/domain/repositories/player_search_repository.dart`
- Create: `lib/features/player_search/domain/usecases/search_player.dart`
- Create: `test/features/player_search/domain/usecases/search_player_test.dart`

**Step 1: Create entity (based on API response shape)**

```dart
import 'package:equatable/equatable.dart';

class PlayerSearchResult extends Equatable {
  const PlayerSearchResult({
    required this.puuid,
    required this.gameName,
    required this.tagLine,
    required this.profileIconId,
    required this.summonerLevel,
    required this.matchesEnqueued,
  });

  final String puuid;
  final String gameName;
  final String tagLine;
  final int profileIconId;
  final int summonerLevel;
  final int matchesEnqueued;

  @override
  List<Object?> get props =>
      [puuid, gameName, tagLine, profileIconId, summonerLevel, matchesEnqueued];
}
```

**Step 2: Create repository contract (abstract class — the "D" in SOLID)**

```dart
import '../entities/player_search_result.dart';

abstract class PlayerSearchRepository {
  Future<PlayerSearchResult> searchPlayer({
    required String gameName,
    required String tagLine,
  });
}
```

**Step 3: Create use case**

```dart
import 'package:injectable/injectable.dart';
import '../entities/player_search_result.dart';
import '../repositories/player_search_repository.dart';

@lazySingleton
class SearchPlayer {
  const SearchPlayer(this._repository);

  final PlayerSearchRepository _repository;

  Future<PlayerSearchResult> call({
    required String gameName,
    required String tagLine,
  }) {
    return _repository.searchPlayer(gameName: gameName, tagLine: tagLine);
  }
}
```

**Step 4: Write test for the use case**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/player_search_result.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/repositories/player_search_repository.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/search_player.dart';

class MockPlayerSearchRepository extends Mock
    implements PlayerSearchRepository {}

void main() {
  late SearchPlayer useCase;
  late MockPlayerSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerSearchRepository();
    useCase = SearchPlayer(mockRepository);
  });

  const tResult = PlayerSearchResult(
    puuid: 'test-puuid-123',
    gameName: 'BrTT',
    tagLine: 'BR1',
    profileIconId: 3789,
    summonerLevel: 492,
    matchesEnqueued: 5,
  );

  test('should return PlayerSearchResult from the repository', () async {
    when(() => mockRepository.searchPlayer(
          gameName: any(named: 'gameName'),
          tagLine: any(named: 'tagLine'),
        )).thenAnswer((_) async => tResult);

    final result = await useCase(gameName: 'BrTT', tagLine: 'BR1');

    expect(result, equals(tResult));
    verify(() => mockRepository.searchPlayer(
          gameName: 'BrTT',
          tagLine: 'BR1',
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
```

**Step 5: Run test**

Run: `flutter test test/features/player_search/domain/usecases/search_player_test.dart`
Expected: PASS

**Hora do commit** — adicionamos a camada domain do player_search (entity, repository contract, use case) com teste unitario.

---

### Task 10: player_search - Data Layer (TDD)

**Files:**
- Create: `lib/features/player_search/data/models/player_search_result_model.dart`
- Create: `lib/features/player_search/data/datasources/player_search_remote_datasource.dart`
- Create: `lib/features/player_search/data/repositories/player_search_repository_impl.dart`
- Create: `test/features/player_search/data/models/player_search_result_model_test.dart`
- Create: `test/features/player_search/data/repositories/player_search_repository_impl_test.dart`

**Step 1: Write failing test for model fromJson**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/player_search_result_model.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/player_search_result.dart';

void main() {
  const tModel = PlayerSearchResultModel(
    puuid: 'test-puuid-123',
    gameName: 'BrTT',
    tagLine: 'BR1',
    profileIconId: 3789,
    summonerLevel: 492,
    matchesEnqueued: 5,
  );

  const tJson = {
    'puuid': 'test-puuid-123',
    'gameName': 'BrTT',
    'tagLine': 'BR1',
    'profileIconId': 3789,
    'summonerLevel': 492,
    'matchesEnqueued': 5,
  };

  test('should be a subclass of PlayerSearchResult', () {
    expect(tModel, isA<PlayerSearchResult>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerSearchResultModel.fromJson(tJson);
    expect(result, equals(tModel));
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/player_search/data/models/player_search_result_model_test.dart`
Expected: FAIL (class does not exist yet)

**Step 3: Create model**

```dart
import '../../domain/entities/player_search_result.dart';

class PlayerSearchResultModel extends PlayerSearchResult {
  const PlayerSearchResultModel({
    required super.puuid,
    required super.gameName,
    required super.tagLine,
    required super.profileIconId,
    required super.summonerLevel,
    required super.matchesEnqueued,
  });

  factory PlayerSearchResultModel.fromJson(Map<String, dynamic> json) {
    return PlayerSearchResultModel(
      puuid: json['puuid'] as String,
      gameName: json['gameName'] as String,
      tagLine: json['tagLine'] as String,
      profileIconId: json['profileIconId'] as int,
      summonerLevel: json['summonerLevel'] as int,
      matchesEnqueued: json['matchesEnqueued'] as int,
    );
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/player_search/data/models/player_search_result_model_test.dart`
Expected: PASS

**Step 5: Create remote data source**

```dart
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/player_search_result_model.dart';

@lazySingleton
class PlayerSearchRemoteDataSource {
  const PlayerSearchRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PlayerSearchResultModel> searchPlayer({
    required String gameName,
    required String tagLine,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.searchPlayer,
      data: {'gameName': gameName, 'tagLine': tagLine},
    );
    return PlayerSearchResultModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
```

**Step 6: Write test for repository impl**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/data/datasources/player_search_remote_datasource.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/player_search_result_model.dart';
import 'package:high_br_lol_mobile/features/player_search/data/repositories/player_search_repository_impl.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockRemoteDataSource extends Mock
    implements PlayerSearchRemoteDataSource {}

void main() {
  late PlayerSearchRepositoryImpl repository;
  late MockRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockRemoteDataSource();
    repository = PlayerSearchRepositoryImpl(mockDataSource);
  });

  const tModel = PlayerSearchResultModel(
    puuid: 'test-puuid-123',
    gameName: 'BrTT',
    tagLine: 'BR1',
    profileIconId: 3789,
    summonerLevel: 492,
    matchesEnqueued: 5,
  );

  test('should return PlayerSearchResult when datasource succeeds', () async {
    when(() => mockDataSource.searchPlayer(
          gameName: any(named: 'gameName'),
          tagLine: any(named: 'tagLine'),
        )).thenAnswer((_) async => tModel);

    final result = await repository.searchPlayer(
      gameName: 'BrTT',
      tagLine: 'BR1',
    );

    expect(result, equals(tModel));
  });

  test('should rethrow ApiException when datasource fails', () async {
    when(() => mockDataSource.searchPlayer(
          gameName: any(named: 'gameName'),
          tagLine: any(named: 'tagLine'),
        )).thenThrow(const NotFoundException());

    expect(
      () => repository.searchPlayer(gameName: 'BrTT', tagLine: 'BR1'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
```

**Step 7: Create repository implementation**

```dart
import 'package:injectable/injectable.dart';
import '../../domain/entities/player_search_result.dart';
import '../../domain/repositories/player_search_repository.dart';
import '../datasources/player_search_remote_datasource.dart';

@LazySingleton(as: PlayerSearchRepository)
class PlayerSearchRepositoryImpl implements PlayerSearchRepository {
  const PlayerSearchRepositoryImpl(this._remoteDataSource);

  final PlayerSearchRemoteDataSource _remoteDataSource;

  @override
  Future<PlayerSearchResult> searchPlayer({
    required String gameName,
    required String tagLine,
  }) {
    return _remoteDataSource.searchPlayer(
      gameName: gameName,
      tagLine: tagLine,
    );
  }
}
```

> Note `@LazySingleton(as: PlayerSearchRepository)` — isso diz ao injectable: "registre `PlayerSearchRepositoryImpl` mas no get_it quem aparece e o tipo `PlayerSearchRepository`". Isso e o Dependency Inversion na pratica.

**Step 8: Run all data layer tests**

Run: `flutter test test/features/player_search/data/`
Expected: All PASS

**Hora do commit** — adicionamos a camada data do player_search (model com fromJson, datasource, repository impl) com testes.

---

### Task 11: player_search - BLoC (TDD)

**Files:**
- Create: `lib/features/player_search/presentation/bloc/player_search_event.dart`
- Create: `lib/features/player_search/presentation/bloc/player_search_state.dart`
- Create: `lib/features/player_search/presentation/bloc/player_search_bloc.dart`
- Create: `test/features/player_search/presentation/bloc/player_search_bloc_test.dart`

**Step 1: Create events**

```dart
import 'package:equatable/equatable.dart';

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
```

**Step 2: Create states**

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/player_search_result.dart';

sealed class PlayerSearchState extends Equatable {
  const PlayerSearchState();

  @override
  List<Object?> get props => [];
}

class PlayerSearchInitial extends PlayerSearchState {
  const PlayerSearchInitial();
}

class PlayerSearchLoading extends PlayerSearchState {
  const PlayerSearchLoading();
}

class PlayerSearchSuccess extends PlayerSearchState {
  const PlayerSearchSuccess(this.result);

  final PlayerSearchResult result;

  @override
  List<Object?> get props => [result];
}

class PlayerSearchFailure extends PlayerSearchState {
  const PlayerSearchFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
```

**Step 3: Write failing BLoC test**

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/player_search_result.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/search_player.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/player_search_bloc.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/player_search_event.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/player_search_state.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockSearchPlayer extends Mock implements SearchPlayer {}

void main() {
  late PlayerSearchBloc bloc;
  late MockSearchPlayer mockSearchPlayer;

  setUp(() {
    mockSearchPlayer = MockSearchPlayer();
    bloc = PlayerSearchBloc(mockSearchPlayer);
  });

  tearDown(() => bloc.close());

  const tResult = PlayerSearchResult(
    puuid: 'test-puuid-123',
    gameName: 'BrTT',
    tagLine: 'BR1',
    profileIconId: 3789,
    summonerLevel: 492,
    matchesEnqueued: 5,
  );

  test('initial state should be PlayerSearchInitial', () {
    expect(bloc.state, const PlayerSearchInitial());
  });

  blocTest<PlayerSearchBloc, PlayerSearchState>(
    'emits [Loading, Success] when search succeeds',
    build: () {
      when(() => mockSearchPlayer(
            gameName: any(named: 'gameName'),
            tagLine: any(named: 'tagLine'),
          )).thenAnswer((_) async => tResult);
      return bloc;
    },
    act: (bloc) => bloc.add(
      const PlayerSearchSubmitted(gameName: 'BrTT', tagLine: 'BR1'),
    ),
    expect: () => [
      const PlayerSearchLoading(),
      const PlayerSearchSuccess(tResult),
    ],
  );

  blocTest<PlayerSearchBloc, PlayerSearchState>(
    'emits [Loading, Failure] when search throws NotFoundException',
    build: () {
      when(() => mockSearchPlayer(
            gameName: any(named: 'gameName'),
            tagLine: any(named: 'tagLine'),
          )).thenThrow(const NotFoundException('Jogador nao encontrado.'));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const PlayerSearchSubmitted(gameName: 'Unknown', tagLine: 'BR1'),
    ),
    expect: () => [
      const PlayerSearchLoading(),
      const PlayerSearchFailure('Jogador nao encontrado.'),
    ],
  );

  blocTest<PlayerSearchBloc, PlayerSearchState>(
    'emits [Loading, Failure] when search throws unexpected error',
    build: () {
      when(() => mockSearchPlayer(
            gameName: any(named: 'gameName'),
            tagLine: any(named: 'tagLine'),
          )).thenThrow(Exception('unexpected'));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const PlayerSearchSubmitted(gameName: 'Test', tagLine: 'BR1'),
    ),
    expect: () => [
      const PlayerSearchLoading(),
      const PlayerSearchFailure('Erro inesperado. Tente novamente.'),
    ],
  );
}
```

**Step 4: Run test to verify it fails**

Run: `flutter test test/features/player_search/presentation/bloc/player_search_bloc_test.dart`
Expected: FAIL (PlayerSearchBloc does not exist yet)

**Step 5: Create BLoC**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/search_player.dart';
import 'player_search_event.dart';
import 'player_search_state.dart';

@injectable
class PlayerSearchBloc extends Bloc<PlayerSearchEvent, PlayerSearchState> {
  PlayerSearchBloc(this._searchPlayer) : super(const PlayerSearchInitial()) {
    on<PlayerSearchSubmitted>(_onSearchSubmitted);
  }

  final SearchPlayer _searchPlayer;

  Future<void> _onSearchSubmitted(
    PlayerSearchSubmitted event,
    Emitter<PlayerSearchState> emit,
  ) async {
    emit(const PlayerSearchLoading());
    try {
      final result = await _searchPlayer(
        gameName: event.gameName,
        tagLine: event.tagLine,
      );
      emit(PlayerSearchSuccess(result));
    } on ApiException catch (e) {
      emit(PlayerSearchFailure(e.message));
    } catch (_) {
      emit(const PlayerSearchFailure('Erro inesperado. Tente novamente.'));
    }
  }
}
```

> Note `@injectable` (nao `@lazySingleton`). BLoCs devem ser `factory` porque cada tela cria uma nova instancia. Singletons manteriam estado entre navegacoes, o que causaria bugs.

**Step 6: Run test to verify it passes**

Run: `flutter test test/features/player_search/presentation/bloc/player_search_bloc_test.dart`
Expected: All PASS

**Hora do commit** — adicionamos o BLoC do player_search (events, states, bloc) com 3 testes cobrindo sucesso, erro da API e erro inesperado.

---

### Task 12: Regenerate DI and run full test suite

**Step 1: Regenerate injectable config**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Regenerates `injection.config.dart` with all annotated classes (ApiClient, PlayerSearchRemoteDataSource, PlayerSearchRepositoryImpl, SearchPlayer, PlayerSearchBloc)

**Step 2: Run all tests**

Run: `flutter test`
Expected: All tests PASS (use case, model, repository, bloc — 6 tests total)

**Step 3: Run analyzer**

Run: `flutter analyze`
Expected: No issues found

**Hora do commit** — regeneramos o DI e todos os 6 testes passam. Infraestrutura completa.

---

## STOP — Pause point

At this point you have:

- **Core infrastructure:** Theme (from .pen design), DI (injectable), routing, HTTP client, error handling
- **Complete player_search feature:** Domain + Data + BLoC layers, all with TDD
- **6 passing tests** across 4 test files
- **No UI yet** — the app runs but shows only a placeholder screen

### What was built (and why):

```
lib/
├── main.dart                              ← Entry point, initializes DI
├── app.dart                               ← MaterialApp with theme + router
├── core/
│   ├── constants/app_constants.dart        ← API URL, timeouts
│   ├── theme/
│   │   ├── app_colors.dart                 ← Colors extracted from .pen
│   │   ├── app_typography.dart             ← JetBrains Mono styles
│   │   └── app_theme.dart                  ← ThemeData dark
│   ├── network/
│   │   ├── api_exception.dart              ← Typed errors (sealed class)
│   │   ├── api_endpoints.dart              ← All API URLs
│   │   └── api_client.dart                 ← Dio + error interceptor
│   ├── di/
│   │   ├── injection.dart                  ← get_it + injectable entry
│   │   └── injection.config.dart           ← Generated by build_runner
│   └── router/
│       └── app_router.dart                 ← GoRouter (placeholder)
├── features/
│   └── player_search/
│       ├── domain/
│       │   ├── entities/                   ← Pure Dart object
│       │   ├── repositories/               ← Abstract contract
│       │   └── usecases/                   ← Business logic
│       ├── data/
│       │   ├── models/                     ← DTO with fromJson
│       │   ├── datasources/                ← HTTP calls
│       │   └── repositories/               ← Implements contract
│       └── presentation/
│           └── bloc/                       ← Events, States, BLoC
└── shared/
    └── widgets/                            ← Loading, Error
```

### Next steps (when you're ready):

1. **Build the PlayerSearchPage UI** — connect the BLoC to a real screen matching the .pen design
2. **Add BottomNavBar** with 4 tabs (Meta, Buscar, Compare, Partidas)
3. **Build champion_stats feature** — same pattern as player_search
4. **Build player_profile feature** — same pattern
5. Continue feature by feature...

Each new feature follows the exact same folder pattern as player_search. Copy the structure, replace the names.
