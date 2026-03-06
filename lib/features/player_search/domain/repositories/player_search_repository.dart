import '../entities/player_search_result.dart';

abstract class PlayerSearchRepository {
  Future<PlayerSearchResult> searchPlayer({
    required String gameName,
    required String tagLine,
  });
}
