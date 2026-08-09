import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/onboarding_provider.dart';

class TimeStepWidget extends StatelessWidget {
  const TimeStepWidget({super.key});

  static const List<Map<String, dynamic>> _timeOptions = [
    {
      'minutes': 5,
      'label': '5 Mins / Day',
      'tag': 'Casual',
      'icon': Icons.bolt_rounded,
    },
    {
      'minutes': 10,
      'label': '10 Mins / Day',
      'tag': 'Recommended',
      'icon': Icons.local_fire_department_rounded,
    },
    {
      'minutes': 15,
      'label': '15 Mins / Day',
      'tag': 'Dedicated',
      'icon': Icons.fitness_center_rounded,
    },
    {
      'minutes': 30,
      'label': '30 Mins / Day',
      'tag': 'Intense',
      'icon': Icons.emoji_events_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OnboardingProvider>();
    final selectedMins = provider.data.dailyGoalMinutes;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: _timeOptions.map((time) {
          final isSelected = selectedMins == time['minutes'];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              onTap: () => provider.setDailyMinutes(time['minutes'] as int),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                            color: AppTheme.primary.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary.withOpacity(0.2)
                            : (isDark
                                ? Colors.white10
                                : Colors.black.withOpacity(0.04)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          time['icon'] as IconData,
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark
                                  ? AppTheme.textMain
                                  : AppTheme.textMainLight),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        time['label'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark
                                  ? AppTheme.textMain
                                  : AppTheme.textMainLight),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark
                                ? Colors.white10
                                : Colors.black.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        time['tag'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppTheme.textMuted
                                  : AppTheme.textMutedLight),
                        ),
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
}
