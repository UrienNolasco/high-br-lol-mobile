import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/processing_status.dart';
import '../../domain/usecases/get_player_status.dart';
import 'processing_status_event.dart';
import 'processing_status_state.dart';

@injectable
class ProcessingStatusBloc
    extends Bloc<ProcessingStatusEvent, ProcessingStatusState> {
  ProcessingStatusBloc(this._getPlayerStatus)
      : super(const ProcessingStatusLoading()) {
    on<ProcessingStarted>(_onStarted);
    on<ProcessingPolled>(_onPolled);
    on<ProcessingRetried>(_onRetried);
    on<ProcessingStopped>(_onStopped);
  }

  final GetPlayerStatus _getPlayerStatus;
  Timer? _timer;
  String? _puuid;

  Future<void> _onStarted(
    ProcessingStarted event,
    Emitter<ProcessingStatusState> emit,
  ) async {
    _puuid = event.puuid;
    await _poll(emit);
    _startTimer();
  }

  Future<void> _onPolled(
    ProcessingPolled event,
    Emitter<ProcessingStatusState> emit,
  ) async {
    await _poll(emit);
  }

  Future<void> _onRetried(
    ProcessingRetried event,
    Emitter<ProcessingStatusState> emit,
  ) async {
    _puuid = event.puuid;
    emit(const ProcessingStatusLoading());
    await _poll(emit);
    _startTimer();
  }

  void _onStopped(
    ProcessingStopped event,
    Emitter<ProcessingStatusState> emit,
  ) {
    _timer?.cancel();
  }

  Future<void> _poll(Emitter<ProcessingStatusState> emit) async {
    try {
      final status = await _getPlayerStatus(puuid: _puuid!);
      switch (status.status) {
        case UpdateStatus.idle:
          _timer?.cancel();
          emit(ProcessingStatusComplete(_puuid!));
        case UpdateStatus.error:
          _timer?.cancel();
          emit(ProcessingStatusError(status.message));
        case UpdateStatus.updating:
          emit(ProcessingStatusUpdating(
            matchesProcessed: status.matchesProcessed,
            matchesTotal: status.matchesTotal,
          ));
      }
    } on ApiException {
      // Silent retry — next poll cycle will try again
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!isClosed) add(const ProcessingPolled());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
