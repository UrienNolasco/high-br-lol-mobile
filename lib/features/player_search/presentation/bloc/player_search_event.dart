import 'package:equatable/equatable.dart';
import '../../domain/entities/recent_search.dart';

sealed class PlayerSearchEvent extends Equatable {
  const PlayerSearchEvent();

  @override
  List<Object?> get props => [];
}

class PlayerSearchSubmitted extends PlayerSearchEvent {
  const PlayerSearchSubmitted({
    required this.gameName,
    required this.tagLine,
  });

  final String gameName;
  final String tagLine;

  @override
  List<Object?> get props => [gameName, tagLine];
}

class RecentSearchesLoaded extends PlayerSearchEvent {
  const RecentSearchesLoaded();
}

class RecentSearchAdded extends PlayerSearchEvent {
  const RecentSearchAdded(this.search);

  final RecentSearch search;

  @override
  List<Object?> get props => [search];
}
