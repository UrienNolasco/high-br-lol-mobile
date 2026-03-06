# Processing Status Screen Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an intermediate screen that polls the backend for match processing progress and auto-navigates to the player profile when done.

**Architecture:** New data layer (entity, model, datasource, repository, usecase) for the status endpoint, a new BLoC with Timer-based polling, a new page widget, and router changes to insert this screen between search and profile.

**Tech Stack:** Flutter widgets, flutter_bloc (Timer polling), go_router, injectable DI, equatable, dio

---

### Task 1: Entity + Model + Test

**Files:**
- Create: `lib/features/player_search/domain/entities/processing_status.dart`
- Create: `lib/features/player_search/data/models/processing_status_model.dart`
- Create: `test/features/player_search/data/models/processing_status_model_test.dart`

**Step 1: Create the entity with UpdateStatus enum**

```dart
import 'package:equatable/equatable.dart';

enum UpdateStatus { idle, updating, error }

class ProcessingStatus extends Equatable {
  const ProcessingStatus({
    required this.status,
    required this.matchesProcessed,
    required this.matchesTotal,
    required this.message,
  });

  final UpdateStatus status;
  final int matchesProcessed;
  final int matchesTotal;
  final String message;

  @override
  List<Object?> get props => [status, matchesProcessed, matchesTotal, message];
}
```

**Step 2: Create the model with fromJson**

```dart
import '../../domain/entities/processing_status.dart';

class ProcessingStatusModel extends ProcessingStatus {
  const ProcessingStatusModel({
    required super.status,
    required super.matchesProcessed,
    required super.matchesTotal,
    required super.message,
  });

  factory ProcessingStatusModel.fromJson(Map<String, dynamic> json) {
    return ProcessingStatusModel(
      status: _parseStatus(json['status'] as String),
      matchesProcessed: json['matchesProcessed'] as int,
      matchesTotal: json['matchesTotal'] as int,
      message: json['message'] as String,
    );
  }

  static UpdateStatus _parseStatus(String status) {
    return switch (status) {
      'IDLE' => UpdateStatus.idle,
      'UPDATING' => UpdateStatus.updating,
      'ERROR' => UpdateStatus.error,
      _ => UpdateStatus.error,
    };
  }
}
```

**Step 3: Write the test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/processing_status_model.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';

