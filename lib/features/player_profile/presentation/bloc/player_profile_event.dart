import 'package:equatable/equatable.dart';

sealed class PlayerProfileEvent extends Equatable {
  const PlayerProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileStarted extends PlayerProfileEvent {
  const ProfileStarted({required this.puuid});

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}

class ProfileStatusPolled extends PlayerProfileEvent {
  const ProfileStatusPolled();
}

class ProfileStatusStopped extends PlayerProfileEvent {
  const ProfileStatusStopped();
}

class DeepSyncRequested extends PlayerProfileEvent {
  const DeepSyncRequested();
}

class DeepSyncStatusPolled extends PlayerProfileEvent {
  const DeepSyncStatusPolled();
}
