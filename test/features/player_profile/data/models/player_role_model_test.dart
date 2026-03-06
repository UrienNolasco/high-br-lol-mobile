import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/data/models/player_role_model.dart';
import 'package:high_br_lol_mobile/features/player_profile/domain/entities/player_role.dart';

void main() {
  const tModel = PlayerRoleModel(
    role: 'MID',
    games: 142,
    winRate: 58.0,
  );

  const tJson = {
    'role': 'MID',
    'games': 142,
    'winRate': 58.0,
  };

  test('should be a subclass of PlayerRole', () {
    expect(tModel, isA<PlayerRole>());
  });

  test('should return a valid model from JSON', () {
    final result = PlayerRoleModel.fromJson(tJson);
    expect(result, equals(tModel));
  });
}