void main() {
  test('should be a subclass of ProcessingStatus', () {
    const model = ProcessingStatusModel(
      status: UpdateStatus.idle,
      matchesProcessed: 20,
      matchesTotal: 20,
      message: 'All matches processed',
    );
    expect(model, isA<ProcessingStatus>());
  });

  test('should parse IDLE status from JSON', () {
    final json = {
      'status': 'IDLE',
      'matchesProcessed': 20,
      'matchesTotal': 20,
      'message': 'All matches processed',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.idle);
    expect(model.matchesProcessed, 20);
    expect(model.matchesTotal, 20);
    expect(model.message, 'All matches processed');
  });

  test('should parse UPDATING status from JSON', () {
    final json = {
      'status': 'UPDATING',
      'matchesProcessed': 5,
      'matchesTotal': 20,
      'message': 'Processing matches: 5/20',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.updating);
    expect(model.matchesProcessed, 5);
    expect(model.matchesTotal, 20);
  });

  test('should parse ERROR status from JSON', () {
    final json = {
      'status': 'ERROR',
      'matchesProcessed': 0,
      'matchesTotal': 0,
      'message': 'Failed to fetch match status from Riot API',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.error);
    expect(model.message, 'Failed to fetch match status from Riot API');
  });

  test('should default unknown status to error', () {
    final json = {
      'status': 'UNKNOWN',
      'matchesProcessed': 0,
      'matchesTotal': 0,
      'message': 'Something unexpected',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.error);
  });
}
```

**Step 4: Verify**

Run: `flutter test test/features/player_search/data/models/processing_status_model_test.dart`
Expected: 5 tests pass

**Hora do commit** — adicionamos entity ProcessingStatus com enum UpdateStatus e model com fromJson.

---

### Task 2: API Endpoint + Datasource

**Files:**
- Modify: `lib/core/network/api_endpoints.dart`
- Modify: `lib/features/player_search/data/datasources/player_search_remote_datasource.dart`

**Step 1: Add endpoint**

Add to `ApiEndpoints` class:

```dart
static String playerStatus(String puuid) => '/players/$puuid/status';
```

**Step 2: Add method to datasource**

Add to `PlayerSearchRemoteDataSource`:

```dart
import '../models/processing_status_model.dart';
```

And the method:

```dart
Future<ProcessingStatusModel> getPlayerStatus({
  required String puuid,
}) async {
  final response = await _apiClient.dio.get(
    ApiEndpoints.playerStatus(puuid),
  );
  return ProcessingStatusModel.fromJson(
    response.data as Map<String, dynamic>,
  );
}
```

**Hora do commit** — adicionamos endpoint playerStatus e metodo getPlayerStatus no datasource.

---

### Task 3: Repository (with test)

**Files:**
- Modify: `lib/features/player_search/domain/repositories/player_search_repository.dart`
- Modify: `lib/features/player_search/data/repositories/player_search_repository_impl.dart`
- Modify: `test/features/player_search/data/repositories/player_search_repository_impl_test.dart`

**Step 1: Add to abstract repository**

Add import and method:

```dart
import '../entities/processing_status.dart';
```

```dart
Future<ProcessingStatus> getPlayerStatus({required String puuid});
```

**Step 2: Add implementation**

Add import:

```dart
import '../../domain/entities/processing_status.dart';
```

Add method to `PlayerSearchRepositoryImpl`:

```dart
@override
Future<ProcessingStatus> getPlayerStatus({required String puuid}) {
  return _remoteDataSource.getPlayerStatus(puuid: puuid);
}
```

**Step 3: Add test**

Add to the existing test file, inside `main()`:

```dart
test('should return ProcessingStatus when getPlayerStatus succeeds', () async {
  const tStatus = ProcessingStatusModel(
    status: UpdateStatus.updating,
    matchesProcessed: 5,
    matchesTotal: 20,
    message: 'Processing matches: 5/20',
  );
  when(() => mockDataSource.getPlayerStatus(puuid: any(named: 'puuid')))
      .thenAnswer((_) async => tStatus);

  final result = await repository.getPlayerStatus(puuid: 'test-puuid');

  expect(result, tStatus);
  verify(() => mockDataSource.getPlayerStatus(puuid: 'test-puuid')).called(1);
});
```

Also add the required imports at the top of the test file:

```dart
import 'package:high_br_lol_mobile/features/player_search/data/models/processing_status_model.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';
```

**Step 4: Verify**

Run: `flutter test test/features/player_search/data/repositories/`
Expected: 3 tests pass (2 existing + 1 new)

**Hora do commit** — adicionamos getPlayerStatus no repository abstrato e implementacao.

---

### Task 4: UseCase (with test)

**Files:**
- Create: `lib/features/player_search/domain/usecases/get_player_status.dart`
- Create: `test/features/player_search/domain/usecases/get_player_status_test.dart`

**Step 1: Create the use case**

```dart
import 'package:injectable/injectable.dart';
import '../entities/processing_status.dart';
import '../repositories/player_search_repository.dart';

@lazySingleton
class GetPlayerStatus {
  const GetPlayerStatus(this._repository);

  final PlayerSearchRepository _repository;

  Future<ProcessingStatus> call({required String puuid}) {
    return _repository.getPlayerStatus(puuid: puuid);
  }
}
```

**Step 2: Write the test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/repositories/player_search_repository.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/get_player_status.dart';

class MockPlayerSearchRepository extends Mock
    implements PlayerSearchRepository {}

void main() {
  late GetPlayerStatus useCase;
  late MockPlayerSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerSearchRepository();
    useCase = GetPlayerStatus(mockRepository);
  });

  test('should return ProcessingStatus from the repository', () async {
    const tStatus = ProcessingStatus(
      status: UpdateStatus.updating,
      matchesProcessed: 10,
      matchesTotal: 20,
      message: 'Processing matches: 10/20',
    );
    when(() => mockRepository.getPlayerStatus(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tStatus);

    final result = await useCase(puuid: 'test-puuid');

    expect(result, tStatus);
    verify(() => mockRepository.getPlayerStatus(puuid: 'test-puuid')).called(1);
  });
}
```

