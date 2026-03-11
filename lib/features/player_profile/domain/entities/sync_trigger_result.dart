import 'package:equatable/equatable.dart';

class SyncTriggerResult extends Equatable {
  const SyncTriggerResult({
    required this.puuid,
    required this.status,
    required this.matchesEnqueued,
    required this.matchesTotal,
    required this.matchesAlreadyInDb,
    required this.message,
  });

  final String puuid;
  final String status;
  final int matchesEnqueued;
  final int matchesTotal;
  final int matchesAlreadyInDb;
  final String message;

  @override
  List<Object?> get props => [
        puuid,
        status,
        matchesEnqueued,
        matchesTotal,
        matchesAlreadyInDb,
        message,
      ];
}
