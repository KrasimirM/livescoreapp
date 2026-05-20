import 'package:LiveScore/Screens/MatchScreen.dart';
import 'package:LiveScore/Screens/UpcomingMatchScreen.dart';
import 'package:LiveScore/Widgets/CrestImage.dart';
import 'package:LiveScore/constants.dart';
import 'package:flutter/material.dart';

class CompetitionOverviewView extends StatelessWidget {
  final String competitionName;
  final List standings;
  final List matches;
  final bool hasBracket;

  const CompetitionOverviewView({
    Key? key,
    required this.competitionName,
    required this.standings,
    required this.matches,
    required this.hasBracket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final table = _allTableRows(standings);
    final upcomingMatches = _upcomingMatches(matches).take(5).toList();

    return ListView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
      children: [
        _HubIntro(
          competitionName: competitionName,
          teamCount: table.length,
          matchCount: matches.length,
          hasBracket: hasBracket,
        ),
        const SizedBox(height: 16),
        _SectionHeader(
          title: 'Next matches',
          icon: Icons.event,
          subtitle: upcomingMatches.isEmpty
              ? 'No scheduled matches'
              : 'Swipe and open preview',
        ),
        const SizedBox(height: 10),
        if (upcomingMatches.isEmpty)
          const _EmptyHubCard(
            icon: Icons.event_busy,
            message: 'No upcoming matches available.',
          )
        else
          SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: upcomingMatches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _MatchPreviewCard(match: upcomingMatches[index]);
              },
            ),
          ),
        const SizedBox(height: 18),
        _MatchExplorer(matches: matches),
        const SizedBox(height: 18),
        _CompetitionPulse(
          matches: matches,
          standings: standings,
          hasBracket: hasBracket,
        ),
        const SizedBox(height: 18),
        if (table.isNotEmpty) ...[
          _SectionHeader(
            title: 'Team Spotlight',
            icon: Icons.shuffle,
            subtitle: 'Shuffle through teams and quick stats',
          ),
          const SizedBox(height: 10),
          _TeamSpotlight(table: table),
        ] else
          const _EmptyHubCard(
            icon: Icons.table_rows,
            message: 'No standings available for interactive insights.',
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _allTableRows(List standings) {
    final rows = <Map<String, dynamic>>[];
    for (final standing in standings) {
      final table = standing['table'];
      if (table is! List) continue;
      final group =
          (standing['group'] ?? standing['stage'] ?? '').toString().trim();
      for (final row in table) {
        if (row is Map) {
          final tableRow = Map<String, dynamic>.from(row);
          if (group.isNotEmpty) tableRow['group'] = group;
          rows.add(tableRow);
        }
      }
    }
    rows.sort((a, b) {
      final groupA = (a['group'] ?? '').toString();
      final groupB = (b['group'] ?? '').toString();
      final groupCompare = groupA.compareTo(groupB);
      if (groupCompare != 0) return groupCompare;
      return _asInt(a['position']).compareTo(_asInt(b['position']));
    });
    return rows;
  }

  List<Map<String, dynamic>> _upcomingMatches(List matches) {
    final result = matches
        .where((match) {
          if (match is! Map) return false;
          final score = match['score']?['fullTime'] ?? {};
          return score['home'] == null && score['away'] == null;
        })
        .map((match) => Map<String, dynamic>.from(match as Map))
        .toList();

    result.sort((a, b) => _matchDate(a).compareTo(_matchDate(b)));
    return result;
  }
}

class _HubIntro extends StatelessWidget {
  final String competitionName;
  final int teamCount;
  final int matchCount;
  final bool hasBracket;

