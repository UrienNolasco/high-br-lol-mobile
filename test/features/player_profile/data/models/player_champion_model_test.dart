import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_champion_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_champion.dart';

void main() {
  const tModel = PlayerChampionModel(
    name: 'Ahri',
    games: 68,
    winRate: 61.8,
    iconId: 103,
  );

  const tJson = {
    'name': 'Ahri',
    'games': 68,
    'winRate': 61.8,
    'iconId': 103,
  };

  test('should be a subclass of PlayerChampion', () {
    expect(tModel, isA<PlayerChampion>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerChampionModel.fromJson(tJson);
    expect(result, equals(tModel));
  });
}
