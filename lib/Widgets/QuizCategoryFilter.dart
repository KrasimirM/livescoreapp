import 'package:flutter/material.dart';
import '../Models/QuizCategory.dart';
import '../constants.dart';

class QuizCategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onChanged;
  final bool includeAll;

  const QuizCategoryFilter({
    Key? key,
    required this.selectedCategory,
    required this.onChanged,
    this.includeAll = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = includeAll ? QuizCategory.filters : QuizCategory.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: categories.map((category) {
          final selected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryColor.withAlpha(45)
                      : AppColors.surfaceColor.withAlpha(225),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryColor
                        : Colors.white.withAlpha(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForCategory(category),
                      size: 17,
                      color: selected
                          ? AppColors.primaryColor
                          : AppColors.mutedTextColor,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      QuizCategory.label(category),
                      style: TextStyle(
                        color: selected
                            ? AppColors.textColor
                            : AppColors.subtitleTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case QuizCategory.history:
        return Icons.history_edu;
      case QuizCategory.teams:
        return Icons.shield;
      case QuizCategory.players:
        return Icons.sports_soccer;
      default:
        return Icons.grid_view;
    }
  }
}
