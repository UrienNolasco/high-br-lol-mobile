import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/player_profile_model.dart';
import '../models/player_summary_model.dart';
import '../models/player_champion_model.dart';
import '../models/player_role_model.dart';
import '../models/player_activity_model.dart';

@lazySingleton
class PlayerProfileRemoteDataSource {
  const PlayerProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PlayerProfileModel> getPlayerProfile({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerProfile(puuid),
    );
    return PlayerProfileModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PlayerSummaryModel> getPlayerSummary({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerSummary(puuid),
    );
    return PlayerSummaryModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<PlayerChampionModel>> getPlayerChampions({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerChampions(puuid),
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['champions'] as List<dynamic>;
    return list
        .map((e) => PlayerChampionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PlayerRoleModel>> getPlayerRoles({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerRoles(puuid),
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['roles'] as List<dynamic>;
    return list
        .map((e) => PlayerRoleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PlayerActivityModel> getPlayerActivity({
    required String puuid,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.playerActivity(puuid),
    );
    return PlayerActivityModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
