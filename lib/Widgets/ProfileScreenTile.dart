import 'package:flutter/material.dart';

class ProfileScreenTile extends StatelessWidget {
  final String name;
  final String label;

  const ProfileScreenTile({
    required this.name,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.pinkAccent,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          '$name:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
