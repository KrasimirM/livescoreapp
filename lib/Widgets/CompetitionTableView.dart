import 'package:LiveScore/constants.dart';
import 'package:LiveScore/Widgets/CrestImage.dart';
import 'package:flutter/material.dart';

class CompetitionTableView extends StatelessWidget {
  final List standings;

  const CompetitionTableView({Key? key, required this.standings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sections = standings.where((standing) {
      final table = standing['table'] ?? [];
      return table is List && table.isNotEmpty;
    }).toList();

    return ListView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        for (int index = 0; index < sections.length; index++) ...[
          if (sections.length > 1)
            _GroupTitle(label: _standingLabel(sections[index], index)),
          _HeaderRow(),
          const SizedBox(height: 8),
          ...(sections[index]['table'] as List)
              .map((team) => _TeamStandingRow(team: team)),
          if (index != sections.length - 1) const SizedBox(height: 22),
        ],
      ],
    );
  }

  String _standingLabel(dynamic standing, int index) {
    final group = (standing['group'] ?? '').toString().trim();
    if (group.isNotEmpty) return group.replaceAll('_', ' ');

    final stage = (standing['stage'] ?? '').toString().trim();
    if (stage.isNotEmpty) return stage.replaceAll('_', ' ');

    return 'Group ${String.fromCharCode(65 + index)}';
  }
}

class _GroupTitle extends StatelessWidget {
  final String label;

  const _GroupTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(180),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 34,
            child: Text(
              '#',
              style: TextStyle(
                color: AppColors.subtitleTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            flex: 4,
            child: Text(
              'Club',
              style: TextStyle(
                color: AppColors.subtitleTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...['PL', 'W', 'D', 'L', 'GD', 'Pts'].map(
            (label) => _StatHeader(label: label),
          ),
        ],
      ),
    );
  }
}

class _TeamStandingRow extends StatelessWidget {
  final dynamic team;

  const _TeamStandingRow({required this.team});

  @override
  Widget build(BuildContext context) {
    final club = team['team'] ?? {};
    final shortName = (club['shortName'] ?? club['name'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              team['position'].toString(),
              style: const TextStyle(
                color: AppColors.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CrestImage(
                    crestUrl: club['crest'],
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    shortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _StatValue(value: team['playedGames']),
          _StatValue(value: team['won']),
          _StatValue(value: team['draw']),
          _StatValue(value: team['lost']),
          _StatValue(value: team['goalDifference']),
          _StatValue(value: team['points'], isStrong: true),
        ],
      ),
    );
  }
}

class _StatHeader extends StatelessWidget {
  final String label;

  const _StatHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.subtitleTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  final dynamic value;
  final bool isStrong;

  const _StatValue({required this.value, this.isStrong = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Text(
        value.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isStrong ? AppColors.accentColor : AppColors.textColor,
          fontWeight: isStrong ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
