import 'package:flutter/material.dart';

class MatchFilter extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onChanged;

  const MatchFilter({
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Filter Matches:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRadioButton('upcoming', 'Upcoming'),
            _buildRadioButton('past', 'Past'),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioButton(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: selectedFilter,
            onChanged: (String? newValue) {
              onChanged(newValue!);
            },
            activeColor: Colors.orange,
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
