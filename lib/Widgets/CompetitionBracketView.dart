import 'dart:math';

import 'package:LiveScore/Screens/MatchScreen.dart';
import 'package:LiveScore/Screens/UpcomingMatchScreen.dart';
import 'package:LiveScore/Widgets/CrestImage.dart';
import 'package:LiveScore/constants.dart';
import 'package:flutter/material.dart';

class CompetitionBracketView extends StatelessWidget {
  final Map<String, List> matchesByStage;
  final int Function(dynamic stage) stageOrder;
  final String Function(String stage) stageLabel;

  const CompetitionBracketView({
    Key? key,
    required this.matchesByStage,
    required this.stageOrder,
    required this.stageLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stages = matchesByStage.keys.toList()
      ..sort((a, b) => stageOrder(a).compareTo(stageOrder(b)));

    final columns = stages
        .map(
          (stage) => BracketColumnData(
            label: stageLabel(stage),
            ties: _buildTies(matchesByStage[stage] ?? []),
          ),
        )
        .where((column) => column.ties.isNotEmpty)
        .toList();

    if (columns.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: _BracketBoard(columns: columns),
          ),
        );
      },
    );
  }

  List<BracketTieData> _buildTies(List matches) {
    final sortedMatches = [...matches]..sort((a, b) {
        return _matchDate(a).compareTo(_matchDate(b));
      });
    final tiesByTeams = <String, List<Map>>{};

    for (final match in sortedMatches) {
      if (match is! Map) continue;
      final key = _tieKey(match);
      tiesByTeams.putIfAbsent(key, () => []).add(match);
    }

    return tiesByTeams.values.map((tieMatches) {
      return BracketTieData(matches: tieMatches);
    }).toList();
  }

  String _tieKey(Map match) {
    final homeId = match['homeTeam']?['id']?.toString();
    final awayId = match['awayTeam']?['id']?.toString();
    if (homeId == null || awayId == null || homeId.isEmpty || awayId.isEmpty) {
      return match['id']?.toString() ?? UniqueKey().toString();
    }

    final ids = [homeId, awayId]..sort();
    return '${ids[0]}-${ids[1]}';
  }

  DateTime _matchDate(dynamic match) {
    return DateTime.tryParse((match['utcDate'] ?? '').toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class BracketColumnData {
  final String label;
  final List<BracketTieData> ties;

  const BracketColumnData({
    required this.label,
    required this.ties,
  });
}

class BracketTieData {
  final List<Map> matches;

  const BracketTieData({required this.matches});

  Map get firstMatch => matches.first;
  Map get primaryHomeTeam => firstMatch['homeTeam'] ?? {};
  Map get primaryAwayTeam => firstMatch['awayTeam'] ?? {};
  bool get isMultiLeg => matches.length > 1;

  int? aggregateForTeam(dynamic teamId) {
    if (teamId == null) return null;

    int total = 0;
    bool hasScore = false;
    for (final match in matches) {
      final fullTime = match['score']?['fullTime'] ?? {};
      final homeScore = fullTime['home'];
      final awayScore = fullTime['away'];
      if (homeScore == null || awayScore == null) continue;

      if (match['homeTeam']?['id'] == teamId) {
        total += homeScore as int;
        hasScore = true;
      } else if (match['awayTeam']?['id'] == teamId) {
        total += awayScore as int;
        hasScore = true;
      }
    }

    return hasScore ? total : null;
  }

  Map get navigableMatch {
    return matches.lastWhere(
      (match) {
        final fullTime = match['score']?['fullTime'] ?? {};
        return fullTime['home'] != null || fullTime['away'] != null;
      },
      orElse: () => matches.first,
    );
  }
}

class _BracketBoard extends StatelessWidget {
  final List<BracketColumnData> columns;

  static const double columnWidth = 238;
  static const double columnGap = 34;
  static const double headerHeight = 42;
  static const double matchHeight = 112;
  static const double baseGap = 18;

  const _BracketBoard({required this.columns});

  @override
  Widget build(BuildContext context) {
    final positions = _calculatePositions(columns);
    final boardHeight = _boardHeight(positions);
    final boardWidth =
        columns.length * columnWidth + (columns.length - 1) * columnGap;

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(boardWidth, boardHeight),
            painter: _BracketConnectorPainter(
              columns: columns,
              positions: positions,
              columnWidth: columnWidth,
              columnGap: columnGap,
              headerHeight: headerHeight,
              matchHeight: matchHeight,
            ),
          ),
          for (int columnIndex = 0; columnIndex < columns.length; columnIndex++)
            Positioned(
              left: columnIndex * (columnWidth + columnGap),
              top: 0,
              width: columnWidth,
              height: boardHeight,
              child: _BracketColumn(
                column: columns[columnIndex],
                topOffsets: positions[columnIndex],
                headerHeight: headerHeight,
                matchHeight: matchHeight,
              ),
            ),
        ],
      ),
    );
  }

  List<List<double>> _calculatePositions(List<BracketColumnData> columns) {
    final maxTies = columns.map((column) => column.ties.length).reduce(max);
    final baseHeight = maxTies * matchHeight + (maxTies - 1) * baseGap;
    final positions = <List<double>>[];

    for (int columnIndex = 0; columnIndex < columns.length; columnIndex++) {
      final count = columns[columnIndex].ties.length;
      final progressionGap = baseGap * pow(2, columnIndex).toDouble();
      final columnHeight =
          count * matchHeight + max(0, count - 1) * progressionGap;
      final start = headerHeight + max(0, (baseHeight - columnHeight) / 2);
      positions.add([
        for (int tieIndex = 0; tieIndex < count; tieIndex++)
          start + tieIndex * (matchHeight + progressionGap),
      ]);
    }

    return positions;
  }

  double _boardHeight(List<List<double>> positions) {
    double height = 0;
    for (final columnPositions in positions) {
      if (columnPositions.isEmpty) continue;
      height = max(height, columnPositions.last + matchHeight);
    }
    return height + 8;
  }
}