**Step 3: Verify**

Run: `flutter test test/features/player_search/domain/usecases/get_player_status_test.dart`
Expected: 1 test passes

**Hora do commit** — adicionamos usecase GetPlayerStatus.

---

### Task 5: BLoC (events, states, bloc, tests)

**Files:**
- Create: `lib/features/player_search/presentation/bloc/processing_status_event.dart`
- Create: `lib/features/player_search/presentation/bloc/processing_status_state.dart`
- Create: `lib/features/player_search/presentation/bloc/processing_status_bloc.dart`
- Create: `test/features/player_search/presentation/bloc/processing_status_bloc_test.dart`

**Step 1: Create events**

```dart
import 'package:equatable/equatable.dart';

sealed class ProcessingStatusEvent extends Equatable {
  const ProcessingStatusEvent();

  @override
  List<Object?> get props => [];
}

class ProcessingStarted extends ProcessingStatusEvent {
  const ProcessingStarted({required this.puuid});

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}

class ProcessingPolled extends ProcessingStatusEvent {
  const ProcessingPolled();
}

class ProcessingRetried extends ProcessingStatusEvent {
  const ProcessingRetried({required this.puuid});

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}

class ProcessingStopped extends ProcessingStatusEvent {
  const ProcessingStopped();
}
```

**Step 2: Create states**

```dart
import 'package:equatable/equatable.dart';

sealed class ProcessingStatusState extends Equatable {
  const ProcessingStatusState();

  @override
  List<Object?> get props => [];
}

class ProcessingStatusLoading extends ProcessingStatusState {
  const ProcessingStatusLoading();
}

class ProcessingStatusUpdating extends ProcessingStatusState {
  const ProcessingStatusUpdating({
    required this.matchesProcessed,
    required this.matchesTotal,
  });

  final int matchesProcessed;
  final int matchesTotal;

  double get progress =>
      matchesTotal > 0 ? matchesProcessed / matchesTotal : 0;

  @override
  List<Object?> get props => [matchesProcessed, matchesTotal];
}

class ProcessingStatusComplete extends ProcessingStatusState {
  const ProcessingStatusComplete(this.puuid);

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}

class ProcessingStatusError extends ProcessingStatusState {
  const ProcessingStatusError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
```

**Step 3: Create the BLoC**

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/processing_status.dart';
import '../../domain/usecases/get_player_status.dart';
import 'processing_status_event.dart';
import 'processing_status_state.dart';

