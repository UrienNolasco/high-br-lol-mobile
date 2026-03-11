import '../../domain/entities/processing_status.dart';

class ProcessingStatusModel extends ProcessingStatus {
  const ProcessingStatusModel({
    required super.status,
    required super.matchesProcessed,
    required super.matchesTotal,
    required super.message,
  });

  factory ProcessingStatusModel.fromJson(Map<String, dynamic> json) {
    return ProcessingStatusModel(
      status: _parseStatus(json['status'] as String),
      matchesProcessed: json['matchesProcessed'] as int,
      matchesTotal: json['matchesTotal'] as int,
      message: json['message'] as String,
    );
  }

  static UpdateStatus _parseStatus(String status) {
    return switch (status) {
      'IDLE' => UpdateStatus.idle,
      'UPDATING' => UpdateStatus.updating,
      'SYNCING' => UpdateStatus.updating,
      'DONE' => UpdateStatus.idle,
      'ERROR' => UpdateStatus.error,
      _ => UpdateStatus.error,
    };
  }
}
