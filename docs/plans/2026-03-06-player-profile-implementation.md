# Player Profile Overview Tab Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the PlayerProfilePage with Overview tab, replacing the current placeholder. Loads player data in 2 phases (header first, body parallel) with a processing banner that polls match status.

**Architecture:** New `player_profile` feature following Clean Architecture (domain/data/presentation). Two BLoCs: `PlayerProfileBloc` (header + status polling) and `PlayerOverviewBloc` (body with Future.wait). Reuses `GetPlayerStatus` usecase from `player_search` for polling.

**Tech Stack:** Flutter widgets, flutter_bloc (Timer polling), go_router, injectable DI, equatable, dio, Future.wait

---

### Task 1: Domain Entities

**Files:**
- Create: `lib/features/player_profile/domain/entities/player_profile.dart`
- Create: `lib/features/player_profile/domain/entities/player_summary.dart`
- Create: `lib/features/player_profile/domain/entities/player_champion.dart`
- Create: `lib/features/player_profile/domain/entities/player_role.dart`
- Create: `lib/features/player_profile/domain/entities/player_activity.dart`
- Create: `lib/features/player_profile/domain/entities/overview_data.dart`

**Step 1: Create PlayerProfile entity**

```dart
import 'package:equatable/equatable.dart';

class PlayerProfile extends Equatable {
  const PlayerProfile({
    required this.puuid,
    required this.gameName,
    required this.tagLine,
    required this.profileIconId,
    required this.tier,
    required this.rank,
    required this.leaguePoints,
    required this.wins,
    required this.losses,
  });

  final String puuid;
  final String gameName;
  final String tagLine;
  final int profileIconId;
  final String tier;
  final String rank;
  final int leaguePoints;
  final int wins;
  final int losses;

  double get winRate => (wins + losses) > 0 ? wins / (wins + losses) * 100 : 0;

  @override
  List<Object?> get props =>
      [puuid, gameName, tagLine, profileIconId, tier, rank, leaguePoints, wins, losses];
}
```

**Step 2: Create PlayerSummary entity**

```dart
import 'package:equatable/equatable.dart';

class PlayerSummary extends Equatable {
  const PlayerSummary({
    required this.games,
    required this.winRate,
    required this.kda,
    required this.csPerMin,
    required this.dpm,
  });

  final int games;
  final double winRate;
  final double kda;
  final double csPerMin;
  final int dpm;

  @override
  List<Object?> get props => [games, winRate, kda, csPerMin, dpm];
}
```

**Step 3: Create PlayerChampion entity**

```dart
import 'package:equatable/equatable.dart';

class PlayerChampion extends Equatable {
  const PlayerChampion({
    required this.name,
    required this.games,
    required this.winRate,
    required this.iconId,
  });

  final String name;
  final int games;
  final double winRate;
  final int iconId;

  @override
  List<Object?> get props => [name, games, winRate, iconId];
}
```

**Step 4: Create PlayerRole entity**

```dart
import 'package:equatable/equatable.dart';

class PlayerRole extends Equatable {
  const PlayerRole({
    required this.role,
    required this.games,
    required this.winRate,
  });

  final String role;
  final int games;
  final double winRate;

  @override
  List<Object?> get props => [role, games, winRate];
}
```

**Step 5: Create PlayerActivity entity (stub for future tab)**

```dart
import 'package:equatable/equatable.dart';

class PlayerActivity extends Equatable {
  const PlayerActivity({required this.raw});

  final Map<String, dynamic> raw;

  @override
  List<Object?> get props => [];
}
```

**Step 6: Create OverviewData composite entity**

```dart
import 'package:equatable/equatable.dart';
import 'player_summary.dart';
import 'player_champion.dart';
import 'player_role.dart';
import 'player_activity.dart';

class OverviewData extends Equatable {
  const OverviewData({
    required this.summary,
    required this.champions,
    required this.roles,
    required this.activity,
  });

  final PlayerSummary summary;
  final List<PlayerChampion> champions;
  final List<PlayerRole> roles;
  final PlayerActivity activity;

  @override
  List<Object?> get props => [summary, champions, roles, activity];
}
```

**Step 7: Verify**

Run: `flutter analyze`
Expected: No issues found

**Hora do commit** — adicionamos entities do player_profile (PlayerProfile, PlayerSummary, PlayerChampion, PlayerRole, PlayerActivity, OverviewData).

---

### Task 2: Data Models + Tests

**Files:**
- Create: `lib/features/player_profile/data/models/player_profile_model.dart`
- Create: `lib/features/player_profile/data/models/player_summary_model.dart`
- Create: `lib/features/player_profile/data/models/player_champion_model.dart`
- Create: `lib/features/player_profile/data/models/player_role_model.dart`
- Create: `lib/features/player_profile/data/models/player_activity_model.dart`
- Create: `test/features/player_profile/data/models/player_profile_model_test.dart`
- Create: `test/features/player_profile/data/models/player_summary_model_test.dart`
- Create: `test/features/player_profile/data/models/player_champion_model_test.dart`
- Create: `test/features/player_profile/data/models/player_role_model_test.dart`

**Step 1: Create PlayerProfileModel**

```dart
import '../../domain/entities/player_profile.dart';

class PlayerProfileModel extends PlayerProfile {
  const PlayerProfileModel({
    required super.puuid,
    required super.gameName,
    required super.tagLine,
    required super.profileIconId,
    required super.tier,
    required super.rank,
    required super.leaguePoints,
    required super.wins,
    required super.losses,
  });

  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    return PlayerProfileModel(
      puuid: json['puuid'] as String,
      gameName: json['gameName'] as String,
      tagLine: json['tagLine'] as String,
      profileIconId: json['profileIconId'] as int,
      tier: json['tier'] as String,
      rank: json['rank'] as String,
      leaguePoints: json['leaguePoints'] as int,
      wins: json['wins'] as int,
      losses: json['losses'] as int,
    );
  }
}
```

**Step 2: Create PlayerSummaryModel**

