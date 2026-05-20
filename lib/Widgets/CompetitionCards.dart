import 'package:flutter/material.dart';
import 'package:LiveScore/Models/CompetitionItem.dart';
import 'package:LiveScore/constants.dart';

class CompetitionsHeader extends StatelessWidget {
  final int count;

  const CompetitionsHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(232),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Competitions',
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count tournaments with tables, teams, matches and brackets',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedCompetitionCard extends StatelessWidget {
  final CompetitionItem item;
  final ValueChanged<CompetitionItem> onOpen;

  const FeaturedCompetitionCard({
    super.key,
    required this.item,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 286,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onOpen(item),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                item.accent.withAlpha(75),
                AppColors.cardBackgroundColor.withAlpha(245),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: item.accent.withAlpha(120)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CompetitionLogo(item: item, size: 54),
                  const Spacer(),
                  RegionPill(region: item.region, color: item.accent),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 58,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              OpenCompetitionCue(
                label: 'Open ${item.code}',
                color: item.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompetitionCard extends StatelessWidget {
  final CompetitionItem item;
  final ValueChanged<CompetitionItem> onOpen;

  const CompetitionCard({
    super.key,
    required this.item,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onOpen(item),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor.withAlpha(235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(45),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CompetitionLogo(item: item, size: 48),
                const Spacer(),
                RegionPill(
                  region: item.region,
                  color: item.accent,
                  compact: true,
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            OpenCompetitionCue(
              label: 'Open hub',
              color: item.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class CompetitionLogo extends StatelessWidget {
  final CompetitionItem item;
  final double size;

  const CompetitionLogo({
    super.key,
    required this.item,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Image.asset(
        item.image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(item.icon, color: item.accent),
      ),
    );
  }
}

class RegionPill extends StatelessWidget {
  final String region;
  final Color color;
  final bool compact;

  const RegionPill({
    super.key,
    required this.region,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: compact ? 88 : 128),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(140)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.public, color: color, size: compact ? 13 : 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              region,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: compact ? 10 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpenCompetitionCue extends StatelessWidget {
  final String label;
  final Color color;

  const OpenCompetitionCue({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withAlpha(150),
                  color.withAlpha(0),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 5),
        Icon(Icons.arrow_forward, color: color, size: 16),
      ],
    );
  }
}

class IdeasStrip extends StatelessWidget {
  const IdeasStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withAlpha(210),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(14)),
      ),
      child: const Row(
        children: [
          Icon(Icons.swipe, color: AppColors.secondaryAccentColor, size: 21),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Open a competition to jump between hub, table and bracket views.',
              style: TextStyle(
                color: AppColors.subtitleTextColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(Icons.arrow_forward, color: AppColors.primaryColor, size: 18),
        ],
      ),
    );
  }
}

class CompetitionCodeMark extends StatelessWidget {
  final String code;
  final Color color;

  const CompetitionCodeMark({
    super.key,
    required this.code,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      code,
      style: TextStyle(
        color: color.withAlpha(140),
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class CompetitionIdea {
  final IconData icon;
  final String label;

  const CompetitionIdea(this.icon, this.label);
}