@injectable
class ProcessingStatusBloc
    extends Bloc<ProcessingStatusEvent, ProcessingStatusState> {
  ProcessingStatusBloc(this._getPlayerStatus)
      : super(const ProcessingStatusLoading()) {
    on<ProcessingStarted>(_onStarted);
    on<ProcessingPolled>(_onPolled);
    on<ProcessingRetried>(_onRetried);
    on<ProcessingStopped>(_onStopped);
  }

  final GetPlayerStatus _getPlayerStatus;
  Timer? _timer;
  String? _puuid;

  Future<void> _onStarted(
    ProcessingStarted event,
    Emitter<ProcessingStatusState> emit,
  ) async {
    _puuid = event.puuid;
    await _poll(emit);
    _startTimer();
  }

  Future<void> _onPolled(
    ProcessingPolled event,
    Emitter<ProcessingStatusState> emit,
  ) async {
    await _poll(emit);
  }

  Future<void> _onRetried(
    ProcessingRetried event,
    Emitter<ProcessingStatusState> emit,
  ) async {
    _puuid = event.puuid;
    emit(const ProcessingStatusLoading());
    await _poll(emit);
    _startTimer();
  }

  void _onStopped(
    ProcessingStopped event,
    Emitter<ProcessingStatusState> emit,
  ) {
    _timer?.cancel();
  }

  Future<void> _poll(Emitter<ProcessingStatusState> emit) async {
    try {
      final status = await _getPlayerStatus(puuid: _puuid!);
      switch (status.status) {
        case UpdateStatus.idle:
          _timer?.cancel();
          emit(ProcessingStatusComplete(_puuid!));
        case UpdateStatus.error:
          _timer?.cancel();
          emit(ProcessingStatusError(status.message));
        case UpdateStatus.updating:
          emit(ProcessingStatusUpdating(
            matchesProcessed: status.matchesProcessed,
            matchesTotal: status.matchesTotal,
          ));
      }
    } on ApiException {
      // Silent retry — next poll cycle will try again
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!isClosed) add(const ProcessingPolled());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
```

**Step 4: Write the tests**

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/get_player_status.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/processing_status_bloc.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/processing_status_event.dart';
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/processing_status_state.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockGetPlayerStatus extends Mock implements GetPlayerStatus {}

void main() {
  late ProcessingStatusBloc bloc;
  late MockGetPlayerStatus mockGetPlayerStatus;

  setUp(() {
    mockGetPlayerStatus = MockGetPlayerStatus();
    bloc = ProcessingStatusBloc(mockGetPlayerStatus);
  });

  tearDown(() => bloc.close());

  const tPuuid = 'test-puuid-123';

  const tUpdating = ProcessingStatus(
    status: UpdateStatus.updating,
    matchesProcessed: 5,
    matchesTotal: 20,
    message: 'Processing matches: 5/20',
  );

  const tIdle = ProcessingStatus(
    status: UpdateStatus.idle,
    matchesProcessed: 20,
    matchesTotal: 20,
    message: 'All matches processed',
  );

  const tError = ProcessingStatus(
    status: UpdateStatus.error,
    matchesProcessed: 0,
    matchesTotal: 0,
    message: 'Failed to fetch match status from Riot API',
  );

  test('initial state should be ProcessingStatusLoading', () {
    expect(bloc.state, const ProcessingStatusLoading());
  });

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits [Updating] when started and status is UPDATING',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tUpdating);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProcessingStatusUpdating(matchesProcessed: 5, matchesTotal: 20),
    ],
  );

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits [Complete] when started and status is IDLE',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tIdle);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProcessingStatusComplete(tPuuid),
    ],
  );

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits [Error] when started and status is ERROR',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tError);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProcessingStatusError('Failed to fetch match status from Riot API'),
    ],
  );

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits nothing extra when API throws (silent retry)',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenThrow(const ServerException());
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [],
  );

  blocTest<ProcessingStatusBloc, ProcessingStatusState>(
    'emits [Loading, Updating] when retried',
    build: () {
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tUpdating);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProcessingRetried(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProcessingStatusLoading(),
      const ProcessingStatusUpdating(matchesProcessed: 5, matchesTotal: 20),
    ],
  );
}
```

**Step 5: Verify**

Run: `flutter test test/features/player_search/presentation/bloc/processing_status_bloc_test.dart`
Expected: 6 tests pass

**Hora do commit** — adicionamos ProcessingStatusBloc com polling via Timer, eventos e estados.

---

### Task 6: Regenerate DI

**Step 1: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: `injection.config.dart` regenerated with `GetPlayerStatus` and `ProcessingStatusBloc` registered.

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues found

**Hora do commit** — regeneramos injection.config.dart com GetPlayerStatus e ProcessingStatusBloc.

---

### Task 7: ProcessingStatusPage widget

**Files:**
- Create: `lib/features/player_search/presentation/pages/processing_status_page.dart`

**Step 1: Create the page**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/processing_status_bloc.dart';
import '../bloc/processing_status_event.dart';
import '../bloc/processing_status_state.dart';

class ProcessingStatusPage extends StatelessWidget {
  const ProcessingStatusPage({
    super.key,
    required this.puuid,
    required this.gameName,
    required this.tagLine,
  });

  final String puuid;
  final String gameName;
  final String tagLine;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProcessingStatusBloc>()
        ..add(ProcessingStarted(puuid: puuid)),
      child: _ProcessingStatusView(
        puuid: puuid,
        gameName: gameName,
        tagLine: tagLine,
      ),
    );
  }
}