```dart
import '../../domain/entities/player_summary.dart';

class PlayerSummaryModel extends PlayerSummary {
  const PlayerSummaryModel({
    required super.games,
    required super.winRate,
    required super.kda,
    required super.csPerMin,
    required super.dpm,
  });

  factory PlayerSummaryModel.fromJson(Map<String, dynamic> json) {
    return PlayerSummaryModel(
      games: json['games'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      kda: (json['kda'] as num).toDouble(),
      csPerMin: (json['csPerMin'] as num).toDouble(),
      dpm: json['dpm'] as int,
    );
  }
}
```

**Step 3: Create PlayerChampionModel**

```dart
import '../../domain/entities/player_champion.dart';

class PlayerChampionModel extends PlayerChampion {
  const PlayerChampionModel({
    required super.name,
    required super.games,
    required super.winRate,
    required super.iconId,
  });

  factory PlayerChampionModel.fromJson(Map<String, dynamic> json) {
    return PlayerChampionModel(
      name: json['name'] as String,
      games: json['games'] as int,
      winRate: (json['winRate'] as num).toDouble(),
      iconId: json['iconId'] as int,
    );
  }
}
```

**Step 4: Create PlayerRoleModel**

```dart
import '../../domain/entities/player_role.dart';

class PlayerRoleModel extends PlayerRole {
  const PlayerRoleModel({
    required super.role,
    required super.games,
    required super.winRate,
  });

  factory PlayerRoleModel.fromJson(Map<String, dynamic> json) {
    return PlayerRoleModel(
      role: json['role'] as String,
      games: json['games'] as int,
      winRate: (json['winRate'] as num).toDouble(),
    );
  }
}
```

**Step 5: Create PlayerActivityModel (stub)**

```dart
import '../../domain/entities/player_activity.dart';

class PlayerActivityModel extends PlayerActivity {
  const PlayerActivityModel({required super.raw});

  factory PlayerActivityModel.fromJson(Map<String, dynamic> json) {
    return PlayerActivityModel(raw: json);
  }
}
```

**Step 6: Write test for PlayerProfileModel**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_profile_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_profile.dart';

