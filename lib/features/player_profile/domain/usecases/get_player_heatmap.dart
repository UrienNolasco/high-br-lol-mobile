import 'package:injectable/injectable.dart';
import '../entities/heatmap_data.dart';
import '../repositories/player_profile_repository.dart';

@lazySingleton
class GetPlayerHeatmap {
  const GetPlayerHeatmap(this._repository);

  final PlayerProfileRepository _repository;

  Future<HeatmapData> call({required String puuid}) {
    return _repository.getPlayerHeatmap(puuid: puuid);
  }
}