class _ProcessingStatusView extends StatelessWidget {
  const _ProcessingStatusView({
    required this.puuid,
    required this.gameName,
    required this.tagLine,
  });

  final String puuid;
  final String gameName;
  final String tagLine;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessingStatusBloc, ProcessingStatusState>(
      listener: (context, state) {
        if (state is ProcessingStatusComplete) {
          context.go('/search/player/${state.puuid}');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: BlocBuilder<ProcessingStatusBloc, ProcessingStatusState>(
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Player name
                      Text(
                        '$gameName#$tagLine',
                        style: AppTypography.headlineLarge,
                      ),
                      const SizedBox(height: 32),
                      // Status indicator
                      _buildStatusIndicator(state),
                      const SizedBox(height: 24),
                      // Progress text
                      _buildProgressText(state),
                      const SizedBox(height: 16),
                      // Progress bar
                      if (state is ProcessingStatusUpdating)
                        _buildProgressBar(state),
                      // Error buttons
                      if (state is ProcessingStatusError) ...[
                        const SizedBox(height: 32),
                        _buildErrorButtons(context),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ProcessingStatusState state) {
    if (state is ProcessingStatusError) {
      return const Icon(
        Icons.error_outline,
        color: AppColors.loss,
        size: 48,
      );
    }
    return const SizedBox(
      width: 48,
      height: 48,
      child: CircularProgressIndicator(
        color: AppColors.accent,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildProgressText(ProcessingStatusState state) {
    if (state is ProcessingStatusUpdating) {
      return Text(
        'Processando ${state.matchesProcessed}/${state.matchesTotal} partidas...',
        style: AppTypography.bodyMedium,
        textAlign: TextAlign.center,
      );
    }
    if (state is ProcessingStatusError) {
      return Text(
        state.message,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.loss),
        textAlign: TextAlign.center,
      );
    }
    return Text(
      'Buscando partidas...',
      style: AppTypography.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressBar(ProcessingStatusUpdating state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: state.progress,
        backgroundColor: AppColors.bgTertiary,
        color: AppColors.accent,
        minHeight: 6,
      ),
    );
  }

  Widget _buildErrorButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              context
                  .read<ProcessingStatusBloc>()
                  .add(ProcessingRetried(puuid: puuid));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Tentar novamente',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () => context.go('/search'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Voltar',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Hora do commit** — adicionamos ProcessingStatusPage com indicador de progresso, texto e botoes de erro.

---

### Task 8: Router + Navigation Changes

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/player_search/presentation/pages/player_search_page.dart`

**Step 1: Add processing route to router**

In `app_router.dart`, add the import:

```dart
import '../../features/player_search/presentation/pages/processing_status_page.dart';
import '../../features/player_search/domain/entities/player_search_result.dart';
```

Replace the `player/:puuid` GoRoute with nested routes:

```dart
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
```

**Step 2: Change navigation in PlayerSearchPage**

In `player_search_page.dart`, change the BlocListener success handler from:

```dart
if (state is PlayerSearchSuccess) {
  context.go('/search/player/${state.result.puuid}');
}
```

To:

```dart
if (state is PlayerSearchSuccess) {
  context.go(
    '/search/player/${state.result.puuid}/processing',
    extra: state.result,
  );
}
```

**Hora do commit** — adicionamos rota /processing e redirecionamos busca para tela de processamento.

---

### Task 9: Verify everything

**Step 1: Run analyze**

Run: `flutter analyze`
Expected: No issues found

**Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass (9 existing + 5 model + 1 repository + 1 usecase + 6 bloc = 22 tests)

**Hora do commit** — tela de processamento finalizada e verificada.
