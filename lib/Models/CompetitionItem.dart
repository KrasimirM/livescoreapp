import 'package:flutter/material.dart';

class CompetitionItem {
  final String image;
  final String code;
  final String name;
  final String region;
  final Color accent;
  final List<String> features;
  final IconData icon;
  final bool featured;

  const CompetitionItem({
    required this.image,
    required this.code,
    required this.name,
    required this.region,
    required this.accent,
    required this.features,
    required this.icon,
    this.featured = false,
  });
}