  const _HubIntro({
    required this.competitionName,
    required this.teamCount,
    required this.matchCount,
    required this.hasBracket,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryAccentColor.withAlpha(34),
            AppColors.cardBackgroundColor.withAlpha(238),
            AppColors.primaryColor.withAlpha(24),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Competition hub',
                      style: TextStyle(
                        color: AppColors.mutedTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      competitionName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        height: 1.04,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(34),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryColor.withAlpha(95),
                  ),
                ),
                child: Icon(
                  hasBracket ? Icons.account_tree : Icons.table_rows,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HubMetric(
                  icon: Icons.groups,
                  label: 'Teams',
                  value: teamCount.toString(),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _HubMetric(
                  icon: Icons.sports_soccer,
                  label: 'Matches',
                  value: matchCount.toString(),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _HubMetric(
                  icon: hasBracket ? Icons.account_tree : Icons.table_rows,
                  label: hasBracket ? 'Path' : 'Type',
                  value: hasBracket ? 'KO' : 'Table',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HubMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HubMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withAlpha(205),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 16),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.mutedTextColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentColor, size: 21),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.mutedTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchPreviewCard extends StatelessWidget {
  final Map<String, dynamic> match;

  const _MatchPreviewCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final home = match['homeTeam'] ?? {};
    final away = match['awayTeam'] ?? {};

    return SizedBox(
      width: 250,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UpcomingMatchScreen(match: match),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundColor.withAlpha(235),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryColor.withAlpha(70)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _TinyTeam(team: home),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: AppColors.accentColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _TinyTeam(team: away),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: AppColors.mutedTextColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _dateLabel(match['utcDate']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.subtitleTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.primaryColor,
                    size: 17,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyTeam extends StatelessWidget {
  final dynamic team;

  const _TinyTeam({required this.team});

  @override
  Widget build(BuildContext context) {
    final name = (team['shortName'] ?? team['name'] ?? '').toString();
    return Expanded(
      child: Column(
        children: [
          CrestImage(
            crestUrl: team['crest'],
            width: 34,
            height: 34,
          ),
          const SizedBox(height: 7),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchExplorer extends StatefulWidget {
  final List matches;

  const _MatchExplorer({required this.matches});

  @override
  State<_MatchExplorer> createState() => _MatchExplorerState();
}

class _MatchExplorerState extends State<_MatchExplorer> {
  String _mode = 'upcoming';

  @override
  Widget build(BuildContext context) {
    final matches = _filteredMatches().take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Match Explorer',
          icon: Icons.manage_search,
          subtitle: 'Switch between upcoming and recent matches',
        ),
        const SizedBox(height: 10),
        _ExplorerSwitch(
          selected: _mode,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        const SizedBox(height: 10),
        if (matches.isEmpty)
          _EmptyHubCard(
            icon: Icons.search_off,
            message: _mode == 'upcoming'
                ? 'No upcoming matches to explore.'
                : 'No recent results to explore.',
          )
        else
          ...matches.map(
            (match) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _ExplorerMatchTile(match: match),
            ),
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _filteredMatches() {
    final result = widget.matches.whereType<Map>().map((match) {
      return Map<String, dynamic>.from(match);
    }).where((match) {
      final score = match['score']?['fullTime'] ?? {};
      final isUpcoming = score['home'] == null && score['away'] == null;
      return _mode == 'upcoming' ? isUpcoming : !isUpcoming;
    }).toList();

    result.sort((a, b) {
      final compare = _matchDate(a).compareTo(_matchDate(b));
      return _mode == 'upcoming' ? compare : -compare;
    });
    return result;
  }
}

class _ExplorerSwitch extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _ExplorerSwitch({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Row(
        children: [
          _ExplorerSegment(
            label: 'Upcoming',
            icon: Icons.schedule,
            selected: selected == 'upcoming',
            onTap: () => onChanged('upcoming'),
          ),
          const SizedBox(width: 6),
          _ExplorerSegment(
            label: 'Recent',
            icon: Icons.history,
            selected: selected == 'recent',
            onTap: () => onChanged('recent'),
          ),
        ],
      ),
    );
  }
}

class _ExplorerSegment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ExplorerSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.secondaryAccentColor,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? AppColors.backgroundColor
                    : AppColors.mutedTextColor,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.backgroundColor
                      : AppColors.subtitleTextColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplorerMatchTile extends StatelessWidget {
  final Map<String, dynamic> match;

  const _ExplorerMatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final home = match['homeTeam'] ?? {};
    final away = match['awayTeam'] ?? {};
    final score = match['score']?['fullTime'] ?? {};
    final isUpcoming = score['home'] == null && score['away'] == null;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isUpcoming
                ? UpcomingMatchScreen(match: match)
                : MatchScreen(matchId: match['id'].toString()),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor.withAlpha(228),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(14)),
        ),
        child: Row(
          children: [
            Expanded(child: _MiniTeamLine(team: home)),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isUpcoming
                    ? AppColors.accentColor.withAlpha(35)
                    : AppColors.primaryColor.withAlpha(35),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                isUpcoming ? 'Preview' : '${score['home']} - ${score['away']}',
                style: TextStyle(
                  color: isUpcoming
                      ? AppColors.accentColor
                      : AppColors.primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(child: _MiniTeamLine(team: away, alignEnd: true)),
          ],
        ),
      ),
    );
  }
}

class _MiniTeamLine extends StatelessWidget {
  final dynamic team;
  final bool alignEnd;

  const _MiniTeamLine({required this.team, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    final children = [
      CrestImage(
        crestUrl: team['crest'],
        width: 24,
        height: 24,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          (team['shortName'] ?? team['name'] ?? '').toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    ];

    return Row(
      children: alignEnd ? children.reversed.toList() : children,
    );
  }
}

class _CompetitionPulse extends StatelessWidget {
  final List matches;
  final List standings;
  final bool hasBracket;

  const _CompetitionPulse({
    required this.matches,
    required this.standings,
    required this.hasBracket,
  });

  @override
  Widget build(BuildContext context) {
    final played = matches.whereType<Map>().where((match) {
      final score = match['score']?['fullTime'] ?? {};
      return score['home'] != null && score['away'] != null;
    }).length;
    final upcoming = matches.whereType<Map>().where((match) {
      final score = match['score']?['fullTime'] ?? {};
      return score['home'] == null && score['away'] == null;
    }).length;
    final groups = standings.where((standing) {
      final table = standing['table'];
      return table is List && table.isNotEmpty;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Competition Pulse',
          icon: Icons.monitor_heart,
          subtitle: 'A quick read of what is available right now',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _PulseCard(
              icon: Icons.check_circle,
              label: 'Played',
              value: played.toString(),
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            _PulseCard(
              icon: Icons.schedule,
              label: 'Upcoming',
              value: upcoming.toString(),
              color: AppColors.accentColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _PulseCard(
              icon: Icons.table_rows,
              label: groups > 1 ? 'Groups' : 'Table',
              value: groups.toString(),
              color: AppColors.secondaryAccentColor,
            ),
            const SizedBox(width: 8),
            _PulseCard(
              icon: hasBracket ? Icons.account_tree : Icons.leaderboard,
              label: hasBracket ? 'Bracket' : 'Format',
              value: hasBracket ? 'On' : 'League',
              color: AppColors.accentColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _PulseCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PulseCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor.withAlpha(232),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withAlpha(70)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mutedTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamSpotlight extends StatefulWidget {
  final List<Map<String, dynamic>> table;

  const _TeamSpotlight({required this.table});

  @override
  State<_TeamSpotlight> createState() => _TeamSpotlightState();
}

class _TeamSpotlightState extends State<_TeamSpotlight> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final team = widget.table[_index % widget.table.length];
    final club = team['team'] ?? {};

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(232),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accentColor.withAlpha(70)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CrestImage(
                crestUrl: club['crest'],
                width: 44,
                height: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Spotlight',
                      style: TextStyle(
                        color: AppColors.mutedTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _teamName(team),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _index = (_index + 1) % widget.table.length);
                },
                icon: const Icon(Icons.shuffle),
                color: AppColors.accentColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SpotMetric(label: 'Pos', value: '#${team['position']}'),
              _SpotMetric(label: 'Pts', value: team['points'].toString()),
              _SpotMetric(
                  label: 'GD', value: team['goalDifference'].toString()),
              _SpotMetric(
                  label: 'Played', value: team['playedGames'].toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpotMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SpotMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor.withAlpha(220),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedTextColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHubCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyHubCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.subtitleTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _teamName(Map<String, dynamic> team) {
  final club = team['team'] ?? {};
  return (club['shortName'] ?? club['name'] ?? 'Unknown team').toString();
}

DateTime _matchDate(Map<String, dynamic> match) {
  return DateTime.tryParse((match['utcDate'] ?? '').toString()) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _dateLabel(dynamic rawDate) {
  final parsed = DateTime.tryParse((rawDate ?? '').toString());
  if (parsed == null) return 'Date not confirmed';
  final local = parsed.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day}.${local.month}.${local.year}  $hour:$minute';
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}
