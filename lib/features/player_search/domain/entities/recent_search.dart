import 'package:equatable/equatable.dart';

class RecentSearch extends Equatable {
  const RecentSearch({
    required this.puuid,
    required this.gameName,
    required this.tagLine,
    this.tier,
    required this.searchedAt,
  });

  final String puuid;
  final String gameName;
  final String tagLine;
  final String? tier;
  final DateTime searchedAt;

  @override
  List<Object?> get props => [puuid, gameName, tagLine, tier, searchedAt];
}
