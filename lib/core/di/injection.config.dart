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
    gh.lazySingleton<_i255.PlayerSearchRemoteDataSource>(
      () => _i255.PlayerSearchRemoteDataSource(gh<_i998.ApiClient>()),
    );
    gh.lazySingleton<_i266.PlayerSearchRepository>(
      () => _i1072.PlayerSearchRepositoryImpl(
        gh<_i255.PlayerSearchRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i522.GetPlayerStatus>(
      () => _i522.GetPlayerStatus(gh<_i266.PlayerSearchRepository>()),
    );
    gh.lazySingleton<_i731.SearchPlayer>(
      () => _i731.SearchPlayer(gh<_i266.PlayerSearchRepository>()),
    );
    gh.factory<_i1041.PlayerSearchBloc>(
      () => _i1041.PlayerSearchBloc(gh<_i731.SearchPlayer>()),
    );
    gh.factory<_i757.ProcessingStatusBloc>(
      () => _i757.ProcessingStatusBloc(gh<_i522.GetPlayerStatus>()),
    );
    return this;
  }
}
