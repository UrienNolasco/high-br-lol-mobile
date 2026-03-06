import 'package:equatable/equatable.dart';

sealed class PlayerOverviewEvent extends Equatable {
  const PlayerOverviewEvent();

  @override
  List<Object?> get props => [];
}

class OverviewStarted extends PlayerOverviewEvent {
  const OverviewStarted({required this.puuid});

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}
