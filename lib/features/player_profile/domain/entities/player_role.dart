import 'package:equatable/equatable.dart';

class PlayerRole extends Equatable {
  const PlayerRole({
    required this.role,
    required this.games,
    required this.winRate,
  });

  final String role;
  final int games;
  final double winRate;

  @override
  List<Object?> get props => [role, games, winRate];
}
