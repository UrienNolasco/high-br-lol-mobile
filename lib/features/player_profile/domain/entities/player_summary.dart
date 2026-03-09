import 'package:equatable/equatable.dart';

class PlayerSummary extends Equatable {
  const PlayerSummary({
    required this.games,
    required this.winRate,
    required this.kda,
    required this.csPerMin,
    required this.dpm,
  });

  final int games;
  final double winRate;
  final double kda;
  final double csPerMin;
  final double dpm;

  @override
  List<Object?> get props => [games, winRate, kda, csPerMin, dpm];
}
