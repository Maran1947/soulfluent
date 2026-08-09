import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/onboarding_provider.dart';

class CEFRStepWidget extends StatelessWidget {
  const CEFRStepWidget({super.key});

  static const List<Map<String, String>> _cefrLevels = [
    {
      'code': 'A1',
      'title': 'A1 - Beginner',
      'subtitle': 'Know basic words, building sentences',
      'badge': 'Starter',
    },
    {
      'code': 'A2',
      'title': 'A2 - Elementary',
      'subtitle': 'Form sentences, building confidence',
      'badge': 'Learner',
    },
    {
      'code': 'B1',
      'title': 'B1 - Intermediate',
      'subtitle': 'Express ideas, improving vocabulary & speed',
      'badge': 'Intermediate',
    },
    {
      'code': 'B2',
      'title': 'B2 - Upper Intermediate',
      'subtitle': 'Fluent speaking, refining corporate tone',
      'badge': 'Confident',
    },
    {
      'code': 'C1',
      'title': 'C1 - Advanced',
      'subtitle': 'Mastering presentations & advanced debate',
      'badge': 'Master',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OnboardingProvider>();
    final selectedCEFR = provider.data.cefrLevel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: _cefrLevels.map((level) {
          final isSelected = selectedCEFR == level['code'];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => provider.setCEFRLevel(level['code']!),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark
                                ? Colors.white10
                                : Colors.black.withOpacity(0.06)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        level['code']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppTheme.textMain
                                  : AppTheme.textMainLight),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  level['title']!,
                                  style: TextStyle(
                                    fontSize: 15,
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
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary.withOpacity(0.2)
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.black.withOpacity(0.05)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  level['badge']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppTheme.primary
                                        : (isDark
                                            ? AppTheme.textMuted
                                            : AppTheme.textMutedLight),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            level['subtitle']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppTheme.textMuted
                                  : AppTheme.textMutedLight,
                            ),
                          ),
                        ],
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
