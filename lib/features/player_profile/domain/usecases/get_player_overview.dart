import 'package:injectable/injectable.dart';
import '../entities/overview_data.dart';
import '../entities/player_summary.dart';
import '../entities/player_champion.dart';
import '../entities/player_role.dart';
import '../entities/player_activity.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class GetPlayerOverview {
  const GetPlayerOverview(this._repository);

  final PlayerProfileRepository _repository;

  Future<OverviewData> call({required String puuid}) async {
    final results = await Future.wait([
      _repository.getPlayerSummary(puuid: puuid),
      _repository.getPlayerChampions(puuid: puuid),
      _repository.getPlayerRoles(puuid: puuid),
      _repository.getPlayerActivity(puuid: puuid),
    ]);

    return OverviewData(
      summary: results[0] as PlayerSummary,
      champions: results[1] as List<PlayerChampion>,
      roles: results[2] as List<PlayerRole>,
      activity: results[3] as PlayerActivity,
    );
  }
}
