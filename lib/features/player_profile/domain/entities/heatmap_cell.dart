import 'package:equatable/equatable.dart';

class HeatmapCell extends Equatable {
  const HeatmapCell({
    required this.dayOfWeek,
    required this.hour,
    required this.games,
    required this.wins,
    required this.losses,
    required this.winRate,
  });

  final int dayOfWeek;
  final int hour;
  final int games;
  final int wins;
  final int losses;
  final double winRate;

  @override
  List<Object?> get props => [dayOfWeek, hour, games, wins, losses, winRate];
}
