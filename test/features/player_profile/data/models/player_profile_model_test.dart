import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_profile_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_profile.dart';

void main() {
  const tModel = PlayerProfileModel(
    puuid: 'test-puuid-123',
    gameName: 'UrienMano',
    tagLine: 'BR1',
    profileIconId: 1234,
    tier: 'CHALLENGER',
    rank: 'I',
    leaguePoints: 1234,
    wins: 150,
    losses: 120,
  );

  const tJson = {
    'puuid': 'test-puuid-123',
    'gameName': 'UrienMano',
    'tagLine': 'BR1',
    'profileIconId': 1234,
    'tier': 'CHALLENGER',
    'rank': 'I',
    'leaguePoints': 1234,
    'wins': 150,
    'losses': 120,
  };

  test('should be a subclass of PlayerProfile', () {
    expect(tModel, isA<PlayerProfile>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerProfileModel.fromJson(tJson);
    expect(result, equals(tModel));
  });

  test('should calculate winRate correctly', () {
    expect(tModel.winRate, closeTo(55.56, 0.01));
  });
}
