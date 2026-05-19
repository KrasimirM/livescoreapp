import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HttpService {
  String get _baseUrl => dotenv.env['BASE_URL'] ?? '';
  String get _apiKey => dotenv.env['API_KEY'] ?? '';
  Map<String, String> get _headers => {
        'X-Auth-Token': _apiKey,
        'Content-Type': 'application/json',
      };

  Future<dynamic> getRequest(String endpoint) async {
    if (_baseUrl.isEmpty || _apiKey.isEmpty) {
      throw Exception('Missing API configuration.');
    }

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
    final standings = await fetchStandings(competitionCode);
    return standings.isEmpty ? [] : standings.first['table'] ?? [];
  }

  Future<List<dynamic>> fetchStandings(String competitionCode) async {
    final url = '/competitions/$competitionCode/standings';
    final data = await getRequest(url);
    return data['standings'] ?? [];
  }

  Future<List<dynamic>> fetchCompetitionMatches(String competitionCode) async {
    final url = '/competitions/$competitionCode/matches';
    final data = await getRequest(url);
    return data['matches'] ?? [];
  }

  Future<Map<String, dynamic>> fetchHeadToHeadData(String matchId) async {
    final url = '/matches/$matchId/head2head?limit=50';
    return await getRequest(url);
  }

  Future<Map<String, dynamic>> fetchMatchDetails(String matchId) async {
    final url = '/matches/$matchId';
    final data = await getRequest(url);

    return data;
  }
}