class _BracketColumn extends StatelessWidget {
  final BracketColumnData column;
  final List<double> topOffsets;
  final double headerHeight;
  final double matchHeight;

  const _BracketColumn({
    required this.column,
    required this.topOffsets,
    required this.headerHeight,
    required this.matchHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: headerHeight,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  column.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (int index = 0; index < column.ties.length; index++)
          Positioned(
            top: topOffsets[index],
            left: 0,
            right: 0,
            height: matchHeight,
            child: _BracketTieCard(tie: column.ties[index]),
          ),
      ],
    );
  }
}

class _BracketTieCard extends StatelessWidget {
  final BracketTieData tie;

  const _BracketTieCard({required this.tie});

  @override
  Widget build(BuildContext context) {
    final match = tie.navigableMatch;
    final homeTeam = tie.primaryHomeTeam;
    final awayTeam = tie.primaryAwayTeam;
    final score = tie.firstMatch['score']?['fullTime'] ?? {};
    final homeAggregate =
        tie.isMultiLeg ? tie.aggregateForTeam(homeTeam['id']) : score['home'];
    final awayAggregate =
        tie.isMultiLeg ? tie.aggregateForTeam(awayTeam['id']) : score['away'];
    final isUpcoming = score['home'] == null && score['away'] == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (isUpcoming) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpcomingMatchScreen(match: match),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MatchScreen(matchId: match['id'].toString()),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withAlpha(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (tie.isMultiLeg)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Text(
                        'Aggregate',
                        style: TextStyle(
                          color: AppColors.subtitleTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${tie.matches.length} legs',
                        style: const TextStyle(
                          color: AppColors.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              _TeamLine(
                team: homeTeam,
                score: homeAggregate,
                isWinner: _isWinner(homeAggregate, awayAggregate),
              ),
              const SizedBox(height: 8),
              _TeamLine(
                team: awayTeam,
                score: awayAggregate,
                isWinner: _isWinner(awayAggregate, homeAggregate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isWinner(dynamic teamScore, dynamic opponentScore) {
    if (teamScore == null || opponentScore == null) return false;
    return (teamScore as int) > (opponentScore as int);
  }
}

class _TeamLine extends StatelessWidget {
  final Map team;
  final dynamic score;
  final bool isWinner;

  const _TeamLine({
    required this.team,
    required this.score,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: CrestImage(
            crestUrl: team['crest'],
            width: 22,
            height: 22,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            (team['shortName'] ?? team['name'] ?? 'TBD').toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  isWinner ? AppColors.textColor : AppColors.subtitleTextColor,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score?.toString() ?? '-',
          style: TextStyle(
            color: isWinner ? AppColors.accentColor : AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _BracketConnectorPainter extends CustomPainter {
  final List<BracketColumnData> columns;
  final List<List<double>> positions;
  final double columnWidth;
  final double columnGap;
  final double headerHeight;
  final double matchHeight;

  const _BracketConnectorPainter({
    required this.columns,
    required this.positions,
    required this.columnWidth,
    required this.columnGap,
    required this.headerHeight,
    required this.matchHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentColor.withAlpha(105)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int columnIndex = 0; columnIndex < columns.length - 1; columnIndex++) {
      final fromPositions = positions[columnIndex];
      final toPositions = positions[columnIndex + 1];
      if (fromPositions.isEmpty || toPositions.isEmpty) continue;

      for (int targetIndex = 0;
          targetIndex < toPositions.length;
          targetIndex++) {
        final firstSource = targetIndex * 2;
        final secondSource = firstSource + 1;
        if (firstSource >= fromPositions.length) continue;

        final sourceIndexes = [
          firstSource,
          if (secondSource < fromPositions.length) secondSource,
        ];

        for (final sourceIndex in sourceIndexes) {
          _drawConnector(canvas, paint, columnIndex, sourceIndex, targetIndex);
        }
      }
    }
  }

  void _drawConnector(
    Canvas canvas,
    Paint paint,
    int columnIndex,
    int sourceIndex,
    int targetIndex,
  ) {
    final startX = columnIndex * (columnWidth + columnGap) + columnWidth;
    final startY = positions[columnIndex][sourceIndex] + matchHeight / 2;
    final endX = (columnIndex + 1) * (columnWidth + columnGap);
    final endY = positions[columnIndex + 1][targetIndex] + matchHeight / 2;
    final midX = startX + columnGap / 2;

    final path = Path()
      ..moveTo(startX, startY)
      ..lineTo(midX, startY)
      ..lineTo(midX, endY)
      ..lineTo(endX, endY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BracketConnectorPainter oldDelegate) {
    return oldDelegate.columns != columns || oldDelegate.positions != positions;
  }
}
