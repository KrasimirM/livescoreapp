import 'package:LiveScore/constants.dart';
import 'package:flutter/material.dart';

class CompetitionEmptyState extends StatelessWidget {
  final String? title;
  final String message;
  final Color color;
  final IconData icon;
  final List<CompetitionEmptyAction> actions;

  const CompetitionEmptyState({
    Key? key,
    this.title,
    required this.message,
    this.color = AppColors.textColor,
    this.icon = Icons.info_outline,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 56, 18, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withAlpha(34),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withAlpha(95)),
                  ),
                  child: Icon(icon, color: color, size: 34),
                ),
                const SizedBox(height: 14),
                if (title != null) ...[
                  Text(
                    title!,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.subtitleTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  ...actions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _EmptyActionCard(action: action),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompetitionEmptyAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const CompetitionEmptyAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.primaryColor,
  });
}

class _EmptyActionCard extends StatelessWidget {
  final CompetitionEmptyAction action;

  const _EmptyActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: action.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundColor.withAlpha(235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: action.color.withAlpha(80)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: action.color.withAlpha(32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: action.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mutedTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward,
              color: AppColors.mutedTextColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
