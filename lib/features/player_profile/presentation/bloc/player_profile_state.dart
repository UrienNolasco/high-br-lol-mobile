import 'package:equatable/equatable.dart';
import '../../domain/entities/player_profile.dart';
import '../../../player_search/domain/entities/processing_status.dart';

sealed class PlayerProfileState extends Equatable {
  const PlayerProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends PlayerProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends PlayerProfileState {
  const ProfileLoaded({
    required this.player,
    this.processingStatus,
  });

  final PlayerProfile player;
  final ProcessingStatus? processingStatus;

  bool get isProcessing =>
      processingStatus != null &&
      processingStatus!.status == UpdateStatus.updating;

  @override
  List<Object?> get props => [player, processingStatus];
}

class ProfileError extends PlayerProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
