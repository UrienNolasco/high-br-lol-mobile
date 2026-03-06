import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_exception.dart';
import '../../../player_search/domain/entities/processing_status.dart';
import '../../../player_search/domain/usecases/get_player_status.dart';
import '../../domain/usecases/get_player_profile.dart';
import 'player_profile_event.dart';
import 'player_profile_state.dart';

@injectable
class PlayerProfileBloc
    extends Bloc<PlayerProfileEvent, PlayerProfileState> {
  PlayerProfileBloc(this._getPlayerProfile, this._getPlayerStatus)
      : super(const ProfileLoading()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileStatusPolled>(_onStatusPolled);
    on<ProfileStatusStopped>(_onStatusStopped);
  }

  final GetPlayerProfile _getPlayerProfile;
  final GetPlayerStatus _getPlayerStatus;
  Timer? _timer;
  String? _puuid;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<PlayerProfileState> emit,
  ) async {
    _puuid = event.puuid;
    try {
      final player = await _getPlayerProfile(puuid: event.puuid);
      emit(ProfileLoaded(player: player));
      _startPolling();
    } on ApiException catch (e) {
      log('PlayerProfileBloc: ApiException → ${e.message}');
      emit(ProfileError(e.message));
    } catch (e, stack) {
      log('PlayerProfileBloc: unexpected error', error: e, stackTrace: stack);
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
        emit(ProfileLoaded(player: current.player, processingStatus: null));
      } else {
        emit(ProfileLoaded(
          player: current.player,
          processingStatus: status,
        ));
      }
    } on ApiException catch (e) {
      log('PlayerProfileBloc: polling error → ${e.message}');
    } catch (e, stack) {
      log('PlayerProfileBloc: polling unexpected error', error: e, stackTrace: stack);
    }
  }

  void _onStatusStopped(
    ProfileStatusStopped event,
    Emitter<PlayerProfileState> emit,
  ) {
    _timer?.cancel();
  }

  void _startPolling() {
    _timer?.cancel();
    if (!isClosed) add(const ProfileStatusPolled());
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!isClosed) add(const ProfileStatusPolled());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
