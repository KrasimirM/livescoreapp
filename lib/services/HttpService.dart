import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static const String _baseUrl = 'http://api.football-data.org/v4';
  static const String _apiKey = '27f54ff1ab4b4d2cbbb3d0c34084d70a';
  static const Map<String, String> _headers = {
    'X-Auth-Token': _apiKey,
    'Content-Type': 'application/json',
  };

  Future<dynamic> getRequest(String endpoint) async {
    final Uri url = Uri.parse('$_baseUrl$endpoint');
    final response = await http.get(url, headers: _headers);

    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Request failed with status: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchMatches(String teamId,
      {required String dateFrom, required String dateTo}) async {
    final url =
        '/teams/$teamId/matches?dateFrom=$dateFrom&dateTo=$dateTo&sortBy=date';
    final data = await getRequest(url);
    return data['matches'];
  }

  Future<String?> fetchTeamDetails(String teamId) async {
    final url = '/teams/$teamId';
    final data = await getRequest(url);
    return data['crest'];
  }

  Future<List<dynamic>> fetchLeagues() async {
    final url = '/competitions';
    final data = await getRequest(url);
    return data['competitions'];
  }

  Future<List<dynamic>> fetchTeams(String leagueCode) async {
    final url = '/competitions/$leagueCode/teams';
    final data = await getRequest(url);
    return data['teams'];
  }

  Future<List<dynamic>> fetchTable(String competitionCode) async {
    final url = '/competitions/$competitionCode/standings';
    final data = await getRequest(url);
    return data['standings'][0]['table'];
  }

  Future<Map<String, dynamic>> fetchMatchDetails(String matchId) async {
    final url = '/matches/$matchId';
    final data = await getRequest(url);

    return data;
  }

  Future<Map<String, dynamic>> fetchHeadToHead(
      String matchId, Map match) async {
    // Fetch head-to-head data from API
    final url = '/matches/$matchId/head2head?limit=50';
    final data = await getRequest(url);

    // Extract aggregates
    final aggregates = data['aggregates'];
    if (aggregates == null) return {};

    final matchHomeId = match['homeTeam']['id'];
    final matchAwayId = match['awayTeam']['id'];

    List matches = data['matches'] ?? [];
    int homeWins = 0, awayWins = 0, draws = 0;
    double homeGoals = 0, awayGoals = 0;

    // Iterate through all previous encounters
    for (int i = 0; i < matches.length; i++) {
      var m = matches[i];
      var hId = m['homeTeam']['id'];
      var aId = m['awayTeam']['id'];

      // Skip unrelated matches
      if ((hId != matchHomeId && hId != matchAwayId) ||
          (aId != matchHomeId && aId != matchAwayId)) continue;

      int hScore = m['score']['fullTime']['home'] ?? 0;
      int aScore = m['score']['fullTime']['away'] ?? 0;

      // Apply recent form weighting: last 5 matches = 1.5x weight
      double weight = (i >= matches.length - 5) ? 1.5 : 1.0;

      // Accumulate goals (could be used for tie-breakers or advanced algo)
      homeGoals += hScore * weight;
      awayGoals += aScore * weight;

      // Determine winner and accumulate wins/losses with weight
      if (hScore > aScore) {
        if (hId == matchHomeId)
          homeWins += (1 * weight).round();
        else
          awayWins += (1 * weight).round();
      } else if (hScore < aScore) {
        if (aId == matchAwayId)
          awayWins += (1 * weight).round();
        else
          homeWins += (1 * weight).round();
      } else {
        draws += (1 * weight).round();
      }
    }

    // Add simple home advantage boost
    homeWins += 1;

    int total = homeWins + draws + awayWins;
    if (total == 0) total = 1; // Avoid division by zero

    // Normalize so that sum = 100%
    double homeChance = (homeWins / total) * 100;
    double drawChance = (draws / total) * 100;
    double awayChance = (awayWins / total) * 100;

    // Adjust slightly to ensure rounding doesn't exceed 100%
    double totalChance = homeChance + drawChance + awayChance;
    homeChance = homeChance / totalChance * 100;
    drawChance = drawChance / totalChance * 100;
    awayChance = awayChance / totalChance * 100;

    return {
      'homeTeam': {
        'name': match['homeTeam']['name'],
        'chance': homeChance.toStringAsFixed(1),
      },
      'draw': drawChance.toStringAsFixed(1),
      'awayTeam': {
        'name': match['awayTeam']['name'],
        'chance': awayChance.toStringAsFixed(1),
      },
      'matches': matches
          .where((m) =>
              (m['homeTeam']['id'] == matchHomeId &&
                  m['awayTeam']['id'] == matchAwayId) ||
              (m['homeTeam']['id'] == matchAwayId &&
                  m['awayTeam']['id'] == matchHomeId))
          .toList(),
    };
  }
}
