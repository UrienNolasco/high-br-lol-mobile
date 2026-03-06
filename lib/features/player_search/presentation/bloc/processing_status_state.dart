import 'package:equatable/equatable.dart';

sealed class ProcessingStatusState extends Equatable {
  const ProcessingStatusState();

  @override
  List<Object?> get props => [];
}

class ProcessingStatusLoading extends ProcessingStatusState {
  const ProcessingStatusLoading();
}

class ProcessingStatusUpdating extends ProcessingStatusState {
  const ProcessingStatusUpdating({
    required this.matchesProcessed,
    required this.matchesTotal,
  });

  final int matchesProcessed;
  final int matchesTotal;

  double get progress =>
      matchesTotal > 0 ? matchesProcessed / matchesTotal : 0;

  @override
  List<Object?> get props => [matchesProcessed, matchesTotal];
}

class ProcessingStatusComplete extends ProcessingStatusState {
  const ProcessingStatusComplete(this.puuid);

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}

class ProcessingStatusError extends ProcessingStatusState {
  const ProcessingStatusError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
