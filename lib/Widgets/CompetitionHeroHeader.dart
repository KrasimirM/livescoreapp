import 'package:LiveScore/constants.dart';
import 'package:flutter/material.dart';

class CompetitionHeroHeader extends StatelessWidget {
  final String name;
  final String code;
  final int teamCount;
  final int bracketMatchCount;

  const CompetitionHeroHeader({
    Key? key,
    required this.name,
    required this.code,
    required this.teamCount,
    required this.bracketMatchCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.white.withAlpha(18)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryColor.withAlpha(90)),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    color: AppColors.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _Metric(label: 'Teams', value: teamCount.toString()),
          if (bracketMatchCount > 0) ...[
            const SizedBox(width: 8),
            _Metric(label: 'KO', value: bracketMatchCount.toString()),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.subtitleTextColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
