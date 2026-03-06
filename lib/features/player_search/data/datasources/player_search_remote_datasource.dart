import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/player_search_result_model.dart';

@lazySingleton
class PlayerSearchRemoteDataSource {
  const PlayerSearchRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<PlayerSearchResultModel> searchPlayer({
    required String gameName,
    required String tagLine,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.searchPlayer,
      data: {'gameName': gameName, 'tagLine': tagLine},
    );
    return PlayerSearchResultModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
