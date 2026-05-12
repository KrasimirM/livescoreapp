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
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((category) {
          final selected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(QuizCategory.label(category)),
              selected: selected,
              onSelected: (_) => onChanged(category),
              selectedColor: AppColors.primaryColor,
              backgroundColor: AppColors.cardBackgroundColor,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.subtitleTextColor,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected ? AppColors.primaryColor : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
