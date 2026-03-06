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
