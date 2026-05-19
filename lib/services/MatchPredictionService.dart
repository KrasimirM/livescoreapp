import 'package:LiveScore/services/HttpService.dart';

class MatchPredictionService {
  final HttpService _httpService;

  MatchPredictionService({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  Future<Map<String, dynamic>> fetchHeadToHeadPrediction(
      String matchId, Map match) async {
    final data = await _httpService.fetchHeadToHeadData(matchId);
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

    double homeScore = 1.35;
    double drawScore = 1.0;
    double awayScore = 1.0;

    for (int i = 0; i < relatedMatches.length; i++) {
      var m = relatedMatches[i];
      var hId = m['homeTeam']['id'];
      var aId = m['awayTeam']['id'];

      int hScore = m['score']['fullTime']['home'] ?? 0;
      int aScore = m['score']['fullTime']['away'] ?? 0;

      double weight = (i >= relatedMatches.length - 5) ? 1.5 : 1.0;

      final homeTeamGoals = hId == matchHomeId ? hScore : aScore;
      final awayTeamGoals = aId == matchAwayId ? aScore : hScore;
      final goalDifference = homeTeamGoals - awayTeamGoals;

      if (hScore > aScore) {
        if (hId == matchHomeId) {
          homeScore += 2.0 * weight;
        } else {
          awayScore += 2.0 * weight;
        }
      } else if (hScore < aScore) {
        if (aId == matchAwayId) {
          awayScore += 2.0 * weight;
        } else {
          homeScore += 2.0 * weight;
        }
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
    final normalizedChances = _applyMinimumChance([
      (homeScore / totalScore) * 100,
      (drawScore / totalScore) * 100,
      (awayScore / totalScore) * 100,
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
