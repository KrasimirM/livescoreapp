import 'package:flutter/material.dart';
import 'package:LiveScore/constants.dart';

class PinnedProfileMatch extends StatelessWidget {
  final Map<String, dynamic> match;
  final ValueChanged<Map<String, dynamic>> onOpen;

  const PinnedProfileMatch({
    super.key,
    required this.match,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (match.isEmpty) return const SizedBox.shrink();
    final home = match['homeTeam'] ?? {};
    final away = match['awayTeam'] ?? {};

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onOpen(match),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.accentColor.withAlpha(28),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentColor.withAlpha(85)),
        ),
        child: Row(
          children: [
            const Icon(Icons.push_pin, color: AppColors.accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pinned Match',
                    style: TextStyle(
                      color: AppColors.mutedTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${home['shortName'] ?? home['name']} vs ${away['shortName'] ?? away['name']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: AppColors.accentColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHero extends StatelessWidget {
  final String email;
  final String favoriteTeam;

  const ProfileHero({
    super.key,
    required this.email,
    required this.favoriteTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(235),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.secondaryAccentColor,
                ],
              ),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.backgroundColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  favoriteTeam,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.subtitleTextColor,
                    fontSize: 14,
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

class MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const MiniMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor.withAlpha(235),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: AppColors.mutedTextColor,
                    fontSize: 12,
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

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }
}

class ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor.withAlpha(225),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withAlpha(35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.subtitleTextColor),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.mutedTextColor,
        ),
      ),
    );
  }
}
