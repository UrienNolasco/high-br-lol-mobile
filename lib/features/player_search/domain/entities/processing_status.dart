import 'package:equatable/equatable.dart';

enum UpdateStatus { idle, updating, error }

class ProcessingStatus extends Equatable {
  const ProcessingStatus({
    required this.status,
    required this.matchesProcessed,
    required this.matchesTotal,
    required this.message,
  });

  final UpdateStatus status;
  final int matchesProcessed;
  final int matchesTotal;
  final String message;

  @override
  List<Object?> get props => [status, matchesProcessed, matchesTotal, message];
}
