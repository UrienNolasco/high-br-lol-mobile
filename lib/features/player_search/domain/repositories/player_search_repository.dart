import '../entities/player_search_result.dart';
import '../entities/processing_status.dart';

abstract class PlayerSearchRepository {
  Future<PlayerSearchResult> searchPlayer({
    required String gameName,
    required String tagLine,
  });

  Future<ProcessingStatus> getPlayerStatus({required String puuid});
}
