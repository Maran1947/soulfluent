import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/onboarding_provider.dart';

class GoalsStepWidget extends StatelessWidget {
  const GoalsStepWidget({super.key});

  static const List<Map<String, dynamic>> _goalOptions = [
    {
      'id': 'Job Interviews',
      'title': 'Job Interviews & Placements',
      'subtitle': 'Corporate Q&A & elevator pitches',
      'icon': Icons.work_outline_rounded,
    },
    {
      'id': 'Vocabulary Expansion',
      'title': 'Vocabulary & Idioms',
      'subtitle': 'Advanced words & daily expressions',
      'icon': Icons.menu_book_rounded,
    },
    {
      'id': 'Pronunciation & Accent',
      'title': 'Pronunciation & Accent',
      'subtitle': 'Clear articulation & reducing MTI',
      'icon': Icons.record_voice_over_outlined,
    },
    {
      'id': 'Workplace Fluency',
      'title': 'Workplace & Meetings',
      'subtitle': 'Office talks & client presentations',
      'icon': Icons.business_center_outlined,
    },
    {
      'id': 'Confidence & Stage Fear',
      'title': 'Confidence & Stage Fear',
      'subtitle': 'Overcoming hesitation & mental blocks',
      'icon': Icons.psychology_outlined,
    },
    {
      'id': 'Personal Interests',
      'title': 'Personal & Casual Talk',
      'subtitle': 'Everyday conversations & stories',
      'icon': Icons.chat_bubble_outline_rounded,
    },
    {
      'id': 'Daily Challenges',
      'title': 'Daily Practice Drills',
      'subtitle': 'Bite-sized speaking habits',
      'icon': Icons.bolt_rounded,
    },
    {
      'id': 'Others',
      'title': 'Others & Custom Goals',
      'subtitle': 'General fluency exploration',
      'icon': Icons.auto_awesome_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OnboardingProvider>();
    final selectedGoals = provider.data.selectedGoals;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select your focus areas',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (selectedGoals.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedGoals.length} selected',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ..._goalOptions.map((goal) {
            final isSelected = selectedGoals.contains(goal['id']);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => provider.toggleGoal(goal['id'] as String),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(isDark ? 0.18 : 0.1)
                        : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.18),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withOpacity(0.2)
                              : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            goal['icon'] as IconData,
                            color: isSelected
                                ? AppTheme.primary
                                : (isDark ? AppTheme.textMain : AppTheme.textMainLight),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppTheme.primary
                                    : (isDark ? AppTheme.textMain : AppTheme.textMainLight),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              goal['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppTheme.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : (isDark ? AppTheme.textMuted : AppTheme.textMutedLight),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
