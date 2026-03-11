import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../../player_search/domain/entities/processing_status.dart';
import '../../../player_search/domain/usecases/get_player_status.dart';
import '../../domain/usecases/get_player_profile.dart';
import '../../domain/usecases/trigger_deep_sync.dart';
import '../../domain/usecases/get_deep_sync_status.dart';
import 'player_profile_event.dart';
import 'player_profile_state.dart';

@injectable
class PlayerProfileBloc
    extends Bloc<PlayerProfileEvent, PlayerProfileState> {
  PlayerProfileBloc(
    this._getPlayerProfile,
    this._getPlayerStatus,
    this._triggerDeepSync,
    this._getDeepSyncStatus,
  ) : super(const ProfileLoading()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileStatusPolled>(_onStatusPolled);
    on<ProfileStatusStopped>(_onStatusStopped);
    on<DeepSyncRequested>(_onDeepSyncRequested);
    on<DeepSyncStatusPolled>(_onDeepSyncStatusPolled);
  }

  final GetPlayerProfile _getPlayerProfile;
  final GetPlayerStatus _getPlayerStatus;
  final TriggerDeepSync _triggerDeepSync;
  final GetDeepSyncStatus _getDeepSyncStatus;
  Timer? _timer;
  String? _puuid;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<PlayerProfileState> emit,
  ) async {
    _puuid = event.puuid;
    try {
      final player = await _getPlayerProfile(puuid: event.puuid);
      emit(ProfileLoaded(player: player, bannerMode: BannerMode.processing));
      _startInitialPolling();
    } on ApiException catch (e) {
      log('PlayerProfileBloc: ApiException → ${e.message}');
      emit(ProfileError(e.message));
    } catch (e, stack) {
      log('PlayerProfileBloc: unexpected error → $e',
          error: e, stackTrace: stack);
      emit(const ProfileError('Erro ao carregar perfil.'));
    }
  }

  Future<void> _onStatusPolled(
    ProfileStatusPolled event,
    Emitter<PlayerProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    try {
      final status = await _getPlayerStatus(puuid: _puuid!);
      if (status.status == UpdateStatus.idle) {
        _timer?.cancel();
        emit(current.copyWith(
          bannerMode: BannerMode.ready,
          processingStatus: status,
        ));
      } else {
        emit(current.copyWith(
          bannerMode: BannerMode.processing,
          processingStatus: status,
        ));
      }
    } on ApiException catch (e) {
      log('PlayerProfileBloc: polling error → ${e.message}');
    } catch (e, stack) {
      log('PlayerProfileBloc: polling unexpected error',
          error: e, stackTrace: stack);
    }
  }

  Future<void> _onDeepSyncRequested(
    DeepSyncRequested event,
    Emitter<PlayerProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    if (current.bannerMode != BannerMode.ready) return;

    emit(current.copyWith(bannerMode: BannerMode.triggering));

    try {
      await _triggerDeepSync(puuid: _puuid!);
      _startSyncPolling();
    } on ApiException catch (e) {
      log('PlayerProfileBloc: deep sync error → ${e.message}');
      emit(current.copyWith(
        bannerMode: BannerMode.ready,
        syncError: e.message,
      ));
    } catch (e, stack) {
      log('PlayerProfileBloc: deep sync unexpected error',
          error: e, stackTrace: stack);
      emit(current.copyWith(
        bannerMode: BannerMode.ready,
        syncError: 'Erro ao iniciar busca de partidas.',
      ));
    }
  }

  Future<void> _onDeepSyncStatusPolled(
    DeepSyncStatusPolled event,
    Emitter<PlayerProfileState> emit,
  ) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    try {
      final status = await _getDeepSyncStatus(puuid: _puuid!);
      if (status.status == UpdateStatus.idle) {
        _timer?.cancel();
        // Refresh profile data to reflect newly synced matches
        final updatedPlayer = await _getPlayerProfile(puuid: _puuid!);
        emit(current.copyWith(
          player: updatedPlayer,
          bannerMode: BannerMode.ready,
          processingStatus: status,
        ));
      } else if (status.status == UpdateStatus.error) {
        _timer?.cancel();
        emit(current.copyWith(
          bannerMode: BannerMode.ready,
          syncError: status.message,
        ));
      } else {
        emit(current.copyWith(
          bannerMode: BannerMode.processing,
          processingStatus: status,
        ));
      }
    } on ApiException catch (e) {
      log('PlayerProfileBloc: sync polling error → ${e.message}');
    } catch (e, stack) {
      log('PlayerProfileBloc: sync polling unexpected error',
          error: e, stackTrace: stack);
    }
  }

  void _onStatusStopped(
    ProfileStatusStopped event,
    Emitter<PlayerProfileState> emit,
  ) {
    _timer?.cancel();
  }

  void _startInitialPolling() {
    _timer?.cancel();
    if (!isClosed) add(const ProfileStatusPolled());
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isClosed) add(const ProfileStatusPolled());
    });
  }

  void _startSyncPolling() {
    _timer?.cancel();
    if (!isClosed) add(const DeepSyncStatusPolled());
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isClosed) add(const DeepSyncStatusPolled());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
