import '../../domain/entities/sync_trigger_result.dart';

class SyncTriggerResultModel extends SyncTriggerResult {
  const SyncTriggerResultModel({
    required super.puuid,
    required super.status,
    required super.matchesEnqueued,
    required super.matchesTotal,
    required super.matchesAlreadyInDb,
    required super.message,
  });

  factory SyncTriggerResultModel.fromJson(Map<String, dynamic> json) {
    return SyncTriggerResultModel(
      puuid: json['puuid'] as String,
      status: json['status'] as String,
      matchesEnqueued: json['matchesEnqueued'] as int,
      matchesTotal: json['matchesTotal'] as int,
      matchesAlreadyInDb: json['matchesAlreadyInDb'] as int,
      message: json['message'] as String,
    );
  }
}
