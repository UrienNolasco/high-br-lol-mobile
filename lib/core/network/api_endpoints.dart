abstract final class ApiEndpoints {
  // Players
  static const String searchPlayer = '/players/search';
  static String playerProfile(String puuid) => '/players/$puuid';
  static String playerSummary(String puuid) => '/players/$puuid/summary';
  static String playerChampions(String puuid) => '/players/$puuid/champions';
  static String playerRoles(String puuid) => '/players/$puuid/roles';
  static String playerActivity(String puuid) => '/players/$puuid/activity';
  static String playerMatches(String puuid) => '/players/$puuid/matches/page';
  static String playerSync(String puuid) => '/players/$puuid/sync';
  static String playerSyncStatus(String puuid) =>
      '/players/$puuid/sync-status';
  static String playerStatus(String puuid) => '/players/$puuid/status';

  // Matches
  static String matchDetails(String matchId) => '/matches/$matchId';
  static String matchGoldTimeline(String matchId) =>
      '/matches/$matchId/timeline/gold';
  static String matchEvents(String matchId) =>
      '/matches/$matchId/timeline/events';
  static String matchBuilds(String matchId) => '/matches/$matchId/builds';
  static String matchPerformance(String matchId, String puuid) =>
      '/matches/$matchId/performance/$puuid';

  // Champions
  static const String champions = '/champions';
  static const String currentPatch = '/champions/current-patch';
  static const String championStats = '/stats/champions';
  static String championStatsByName(String name) => '/stats/champions/$name';

  // Analytics
  static const String compareAnalytics = '/analytics/compare';
}
