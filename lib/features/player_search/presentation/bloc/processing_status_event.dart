import 'package:equatable/equatable.dart';

sealed class ProcessingStatusEvent extends Equatable {
  const ProcessingStatusEvent();

  @override
  List<Object?> get props => [];
}

class ProcessingStarted extends ProcessingStatusEvent {
  const ProcessingStarted({required this.puuid});

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}

class ProcessingPolled extends ProcessingStatusEvent {
  const ProcessingPolled();
}

class ProcessingRetried extends ProcessingStatusEvent {
  const ProcessingRetried({required this.puuid});

  final String puuid;

  @override
  List<Object?> get props => [puuid];
}

class ProcessingStopped extends ProcessingStatusEvent {
  const ProcessingStopped();
}
