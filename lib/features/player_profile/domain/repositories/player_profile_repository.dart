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
