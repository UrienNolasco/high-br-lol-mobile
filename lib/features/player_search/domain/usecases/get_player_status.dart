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
