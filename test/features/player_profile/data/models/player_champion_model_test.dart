import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_champion_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_champion.dart';

void main() {
  const tModel = PlayerChampionModel(
    name: 'Ahri',
    games: 68,
    winRate: 61.8,
    iconId: 103,
    imageUrl: 'https://ddragon.leagueoflegends.com/cdn/15.23.1/img/champion/Ahri.png',
    wins: 42,
    losses: 26,
    avgKda: 3.21,
    avgCspm: 7.5,
    avgDpm: 890.0,
    avgGpm: 420.0,
    avgVisionScore: 25.3,
    avgCsd15: 5.2,
    avgGd15: 320.0,
    avgXpd15: 150.0,
    roleDistribution: {'MIDDLE': 60, 'BOTTOM': 8},
  );

  const tJson = {
    'championName': 'Ahri',
    'gamesPlayed': 68,
    'winRate': 61.8,
    'championId': 103,
    'imageUrl': 'https://ddragon.leagueoflegends.com/cdn/15.23.1/img/champion/Ahri.png',
    'wins': 42,
    'losses': 26,
    'avgKda': 3.21,
    'avgCspm': 7.5,
    'avgDpm': 890.0,
    'avgGpm': 420.0,
    'avgVisionScore': 25.3,
    'avgCsd15': 5.2,
    'avgGd15': 320.0,
    'avgXpd15': 150.0,
    'roleDistribution': {'MIDDLE': 60, 'BOTTOM': 8},
  };

  test('should be a subclass of PlayerChampion', () {
    expect(tModel, isA<PlayerChampion>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerChampionModel.fromJson(tJson);
    expect(result, equals(tModel));
  });
}
