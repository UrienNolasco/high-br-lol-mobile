import 'package:equatable/equatable.dart';
import '../../domain/entities/overview_data.dart';

sealed class PlayerOverviewState extends Equatable {
  const PlayerOverviewState();

  @override
  List<Object?> get props => [];
}

class OverviewLoading extends PlayerOverviewState {
  const OverviewLoading();
}

class OverviewLoaded extends PlayerOverviewState {
  const OverviewLoaded(this.data);

  final OverviewData data;

  @override
  List<Object?> get props => [data];
}

class OverviewError extends PlayerOverviewState {
  const OverviewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
