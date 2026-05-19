import 'package:flutter/material.dart';
import 'package:LiveScore/constants.dart';

class MatchFilter extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onChanged;

  const MatchFilter({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(16)),
        ),
        child: Row(
          children: [
            _buildSegment(
              value: 'upcoming',
              label: 'Upcoming',
              icon: Icons.schedule,
            ),
            const SizedBox(width: 6),
            _buildSegment(
              value: 'past',
              label: 'Past',
              icon: Icons.history,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final selected = selectedFilter == value;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.secondaryAccentColor,
                    ],
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? AppColors.backgroundColor
                    : AppColors.mutedTextColor,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? AppColors.backgroundColor
                        : AppColors.subtitleTextColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
