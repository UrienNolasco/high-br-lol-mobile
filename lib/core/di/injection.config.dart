// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:high_br_lol_mobile/core/network/api_client.dart' as _i998;
import 'package:high_br_lol_mobile/features/player_profile/data/datasources/player_profile_remote_datasource.dart'
    as _i629;
import 'package:high_br_lol_mobile/features/player_profile/data/repositories/player_profile_repository_impl.dart'
    as _i539;
import 'package:high_br_lol_mobile/features/player_profile/domain/repositories/player_profile_repository.dart'
    as _i295;
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_overview.dart'
    as _i136;
import 'package:high_br_lol_mobile/features/player_profile/domain/usecases/get_player_profile.dart'
    as _i138;
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_overview_bloc.dart'
    as _i945;
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_bloc.dart'
    as _i252;
import 'package:high_br_lol_mobile/features/player_search/data/datasources/player_search_remote_datasource.dart'
    as _i255;
import 'package:high_br_lol_mobile/features/player_search/data/repositories/player_search_repository_impl.dart'
    as _i1072;
import 'package:high_br_lol_mobile/features/player_search/domain/repositories/player_search_repository.dart'
    as _i266;
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/get_player_status.dart'
    as _i522;
import 'package:high_br_lol_mobile/features/player_search/domain/usecases/search_player.dart'
    as _i731;
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/player_search_bloc.dart'
    as _i1041;
import 'package:high_br_lol_mobile/features/player_search/presentation/bloc/processing_status_bloc.dart'
    as _i757;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i998.ApiClient>(() => _i998.ApiClient());
    gh.lazySingleton<_i629.PlayerProfileRemoteDataSource>(
      () => _i629.PlayerProfileRemoteDataSource(gh<_i998.ApiClient>()),
    );
    gh.lazySingleton<_i255.PlayerSearchRemoteDataSource>(
      () => _i255.PlayerSearchRemoteDataSource(gh<_i998.ApiClient>()),
    );
    gh.lazySingleton<_i266.PlayerSearchRepository>(
      () => _i1072.PlayerSearchRepositoryImpl(
        gh<_i255.PlayerSearchRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i295.PlayerProfileRepository>(
      () => _i539.PlayerProfileRepositoryImpl(
        gh<_i629.PlayerProfileRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i522.GetPlayerStatus>(
      () => _i522.GetPlayerStatus(gh<_i266.PlayerSearchRepository>()),
    );
    gh.lazySingleton<_i731.SearchPlayer>(
      () => _i731.SearchPlayer(gh<_i266.PlayerSearchRepository>()),
    );
    gh.lazySingleton<_i136.GetPlayerOverview>(
      () => _i136.GetPlayerOverview(gh<_i295.PlayerProfileRepository>()),
    );
    gh.lazySingleton<_i138.GetPlayerProfile>(
      () => _i138.GetPlayerProfile(gh<_i295.PlayerProfileRepository>()),
    );
    gh.factory<_i1041.PlayerSearchBloc>(
      () => _i1041.PlayerSearchBloc(gh<_i731.SearchPlayer>()),
    );
    gh.factory<_i945.PlayerOverviewBloc>(
      () => _i945.PlayerOverviewBloc(gh<_i136.GetPlayerOverview>()),
    );
    gh.factory<_i252.PlayerProfileBloc>(
      () => _i252.PlayerProfileBloc(
        gh<_i138.GetPlayerProfile>(),
        gh<_i522.GetPlayerStatus>(),
      ),
    );
    gh.factory<_i757.ProcessingStatusBloc>(
      () => _i757.ProcessingStatusBloc(gh<_i522.GetPlayerStatus>()),
    );
    return this;
  }
}
