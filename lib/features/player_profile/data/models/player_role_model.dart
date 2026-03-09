import '../../domain/entities/player_role.dart';

class PlayerRoleModel extends PlayerRole {
  const PlayerRoleModel({
    required super.role,
    required super.games,
    required super.winRate,
  });

  factory PlayerRoleModel.fromJson(Map<String, dynamic> json) {
    return PlayerRoleModel(
      role: json['role'] as String,
      games: json['gamesPlayed'] as int,
      winRate: (json['winRate'] as num).toDouble(),
    );
  }
}
