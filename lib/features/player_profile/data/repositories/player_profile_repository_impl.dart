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
