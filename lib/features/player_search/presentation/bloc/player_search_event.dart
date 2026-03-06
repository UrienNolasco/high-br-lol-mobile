import 'package:equatable/equatable.dart';

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
