import 'package:flutter/material.dart';

class OnboardingStepConfig {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool Function(dynamic data) isValid;
  final Widget Function(BuildContext context) builder;

  const OnboardingStepConfig({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isValid,
    required this.builder,
  });
}
