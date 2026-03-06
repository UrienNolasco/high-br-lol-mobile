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
