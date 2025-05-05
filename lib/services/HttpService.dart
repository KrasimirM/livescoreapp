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
}
