import 'package:equatable/equatable.dart';
import '../../domain/entities/player_search_result.dart';
import '../../domain/entities/recent_search.dart';

sealed class PlayerSearchState extends Equatable {
  const PlayerSearchState({this.recentSearches = const []});

  final List<RecentSearch> recentSearches;

  @override
  List<Object?> get props => [recentSearches];
}

class PlayerSearchInitial extends PlayerSearchState {
  const PlayerSearchInitial({super.recentSearches});
}

class PlayerSearchLoading extends PlayerSearchState {
  const PlayerSearchLoading({super.recentSearches});
}

class PlayerSearchSuccess extends PlayerSearchState {
  const PlayerSearchSuccess(this.result, {super.recentSearches});

  final PlayerSearchResult result;

  @override
  List<Object?> get props => [result, recentSearches];
}

class PlayerSearchFailure extends PlayerSearchState {
  const PlayerSearchFailure(this.message, {super.recentSearches});

  final String message;

  @override
  List<Object?> get props => [message, recentSearches];
}
