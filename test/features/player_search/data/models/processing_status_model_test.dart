import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_search/data/models/processing_status_model.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';

void main() {
  test('should be a subclass of ProcessingStatus', () {
    const model = ProcessingStatusModel(
      status: UpdateStatus.idle,
      matchesProcessed: 20,
      matchesTotal: 20,
      message: 'All matches processed',
    );
    expect(model, isA<ProcessingStatus>());
  });

  test('should parse IDLE status from JSON', () {
    final json = {
      'status': 'IDLE',
      'matchesProcessed': 20,
      'matchesTotal': 20,
      'message': 'All matches processed',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.idle);
    expect(model.matchesProcessed, 20);
    expect(model.matchesTotal, 20);
    expect(model.message, 'All matches processed');
  });

  test('should parse UPDATING status from JSON', () {
    final json = {
      'status': 'UPDATING',
      'matchesProcessed': 5,
      'matchesTotal': 20,
      'message': 'Processing matches: 5/20',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.updating);
    expect(model.matchesProcessed, 5);
    expect(model.matchesTotal, 20);
  });

  test('should parse ERROR status from JSON', () {
    final json = {
      'status': 'ERROR',
      'matchesProcessed': 0,
      'matchesTotal': 0,
      'message': 'Failed to fetch match status from Riot API',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.error);
    expect(model.message, 'Failed to fetch match status from Riot API');
  });

  test('should default unknown status to error', () {
    final json = {
      'status': 'UNKNOWN',
      'matchesProcessed': 0,
      'matchesTotal': 0,
      'message': 'Something unexpected',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.error);
  });

  test('should parse SYNCING status as updating', () {
    final json = {
      'status': 'SYNCING',
      'matchesProcessed': 30,
      'matchesTotal': 42,
      'message': 'Sync in progress: 30/42 matches processed',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.updating);
    expect(model.matchesProcessed, 30);
    expect(model.matchesTotal, 42);
  });

  test('should parse DONE status as idle', () {
    final json = {
      'status': 'DONE',
      'matchesProcessed': 42,
      'matchesTotal': 42,
      'message': 'Sync complete',
    };
    final model = ProcessingStatusModel.fromJson(json);
    expect(model.status, UpdateStatus.idle);
  });
}
