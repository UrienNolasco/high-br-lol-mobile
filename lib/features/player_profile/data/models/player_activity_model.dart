import '../../domain/entities/player_activity.dart';

class PlayerActivityModel extends PlayerActivity {
  const PlayerActivityModel({required super.raw});

  factory PlayerActivityModel.fromJson(Map<String, dynamic> json) {
    return PlayerActivityModel(raw: json);
  }
}
