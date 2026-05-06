import '../entities/player_profile.dart';
import '../entities/player_summary.dart';
import '../entities/player_champion.dart';
import '../entities/player_role.dart';
import '../entities/player_activity.dart';
import '../entities/heatmap_data.dart';
import '../entities/sync_trigger_result.dart';
import '../../../player_search/domain/entities/processing_status.dart';

abstract class PlayerProfileRepository {
  Future<PlayerProfile> getPlayerProfile({required String puuid});
  Future<PlayerSummary> getPlayerSummary({required String puuid});
  Future<List<PlayerChampion>> getPlayerChampions({required String puuid});
  Future<List<PlayerRole>> getPlayerRoles({required String puuid});
  Future<PlayerActivity> getPlayerActivity({required String puuid});
  Future<HeatmapData> getPlayerHeatmap({required String puuid});
  Future<SyncTriggerResult> triggerDeepSync({required String puuid});
  Future<ProcessingStatus> getDeepSyncStatus({required String puuid});
}
