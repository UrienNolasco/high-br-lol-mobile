import 'package:injectable/injectable.dart';
import '../entities/sync_trigger_result.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class TriggerDeepSync {
  const TriggerDeepSync(this._repository);

  final PlayerProfileRepository _repository;

  Future<SyncTriggerResult> call({required String puuid}) {
    return _repository.triggerDeepSync(puuid: puuid);
  }
}