void main() {
  const tModel = PlayerProfileModel(
    puuid: 'test-puuid-123',
    gameName: 'UrienMano',
    tagLine: 'BR1',
    profileIconId: 1234,
    tier: 'CHALLENGER',
    rank: 'I',
    leaguePoints: 1234,
    wins: 150,
    losses: 120,
  );

  const tJson = {
    'puuid': 'test-puuid-123',
    'gameName': 'UrienMano',
    'tagLine': 'BR1',
    'profileIconId': 1234,
    'tier': 'CHALLENGER',
    'rank': 'I',
    'leaguePoints': 1234,
    'wins': 150,
    'losses': 120,
  };

  test('should be a subclass of PlayerProfile', () {
    expect(tModel, isA<PlayerProfile>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerProfileModel.fromJson(tJson);
    expect(result, equals(tModel));
  });

  test('should calculate winRate correctly', () {
    expect(tModel.winRate, closeTo(55.56, 0.01));
  });
}
```

**Step 7: Write test for PlayerSummaryModel**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_summary_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_summary.dart';

void main() {
  const tModel = PlayerSummaryModel(
    games: 270,
    winRate: 55.6,
    kda: 3.42,
    csPerMin: 7.8,
    dpm: 624,
  );

  const tJson = {
    'games': 270,
    'winRate': 55.6,
    'kda': 3.42,
    'csPerMin': 7.8,
    'dpm': 624,
  };

  test('should be a subclass of PlayerSummary', () {
    expect(tModel, isA<PlayerSummary>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerSummaryModel.fromJson(tJson);
    expect(result, equals(tModel));
  });

  test('should handle int values for double fields', () {
    final json = {
      'games': 270,
      'winRate': 55,
      'kda': 3,
      'csPerMin': 7,
      'dpm': 624,
    };
    final result = PlayerSummaryModel.fromJson(json);
    expect(result.winRate, 55.0);
    expect(result.kda, 3.0);
  });
}
```

**Step 8: Write test for PlayerChampionModel**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_champion_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_champion.dart';

void main() {
  const tModel = PlayerChampionModel(
    name: 'Ahri',
    games: 68,
    winRate: 61.8,
    iconId: 103,
  );

  const tJson = {
    'name': 'Ahri',
    'games': 68,
    'winRate': 61.8,
    'iconId': 103,
  };

  test('should be a subclass of PlayerChampion', () {
    expect(tModel, isA<PlayerChampion>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerChampionModel.fromJson(tJson);
    expect(result, equals(tModel));
  });
}
```

**Step 9: Write test for PlayerRoleModel**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_role_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_role.dart';

void main() {
  const tModel = PlayerRoleModel(
    role: 'MID',
    games: 142,
    winRate: 58.0,
  );

  const tJson = {
    'role': 'MID',
    'games': 142,
    'winRate': 58.0,
  };

  test('should be a subclass of PlayerRole', () {
    expect(tModel, isA<PlayerRole>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerRoleModel.fromJson(tJson);
    expect(result, equals(tModel));
  });
}
```

**Step 10: Run all model tests**

Run: `flutter test test/features/player_profile/data/models/`
Expected: All tests pass

**Hora do commit** — adicionamos models do player_profile com fromJson e testes.

---

### Task 3: DataSource

**Files:**
- Create: `lib/features/player_profile/data/datasources/player_profile_remote_datasource.dart`

**Step 1: Create the remote datasource with all API calls**

```dart
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/player_profile_model.dart';
import '../models/player_summary_model.dart';
import '../models/player_champion_model.dart';
import '../models/player_role_model.dart';
import '../models/player_activity_model.dart';

@lazySingleton
class PlayerProfileRemoteDataSource {
  const PlayerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PlayerProfileModel> getPlayerProfile({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerProfile(puuid),
    );
    return PlayerProfileModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PlayerSummaryModel> getPlayerSummary({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerSummary(puuid),
    );
    return PlayerSummaryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<PlayerChampionModel>> getPlayerChampions({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerChampions(puuid),
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PlayerChampionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PlayerRoleModel>> getPlayerRoles({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerRoles(puuid),
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PlayerRoleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PlayerActivityModel> getPlayerActivity({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerActivity(puuid),
    );
    return PlayerActivityModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
```

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues found

**Hora do commit** — adicionamos PlayerProfileRemoteDataSource com 5 metodos GET.

---

### Task 4: Repository (abstract + impl + test)

**Files:**
- Create: `lib/features/player_profile/domain/repositories/player_profile_repository.dart`
- Create: `lib/features/player_profile/data/repositories/player_profile_repository_impl.dart`
- Create: `test/features/player_profile/data/repositories/player_profile_repository_impl_test.dart`

**Step 1: Create abstract repository**

```dart
import '../entities/player_profile.dart';
import '../entities/player_summary.dart';
import '../entities/player_champion.dart';
import '../entities/player_role.dart';
import '../entities/player_activity.dart';

abstract class PlayerProfileRepository {
  Future<PlayerProfile> getPlayerProfile({required String puuid});
  Future<PlayerSummary> getPlayerSummary({required String puuid});
  Future<List<PlayerChampion>> getPlayerChampions({required String puuid});
  Future<List<PlayerRole>> getPlayerRoles({required String puuid});
  Future<PlayerActivity> getPlayerActivity({required String puuid});
}
```

**Step 2: Create repository implementation**

```dart
import 'package:injectable/injectable.dart';
import '../../domain/entities/player_profile.dart';
import '../../domain/entities/player_summary.dart';
import '../../domain/entities/player_champion.dart';
import '../../domain/entities/player_role.dart';
import '../../domain/entities/player_activity.dart';
import '../../domain/repositories/player_profile_repository.dart';
import '../datasources/player_profile_remote_datasource.dart';

@LazySingleton(as: PlayerProfileRepository)
class PlayerProfileRepositoryImpl implements PlayerProfileRepository {
  const PlayerProfileRepositoryImpl(this._remoteDataSource);

  final PlayerProfileRemoteDataSource _remoteDataSource;

  @override
  Future<PlayerProfile> getPlayerProfile({required String puuid}) {
    return _remoteDataSource.getPlayerProfile(puuid: puuid);
  }

  @override
  Future<PlayerSummary> getPlayerSummary({required String puuid}) {
    return _remoteDataSource.getPlayerSummary(puuid: puuid);
  }

  @override
  Future<List<PlayerChampion>> getPlayerChampions({required String puuid}) {
    return _remoteDataSource.getPlayerChampions(puuid: puuid);
  }

  @override
  Future<List<PlayerRole>> getPlayerRoles({required String puuid}) {
    return _remoteDataSource.getPlayerRoles(puuid: puuid);
  }

  @override
  Future<PlayerActivity> getPlayerActivity({required String puuid}) {
    return _remoteDataSource.getPlayerActivity(puuid: puuid);
  }
}
```

**Step 3: Write repository test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/datasources/player_profile_remote_datasource.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_profile_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_summary_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_champion_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_role_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_activity_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/repositories/player_profile_repository_impl.dart';

class MockRemoteDataSource extends Mock
    implements PlayerProfileRemoteDataSource {}

void main() {
  late PlayerProfileRepositoryImpl repository;
  late MockRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockRemoteDataSource();
    repository = PlayerProfileRepositoryImpl(mockDataSource);
  });

  const tPuuid = 'test-puuid-123';

  const tProfile = PlayerProfileModel(
    puuid: tPuuid,
    gameName: 'UrienMano',
    tagLine: 'BR1',
    profileIconId: 1234,
    tier: 'CHALLENGER',
    rank: 'I',
    leaguePoints: 1234,
    wins: 150,
    losses: 120,
  );

  const tSummary = PlayerSummaryModel(
    games: 270,
    winRate: 55.6,
    kda: 3.42,
    csPerMin: 7.8,
    dpm: 624,
  );

  test('should return PlayerProfile when getPlayerProfile succeeds', () async {
    when(() => mockDataSource.getPlayerProfile(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tProfile);

    final result = await repository.getPlayerProfile(puuid: tPuuid);

    expect(result, tProfile);
    verify(() => mockDataSource.getPlayerProfile(puuid: tPuuid)).called(1);
  });

  test('should return PlayerSummary when getPlayerSummary succeeds', () async {
    when(() => mockDataSource.getPlayerSummary(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tSummary);

    final result = await repository.getPlayerSummary(puuid: tPuuid);

    expect(result, tSummary);
    verify(() => mockDataSource.getPlayerSummary(puuid: tPuuid)).called(1);
  });

  test('should return champion list when getPlayerChampions succeeds', () async {
    const tChampions = [
      PlayerChampionModel(name: 'Ahri', games: 68, winRate: 61.8, iconId: 103),
    ];
    when(() => mockDataSource.getPlayerChampions(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tChampions);

    final result = await repository.getPlayerChampions(puuid: tPuuid);

    expect(result, tChampions);
  });

  test('should return role list when getPlayerRoles succeeds', () async {
    const tRoles = [
      PlayerRoleModel(role: 'MID', games: 142, winRate: 58.0),
    ];
    when(() => mockDataSource.getPlayerRoles(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tRoles);

    final result = await repository.getPlayerRoles(puuid: tPuuid);

    expect(result, tRoles);
  });

  test('should return activity when getPlayerActivity succeeds', () async {
    const tActivity = PlayerActivityModel(raw: {});
    when(() => mockDataSource.getPlayerActivity(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tActivity);

    final result = await repository.getPlayerActivity(puuid: tPuuid);

    expect(result, tActivity);
  });
}
```

**Step 4: Run tests**

Run: `flutter test test/features/player_profile/data/repositories/`
Expected: 5 tests pass

**Hora do commit** — adicionamos repository abstrato e implementacao do player_profile com testes.

---

### Task 5: UseCases + Tests

**Files:**
- Create: `lib/features/player_profile/domain/usecases/get_player_profile.dart`
- Create: `lib/features/player_profile/domain/usecases/get_player_overview.dart`
- Create: `test/features/player_profile/domain/usecases/get_player_profile_test.dart`
- Create: `test/features/player_profile/domain/usecases/get_player_overview_test.dart`

**Step 1: Create GetPlayerProfile usecase**

```dart
import 'package:injectable/injectable.dart';
import '../entities/player_profile.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class GetPlayerProfile {
  const GetPlayerProfile(this._repository);

  final PlayerProfileRepository _repository;

  Future<PlayerProfile> call({required String puuid}) {
    return _repository.getPlayerProfile(puuid: puuid);
  }
}
```

**Step 2: Create GetPlayerOverview usecase (Future.wait)**

```dart
import 'package:injectable/injectable.dart';
import '../entities/overview_data.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class GetPlayerOverview {
  const GetPlayerOverview(this._repository);

  final PlayerProfileRepository _repository;

  Future<OverviewData> call({required String puuid}) async {
    final results = await Future.wait([
      _repository.getPlayerSummary(puuid: puuid),
      _repository.getPlayerChampions(puuid: puuid),
      _repository.getPlayerRoles(puuid: puuid),
      _repository.getPlayerActivity(puuid: puuid),
    ]);

    return OverviewData(
      summary: results[0] as dynamic,
      champions: results[1] as dynamic,
      roles: results[2] as dynamic,
      activity: results[3] as dynamic,
    );
  }
}
```

**Step 3: Write test for GetPlayerProfile**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_profile.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/repositories/player_profile_repository.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_profile.dart';

class MockPlayerProfileRepository extends Mock
    implements PlayerProfileRepository {}

void main() {
  late GetPlayerProfile useCase;
  late MockPlayerProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerProfileRepository();
    useCase = GetPlayerProfile(mockRepository);
  });

  const tProfile = PlayerProfile(
    puuid: 'test-puuid-123',
    gameName: 'UrienMano',
    tagLine: 'BR1',
    profileIconId: 1234,
    tier: 'CHALLENGER',
    rank: 'I',
    leaguePoints: 1234,
    wins: 150,
    losses: 120,
  );

  test('should return PlayerProfile from the repository', () async {
    when(() => mockRepository.getPlayerProfile(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tProfile);

    final result = await useCase(puuid: 'test-puuid-123');

    expect(result, tProfile);
    verify(() => mockRepository.getPlayerProfile(puuid: 'test-puuid-123'))
        .called(1);
  });
}
```

**Step 4: Write test for GetPlayerOverview**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_summary.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_champion.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_role.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_activity.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/repositories/player_profile_repository.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_overview.dart';

class MockPlayerProfileRepository extends Mock
    implements PlayerProfileRepository {}

void main() {
  late GetPlayerOverview useCase;
  late MockPlayerProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockPlayerProfileRepository();
    useCase = GetPlayerOverview(mockRepository);
  });

  const tPuuid = 'test-puuid-123';

  const tSummary = PlayerSummary(
    games: 270, winRate: 55.6, kda: 3.42, csPerMin: 7.8, dpm: 624,
  );
  const tChampions = [
    PlayerChampion(name: 'Ahri', games: 68, winRate: 61.8, iconId: 103),
  ];
  const tRoles = [
    PlayerRole(role: 'MID', games: 142, winRate: 58.0),
  ];
  const tActivity = PlayerActivity(raw: {});

  test('should call all 4 repository methods and return OverviewData', () async {
    when(() => mockRepository.getPlayerSummary(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tSummary);
    when(() => mockRepository.getPlayerChampions(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tChampions);
    when(() => mockRepository.getPlayerRoles(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tRoles);
    when(() => mockRepository.getPlayerActivity(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tActivity);

    final result = await useCase(puuid: tPuuid);

    expect(result.summary, tSummary);
    expect(result.champions, tChampions);
    expect(result.roles, tRoles);
    expect(result.activity, tActivity);
    verify(() => mockRepository.getPlayerSummary(puuid: tPuuid)).called(1);
    verify(() => mockRepository.getPlayerChampions(puuid: tPuuid)).called(1);
    verify(() => mockRepository.getPlayerRoles(puuid: tPuuid)).called(1);
    verify(() => mockRepository.getPlayerActivity(puuid: tPuuid)).called(1);
  });

  test('should throw when any parallel call fails', () async {
    when(() => mockRepository.getPlayerSummary(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tSummary);
    when(() => mockRepository.getPlayerChampions(puuid: any(named: 'puuid')))
        .thenThrow(Exception('Network error'));
    when(() => mockRepository.getPlayerRoles(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tRoles);
    when(() => mockRepository.getPlayerActivity(puuid: any(named: 'puuid')))
        .thenAnswer((_) async => tActivity);

    expect(() => useCase(puuid: tPuuid), throwsA(isA<Exception>()));
  });
}
```

**Step 5: Run tests**

Run: `flutter test test/features/player_profile/domain/usecases/`
Expected: 3 tests pass

**Hora do commit** — adicionamos usecases GetPlayerProfile e GetPlayerOverview (com Future.wait) e testes.

---

### Task 6: PlayerProfileBloc (header + polling)

**Files:**
- Create: `lib/features/player_profile/presentation/bloc/player_profile_event.dart`
- Create: `lib/features/player_profile/presentation/bloc/player_profile_state.dart`
- Create: `lib/features/player_profile/presentation/bloc/player_profile_bloc.dart`
- Create: `test/features/player_profile/presentation/bloc/player_profile_bloc_test.dart`

**Step 1: Create events**

```dart
import 'package:equatable/equatable.dart';

sealed class PlayerProfileEvent extends Equatable {
  const PlayerProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends PlayerProfileEvent {
  const ProfileStarted({required this.puuid});

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}

class ProfileStatusPolled extends PlayerProfileEvent {
  const ProfileStatusPolled();
}

class ProfileStatusStopped extends PlayerProfileEvent {
  const ProfileStatusStopped();
}
```

**Step 2: Create states**

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/player_profile.dart';
import '../../../player_search/domain/entities/processing_status.dart';

sealed class PlayerProfileState extends Equatable {
  const PlayerProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends PlayerProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends PlayerProfileState {
  const ProfileLoaded({
    required this.player,
    this.processingStatus,
  });

  final PlayerProfile player;
  final ProcessingStatus? processingStatus;

  bool get isProcessing =>
      processingStatus != null &&
      processingStatus!.status == UpdateStatus.updating;

  @override
  List<Object?> get props => [player, processingStatus];
}

class ProfileError extends PlayerProfileState {
  const ProfileError(this.message);

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
import '../../../player_search/domain/entities/processing_status.dart';
import '../../../player_search/domain/usecases/get_player_status.dart';
import '../../domain/usecases/get_player_profile.dart';
import 'player_profile_event.dart';
import 'player_profile_state.dart';

@injectable
class PlayerProfileBloc
    extends Bloc<PlayerProfileEvent, PlayerProfileState> {
  PlayerProfileBloc(this._getPlayerProfile, this._getPlayerStatus)
      : super(const ProfileLoading()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileStatusPolled>(_onStatusPolled);
    on<ProfileStatusStopped>(_onStatusStopped);
  }

  final GetPlayerProfile _getPlayerProfile;
  final GetPlayerStatus _getPlayerStatus;
  Timer? _timer;
  String? _puuid;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<PlayerProfileState> emit,
  ) async {
    _puuid = event.puuid;
    try {
      final player = await _getPlayerProfile(puuid: event.puuid);
      emit(ProfileLoaded(player: player));
      _startPolling();
    } on ApiException catch (e) {
      emit(ProfileError(e.message));
    } catch (_) {
      emit(const ProfileError('Erro ao carregar perfil.'));
    }
  }

  Future<void> _onStatusPolled(
    ProfileStatusPolled event,
    Emitter<PlayerProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    try {
      final status = await _getPlayerStatus(puuid: _puuid!);
      if (status.status == UpdateStatus.idle) {
        _timer?.cancel();
        emit(ProfileLoaded(player: current.player, processingStatus: null));
      } else {
        emit(ProfileLoaded(
          player: current.player,
          processingStatus: status,
        ));
      }
    } on ApiException {
      // Silent retry on next poll cycle
    }
  }

  void _onStatusStopped(
    ProfileStatusStopped event,
    Emitter<PlayerProfileState> emit,
  ) {
    _timer?.cancel();
  }

  void _startPolling() {
    _timer?.cancel();
    if (!isClosed) add(const ProfileStatusPolled());
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isClosed) add(const ProfileStatusPolled());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
```

**Step 4: Write tests**

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_profile.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_profile.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_bloc.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_event.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_state.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/get_player_status.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockGetPlayerProfile extends Mock implements GetPlayerProfile {}

class MockGetPlayerStatus extends Mock implements GetPlayerStatus {}

void main() {
  late PlayerProfileBloc bloc;
  late MockGetPlayerProfile mockGetPlayerProfile;
  late MockGetPlayerStatus mockGetPlayerStatus;

  setUp(() {
    mockGetPlayerProfile = MockGetPlayerProfile();
    mockGetPlayerStatus = MockGetPlayerStatus();
    bloc = PlayerProfileBloc(mockGetPlayerProfile, mockGetPlayerStatus);
  });

  tearDown(() => bloc.close());

  const tPuuid = 'test-puuid-123';

  const tProfile = PlayerProfile(
    puuid: tPuuid,
    gameName: 'UrienMano',
    tagLine: 'BR1',
    profileIconId: 1234,
    tier: 'CHALLENGER',
    rank: 'I',
    leaguePoints: 1234,
    wins: 150,
    losses: 120,
  );

  const tStatusUpdating = ProcessingStatus(
    status: UpdateStatus.updating,
    matchesProcessed: 5,
    matchesTotal: 20,
    message: 'Processing',
  );

  const tStatusIdle = ProcessingStatus(
    status: UpdateStatus.idle,
    matchesProcessed: 20,
    matchesTotal: 20,
    message: 'Done',
  );

  test('initial state should be ProfileLoading', () {
    expect(bloc.state, const ProfileLoading());
  });

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'emits [ProfileLoaded] when profile loads successfully, then polls status',
    build: () {
      when(() => mockGetPlayerProfile(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tProfile);
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tStatusUpdating);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProfileStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 200),
    expect: () => [
      const ProfileLoaded(player: tProfile),
      const ProfileLoaded(player: tProfile, processingStatus: tStatusUpdating),
    ],
  );

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'emits [ProfileLoaded] with null status when polling returns IDLE',
    build: () {
      when(() => mockGetPlayerProfile(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tProfile);
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tStatusIdle);
      return bloc;
    },
    act: (bloc) => bloc.add(const ProfileStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 200),
    expect: () => [
      const ProfileLoaded(player: tProfile),
      const ProfileLoaded(player: tProfile, processingStatus: null),
    ],
  );

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'emits [ProfileError] when profile load fails',
    build: () {
      when(() => mockGetPlayerProfile(puuid: any(named: 'puuid')))
          .thenThrow(const NotFoundException());
      return bloc;
    },
    act: (bloc) => bloc.add(const ProfileStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      const ProfileError('Recurso nao encontrado.'),
    ],
  );

  blocTest<PlayerProfileBloc, PlayerProfileState>(
    'silently retries when status polling throws',
    build: () {
      when(() => mockGetPlayerProfile(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tProfile);
      when(() => mockGetPlayerStatus(puuid: any(named: 'puuid')))
          .thenThrow(const ServerException());
      return bloc;
    },
    act: (bloc) => bloc.add(const ProfileStarted(puuid: tPuuid)),
    wait: const Duration(milliseconds: 200),
    expect: () => [
      const ProfileLoaded(player: tProfile),
    ],
  );
}
```

**Step 5: Run tests**

Run: `flutter test test/features/player_profile/presentation/bloc/player_profile_bloc_test.dart`
Expected: 5 tests pass

**Hora do commit** — adicionamos PlayerProfileBloc com carregamento de header e polling de status.

---

### Task 7: PlayerOverviewBloc

**Files:**
- Create: `lib/features/player_profile/presentation/bloc/player_overview_event.dart`
- Create: `lib/features/player_profile/presentation/bloc/player_overview_state.dart`
- Create: `lib/features/player_profile/presentation/bloc/player_overview_bloc.dart`
- Create: `test/features/player_profile/presentation/bloc/player_overview_bloc_test.dart`

**Step 1: Create events**

```dart
import 'package:equatable/equatable.dart';

sealed class PlayerOverviewEvent extends Equatable {
  const PlayerOverviewEvent();

  @override
  List<Object?> get props => [];
}

class OverviewStarted extends PlayerOverviewEvent {
  const OverviewStarted({required this.puuid});

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}
```

**Step 2: Create states**

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/overview_data.dart';

sealed class PlayerOverviewState extends Equatable {
  const PlayerOverviewState();

  @override
  List<Object?> get props => [];
}

class OverviewLoading extends PlayerOverviewState {
  const OverviewLoading();
}

class OverviewLoaded extends PlayerOverviewState {
  const OverviewLoaded(this.data);

  final OverviewData data;

  @override
  List<Object?> get props => [data];
}

class OverviewError extends PlayerOverviewState {
  const OverviewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
```

**Step 3: Create the BLoC**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/get_player_overview.dart';
import 'player_overview_event.dart';
import 'player_overview_state.dart';

@injectable
class PlayerOverviewBloc
    extends Bloc<PlayerOverviewEvent, PlayerOverviewState> {
  PlayerOverviewBloc(this._getPlayerOverview)
      : super(const OverviewLoading()) {
    on<OverviewStarted>(_onStarted);
  }

  final GetPlayerOverview _getPlayerOverview;

  Future<void> _onStarted(
    OverviewStarted event,
    Emitter<PlayerOverviewState> emit,
  ) async {
    emit(const OverviewLoading());
    try {
      final data = await _getPlayerOverview(puuid: event.puuid);
      emit(OverviewLoaded(data));
    } on ApiException catch (e) {
      emit(OverviewError(e.message));
    } catch (_) {
      emit(const OverviewError('Erro ao carregar dados.'));
    }
  }
}
```

**Step 4: Write tests**

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/overview_data.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_summary.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_champion.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_role.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_activity.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_overview.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_overview_bloc.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_overview_event.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_overview_state.dart';
import 'package:high_br_lol_mobile/core/network/api_exception.dart';

class MockGetPlayerOverview extends Mock implements GetPlayerOverview {}

void main() {
  late PlayerOverviewBloc bloc;
  late MockGetPlayerOverview mockGetPlayerOverview;

  setUp(() {
    mockGetPlayerOverview = MockGetPlayerOverview();
    bloc = PlayerOverviewBloc(mockGetPlayerOverview);
  });

  tearDown(() => bloc.close());

  const tPuuid = 'test-puuid-123';

  const tOverview = OverviewData(
    summary: PlayerSummary(
      games: 270, winRate: 55.6, kda: 3.42, csPerMin: 7.8, dpm: 624,
    ),
    champions: [
      PlayerChampion(name: 'Ahri', games: 68, winRate: 61.8, iconId: 103),
    ],
    roles: [
      PlayerRole(role: 'MID', games: 142, winRate: 58.0),
    ],
    activity: PlayerActivity(raw: {}),
  );

  test('initial state should be OverviewLoading', () {
    expect(bloc.state, const OverviewLoading());
  });

  blocTest<PlayerOverviewBloc, PlayerOverviewState>(
    'emits [OverviewLoading, OverviewLoaded] when overview loads',
    build: () {
      when(() => mockGetPlayerOverview(puuid: any(named: 'puuid')))
          .thenAnswer((_) async => tOverview);
      return bloc;
    },
    act: (bloc) => bloc.add(const OverviewStarted(puuid: tPuuid)),
    expect: () => [
      const OverviewLoading(),
      const OverviewLoaded(tOverview),
    ],
  );

  blocTest<PlayerOverviewBloc, PlayerOverviewState>(
    'emits [OverviewLoading, OverviewError] when overview fails',
    build: () {
      when(() => mockGetPlayerOverview(puuid: any(named: 'puuid')))
          .thenThrow(const ServerException());
      return bloc;
    },
    act: (bloc) => bloc.add(const OverviewStarted(puuid: tPuuid)),
    expect: () => [
      const OverviewLoading(),
      const OverviewError('Erro no servidor. Tente novamente.'),
    ],
  );
}
```

**Step 5: Run tests**

Run: `flutter test test/features/player_profile/presentation/bloc/player_overview_bloc_test.dart`
Expected: 3 tests pass

**Hora do commit** — adicionamos PlayerOverviewBloc com Future.wait paralelo e testes.

---

### Task 8: Regenerate DI

**Step 1: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`

Expected: `injection.config.dart` regenerated with new registrations:
- `PlayerProfileRemoteDataSource` (@lazySingleton)
- `PlayerProfileRepositoryImpl` (@lazySingleton as PlayerProfileRepository)
- `GetPlayerProfile` (@lazySingleton)
- `GetPlayerOverview` (@lazySingleton)
- `PlayerProfileBloc` (@injectable / factory)
- `PlayerOverviewBloc` (@injectable / factory)

**Step 2: Verify**

Run: `flutter analyze`
Expected: No issues found

Run: `flutter test`
Expected: All tests pass (existing + new)

**Hora do commit** — regeneramos injection.config.dart com dependencias do player_profile.

---

### Task 9: Presentation Widgets (header + banner + tabs)

**Files:**
- Create: `lib/features/player_profile/presentation/widgets/profile_header.dart`
- Create: `lib/features/player_profile/presentation/widgets/processing_banner.dart`
- Create: `lib/features/player_profile/presentation/widgets/profile_tabs.dart`

**Step 1: Create ProfileHeader widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.player});

  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  '${player.gameName}#${player.tagLine}',
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // Rank row
                Row(
                  children: [
                    // Tier badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _tierColor(player.tier),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _tierAbbrev(player.tier),
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${player.tier} ${player.leaguePoints} LP',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // WL row
                Row(
                  children: [
                    Text(
                      '${player.wins}W ${player.losses}L',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '·',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.winRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _tierColor(String tier) {
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

  static String _tierAbbrev(String tier) {
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
}
```

**Step 2: Create ProcessingBanner widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../player_search/domain/entities/processing_status.dart';

class ProcessingBanner extends StatelessWidget {
  const ProcessingBanner({super.key, required this.status});

  final ProcessingStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.accent.withOpacity(0.9),
      child: Row(
        children: [
          const Icon(Icons.sync, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Processando partidas... ${status.matchesProcessed}/${status.matchesTotal}',
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Create ProfileTabs widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileTabs extends StatelessWidget {
  const ProfileTabs({super.key, required this.selectedIndex});

  final int selectedIndex;

  static const _tabs = ['Overview', 'Champions', 'Matches', 'Atividade'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isActive = index == selectedIndex;
          return Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  height: 2,
                  color: isActive ? AppColors.accent : Colors.transparent,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
```

**Step 4: Verify**

Run: `flutter analyze`
Expected: No issues found

**Hora do commit** — adicionamos widgets ProfileHeader, ProcessingBanner e ProfileTabs.

---

### Task 10: Presentation Widgets (overview content)

**Files:**
- Create: `lib/features/player_profile/presentation/widgets/general_stats_row.dart`
- Create: `lib/features/player_profile/presentation/widgets/role_distribution_card.dart`
- Create: `lib/features/player_profile/presentation/widgets/top_champions_card.dart`
- Create: `lib/features/player_profile/presentation/widgets/overview_content.dart`

**Step 1: Create GeneralStatsRow widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_summary.dart';

class GeneralStatsRow extends StatelessWidget {
  const GeneralStatsRow({super.key, required this.summary});

  final PlayerSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          value: '${summary.games}',
          label: 'Games',
          valueColor: AppColors.textPrimary,
        ),
        const SizedBox(width: 6),
        _StatCard(
          value: '${summary.winRate.toStringAsFixed(1)}%',
          label: 'WR',
          valueColor: AppColors.accent,
        ),
        const SizedBox(width: 6),
        _StatCard(
          value: summary.kda.toStringAsFixed(2),
          label: 'KDA',
          valueColor: const Color(0xFF60A5FA),
        ),
        const SizedBox(width: 6),
        _StatCard(
          value: summary.csPerMin.toStringAsFixed(1),
          label: 'CS/m',
          valueColor: AppColors.textPrimary,
        ),
        const SizedBox(width: 6),
        _StatCard(
          value: '${summary.dpm}',
          label: 'DPM',
          valueColor: AppColors.textPrimary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Create RoleDistributionCard widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_role.dart';

class RoleDistributionCard extends StatelessWidget {
  const RoleDistributionCard({super.key, required this.roles});

  final List<PlayerRole> roles;

  @override
  Widget build(BuildContext context) {
    final maxGames = roles.isNotEmpty
        ? roles.map((r) => r.games).reduce((a, b) => a > b ? a : b)
        : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: roles.map((role) {
          final barFraction = maxGames > 0 ? role.games / maxGames : 0.0;
          return Padding(
            padding: EdgeInsets.only(
              bottom: role == roles.last ? 0 : 8,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    role.role,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.bgTertiary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 16,
                            width: constraints.maxWidth * barFraction,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(
                                0.3 + 0.7 * barFraction,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${role.games}  ${role.winRate.toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

**Step 3: Create TopChampionsCard widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_champion.dart';

class TopChampionsCard extends StatelessWidget {
  const TopChampionsCard({super.key, required this.champions});

  final List<PlayerChampion> champions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: champions.map((champ) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                // Icon placeholder
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 10),
                // Name
                Expanded(
                  child: Text(
                    champ.name,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // Games
                Text(
                  '${champ.games}',
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                // WR
                SizedBox(
                  width: 48,
                  child: Text(
                    '${champ.winRate.toStringAsFixed(1)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _wrColor(champ.winRate),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static Color _wrColor(double wr) {
    if (wr >= 55) return AppColors.accent;
    if (wr >= 50) return const Color(0xFF60A5FA);
    if (wr >= 45) return AppColors.textPrimary;
    return AppColors.loss;
  }
}
```

**Step 4: Create OverviewContent composite widget**

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/overview_data.dart';
import 'general_stats_row.dart';
import 'role_distribution_card.dart';
import 'top_champions_card.dart';

class OverviewContent extends StatelessWidget {
  const OverviewContent({super.key, required this.data});

  final OverviewData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Gerais
          _sectionLabel('STATS GERAIS'),
          const SizedBox(height: 8),
          GeneralStatsRow(summary: data.summary),
          const SizedBox(height: 16),
          // Role Distribution
          _sectionLabel('DISTRIBUICAO DE ROLES'),
          const SizedBox(height: 8),
          RoleDistributionCard(roles: data.roles),
          const SizedBox(height: 16),
          // Top Champions
          _sectionLabel('TOP CHAMPIONS'),
          const SizedBox(height: 8),
          TopChampionsCard(champions: data.champions),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 2,
      ),
    );
  }
}
```

**Step 5: Verify**

Run: `flutter analyze`
Expected: No issues found

**Hora do commit** — adicionamos widgets de conteudo: GeneralStatsRow, RoleDistributionCard, TopChampionsCard, OverviewContent.

---

### Task 11: PlayerProfilePage + Router + Search navigation

**Files:**
- Create: `lib/features/player_profile/presentation/pages/player_profile_page.dart`
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/features/player_search/presentation/pages/player_search_page.dart`

**Step 1: Create PlayerProfilePage**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../bloc/player_profile_bloc.dart';
import '../bloc/player_profile_event.dart';
import '../bloc/player_profile_state.dart';
import '../bloc/player_overview_bloc.dart';
import '../bloc/player_overview_event.dart';
import '../bloc/player_overview_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/processing_banner.dart';
import '../widgets/profile_tabs.dart';
import '../widgets/overview_content.dart';

class PlayerProfilePage extends StatelessWidget {
  const PlayerProfilePage({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<PlayerProfileBloc>()
            ..add(ProfileStarted(puuid: puuid)),
        ),
        BlocProvider(
          create: (_) => getIt<PlayerOverviewBloc>()
            ..add(OverviewStarted(puuid: puuid)),
        ),
      ],
      child: const _PlayerProfileView(),
    );
  }
}

class _PlayerProfileView extends StatelessWidget {
  const _PlayerProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Back row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Perfil',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Header
            BlocBuilder<PlayerProfileBloc, PlayerProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const SizedBox(
                    height: 80,
                    child: LoadingIndicator(),
                  );
                }
                if (state is ProfileError) {
                  return ErrorDisplay(
                    message: state.message,
                    onRetry: () => context.read<PlayerProfileBloc>().add(
                          ProfileStarted(
                            puuid: (context.read<PlayerProfileBloc>()
                                    .state as ProfileError)
                                .message, // will re-trigger
                          ),
                        ),
                  );
                }
                if (state is ProfileLoaded) {
                  return Column(
                    children: [
                      ProfileHeader(player: state.player),
                      if (state.isProcessing)
                        ProcessingBanner(status: state.processingStatus!),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Tabs
            const ProfileTabs(selectedIndex: 0),
            // Body
            Expanded(
              child: BlocBuilder<PlayerOverviewBloc, PlayerOverviewState>(
                builder: (context, state) {
                  if (state is OverviewLoading) {
                    return const LoadingIndicator();
                  }
                  if (state is OverviewError) {
                    return ErrorDisplay(message: state.message);
                  }
                  if (state is OverviewLoaded) {
                    return OverviewContent(data: state.data);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Update app_router.dart**

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/player_search/presentation/pages/player_search_page.dart';
import '../../features/player_profile/presentation/pages/player_profile_page.dart';
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
                    return PlayerProfilePage(puuid: puuid);
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

**Step 3: Update PlayerSearchPage navigation**

In `lib/features/player_search/presentation/pages/player_search_page.dart`, change line 33-36 from:

```dart
context.go(
  '/search/player/${state.result.puuid}/processing',
  extra: state.result,
);
```

To:

```dart
context.go('/search/player/${state.result.puuid}');
```

Also remove the unused import at the top of the file if present (processing_status_page).

**Step 4: Verify**

Run: `flutter analyze`
Expected: No issues found

Run: `flutter test`
Expected: All tests pass

**Hora do commit** — adicionamos PlayerProfilePage, atualizamos router e navegacao da busca.

---

### Task 12: Full Verification

**Step 1: Run analyzer**

Run: `flutter analyze`
Expected: No issues found

**Step 2: Run all tests**

Run: `flutter test`
Expected: All tests pass. Count should include:
- Existing player_search tests (7)
- New player_profile model tests (~9)
- New repository tests (5)
- New usecase tests (3)
- New PlayerProfileBloc tests (5)
- New PlayerOverviewBloc tests (3)
- Total: ~32 tests

**Step 3: Verify file structure**

Run: `find lib/features/player_profile -type f | sort`
Expected:
```
lib/features/player_profile/data/datasources/player_profile_remote_datasource.dart
lib/features/player_profile/data/models/player_activity_model.dart
lib/features/player_profile/data/models/player_champion_model.dart
lib/features/player_profile/data/models/player_profile_model.dart
lib/features/player_profile/data/models/player_role_model.dart
lib/features/player_profile/data/models/player_summary_model.dart
lib/features/player_profile/data/repositories/player_profile_repository_impl.dart
lib/features/player_profile/domain/entities/overview_data.dart
lib/features/player_profile/domain/entities/player_activity.dart
lib/features/player_profile/domain/entities/player_champion.dart
lib/features/player_profile/domain/entities/player_profile.dart
lib/features/player_profile/domain/entities/player_role.dart
lib/features/player_profile/domain/entities/player_summary.dart
lib/features/player_profile/domain/repositories/player_profile_repository.dart
lib/features/player_profile/domain/usecases/get_player_overview.dart
lib/features/player_profile/domain/usecases/get_player_profile.dart
lib/features/player_profile/presentation/bloc/player_overview_bloc.dart
lib/features/player_profile/presentation/bloc/player_overview_event.dart
lib/features/player_profile/presentation/bloc/player_overview_state.dart
lib/features/player_profile/presentation/bloc/player_profile_bloc.dart
lib/features/player_profile/presentation/bloc/player_profile_event.dart
lib/features/player_profile/presentation/bloc/player_profile_state.dart
lib/features/player_profile/presentation/pages/player_profile_page.dart
lib/features/player_profile/presentation/widgets/general_stats_row.dart
lib/features/player_profile/presentation/widgets/overview_content.dart
lib/features/player_profile/presentation/widgets/processing_banner.dart
lib/features/player_profile/presentation/widgets/profile_header.dart
lib/features/player_profile/presentation/widgets/profile_tabs.dart
lib/features/player_profile/presentation/widgets/role_distribution_card.dart
lib/features/player_profile/presentation/widgets/top_champions_card.dart
```

**Hora do commit** — player profile overview tab finalizado e verificado.
