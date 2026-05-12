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
    final relatedMatches = matches
        .where((m) =>
            (m['homeTeam']['id'] == matchHomeId &&
                m['awayTeam']['id'] == matchAwayId) ||
            (m['homeTeam']['id'] == matchAwayId &&
                m['awayTeam']['id'] == matchHomeId))
        .toList();

    // Base priors prevent impossible-looking 0% predictions when historical
    // head-to-head data is sparse or one outcome has not happened recently.
    double homeScore = 1.35;
    double drawScore = 1.0;
    double awayScore = 1.0;

    // Iterate through all previous encounters
    for (int i = 0; i < relatedMatches.length; i++) {
      var m = relatedMatches[i];
      var hId = m['homeTeam']['id'];
      var aId = m['awayTeam']['id'];

      int hScore = m['score']['fullTime']['home'] ?? 0;
      int aScore = m['score']['fullTime']['away'] ?? 0;

      // Apply recent form weighting: last 5 matches = 1.5x weight
      double weight = (i >= relatedMatches.length - 5) ? 1.5 : 1.0;

      final homeTeamGoals = hId == matchHomeId ? hScore : aScore;
      final awayTeamGoals = aId == matchAwayId ? aScore : hScore;
      final goalDifference = homeTeamGoals - awayTeamGoals;

      // Determine winner and accumulate wins/losses with weight
      if (hScore > aScore) {
        if (hId == matchHomeId)
          homeScore += 2.0 * weight;
        else
          awayScore += 2.0 * weight;
      } else if (hScore < aScore) {
        if (aId == matchAwayId)
          awayScore += 2.0 * weight;
        else
          homeScore += 2.0 * weight;
      } else {
        drawScore += 2.0 * weight;
      }

      if (goalDifference > 0) {
        homeScore += goalDifference.clamp(0, 3) * 0.25 * weight;
      } else if (goalDifference < 0) {
        awayScore += (-goalDifference).clamp(0, 3) * 0.25 * weight;
      } else {
        drawScore += 0.25 * weight;
      }
    }

    final totalScore = homeScore + drawScore + awayScore;

    // Normalize so that sum = 100%
    double homeChance = (homeScore / totalScore) * 100;
    double drawChance = (drawScore / totalScore) * 100;
    double awayChance = (awayScore / totalScore) * 100;
    final normalizedChances = _applyMinimumChance([
      homeChance,
      drawChance,
      awayChance,
    ]);

    return {
      'homeTeam': {
        'name': match['homeTeam']['name'],
        'chance': normalizedChances[0].toStringAsFixed(1),
      },
      'draw': normalizedChances[1].toStringAsFixed(1),
      'awayTeam': {
        'name': match['awayTeam']['name'],
        'chance': normalizedChances[2].toStringAsFixed(1),
      },
      'matches': relatedMatches,
    };
  }

  List<double> _applyMinimumChance(List<double> chances) {
    const double minimumChance = 5.0;
    final adjusted = chances
        .map((chance) => chance < minimumChance ? minimumChance : chance)
        .toList();

    final total = adjusted.reduce((sum, chance) => sum + chance);
    final excess = total - 100.0;
    if (excess <= 0) return adjusted;

    final reducible = adjusted
        .map((chance) => chance > minimumChance ? chance - minimumChance : 0.0)
        .toList();
    final totalReducible = reducible.reduce((sum, value) => sum + value);
    if (totalReducible <= 0) return adjusted;

    for (int i = 0; i < adjusted.length; i++) {
      if (reducible[i] == 0) continue;
      adjusted[i] -= excess * (reducible[i] / totalReducible);
    }

    return adjusted;
  }
}
