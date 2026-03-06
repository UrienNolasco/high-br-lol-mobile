import 'package:equatable/equatable.dart';
import '../../domain/entities/player_search_result.dart';

sealed class PlayerSearchState extends Equatable {
  const PlayerSearchState();

  @override
  List<Object?> get props => [];
}

class PlayerSearchInitial extends PlayerSearchState {
  const PlayerSearchInitial();
}

class PlayerSearchLoading extends PlayerSearchState {
  const PlayerSearchLoading();
}

class PlayerSearchSuccess extends PlayerSearchState {
  const PlayerSearchSuccess(this.result);

  final PlayerSearchResult result;

  @override
  List<Object?> get props => [result];
}

class PlayerSearchFailure extends PlayerSearchState {
  const PlayerSearchFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
