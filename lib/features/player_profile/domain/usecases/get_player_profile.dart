import 'package:injectable/injectable.dart';
import '../entities/player_profile.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class GetPlayerProfile {
  const GetPlayerProfile(this._repository);

  final PlayerProfileRepository _repository;

  Future<PlayerProfile> call({required String puuid}) {
    return _repository.getPlayerProfile(puuid: puuid);
  }
}
