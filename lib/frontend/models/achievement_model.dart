import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final bool earned;
  final bool locked;
  final LinearGradient? gradient;

  AchievementModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    this.earned = false,
    this.locked = false,
    this.gradient,
  });
}