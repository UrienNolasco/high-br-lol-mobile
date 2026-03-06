import 'package:equatable/equatable.dart';
import 'player_summary.dart';
import 'player_champion.dart';
import 'player_role.dart';
import 'player_activity.dart';

class OverviewData extends Equatable {
  const OverviewData({
    required this.summary,
    required this.champions,
    required this.roles,
    required this.activity,
  });

  final PlayerSummary summary;
  final List<PlayerChampion> champions;
  final List<PlayerRole> roles;
  final PlayerActivity activity;

  @override
  List<Object?> get props => [summary, champions, roles, activity];
}
