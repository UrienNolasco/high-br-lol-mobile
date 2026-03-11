import 'package:injectable/injectable.dart';
import '../../../../features/player_search/domain/entities/processing_status.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class GetDeepSyncStatus {
  const GetDeepSyncStatus(this._repository);

  final PlayerProfileRepository _repository;

  Future<ProcessingStatus> call({required String puuid}) {
    return _repository.getDeepSyncStatus(puuid: puuid);
  }
}
