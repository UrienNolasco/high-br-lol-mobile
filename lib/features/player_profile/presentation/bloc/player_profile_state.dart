import 'package:equatable/equatable.dart';
import '../../domain/entities/player_profile.dart';
import '../../../player_search/domain/entities/processing_status.dart';

enum BannerMode { processing, ready, triggering }

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
    this.bannerMode = BannerMode.ready,
    this.processingStatus,
    this.syncError,
  });

  final PlayerProfile player;
  final BannerMode bannerMode;
  final ProcessingStatus? processingStatus;
  final String? syncError;

  ProfileLoaded copyWith({
    PlayerProfile? player,
    BannerMode? bannerMode,
    ProcessingStatus? processingStatus,
    String? syncError,
  }) {
    return ProfileLoaded(
      player: player ?? this.player,
      bannerMode: bannerMode ?? this.bannerMode,
      processingStatus: processingStatus ?? this.processingStatus,
      syncError: syncError,
    );
  }

  @override
  List<Object?> get props => [player, bannerMode, processingStatus, syncError];
}

class ProfileError extends PlayerProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
