import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/onboarding_provider.dart';

class LanguageStepWidget extends StatelessWidget {
  const LanguageStepWidget({super.key});

  static const List<Map<String, dynamic>> _languages = [
    {
      'id': 'English',
      'title': 'English',
      'subtitle': 'Full English practice mode',
      'icon': Icons.language_rounded,
    },
    {
      'id': 'Hindi',
      'title': 'Hindi (हिंदी)',
      'subtitle': 'Hindi hints with English practice',
      'icon': Icons.translate_rounded,
    },
    {
      'id': 'Hinglish',
      'title': 'Hinglish',
      'subtitle': 'Bilingual Hindi + English mix',
      'icon': Icons.record_voice_over_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OnboardingProvider>();
    final selectedLang = provider.data.preferredLanguage;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: _languages.map((lang) {
          final isSelected = selectedLang == lang['id'];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              onTap: () => provider.setLanguage(lang['id'] as String),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                            : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          lang['icon'] as IconData,
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark ? AppTheme.textMain : AppTheme.textMainLight),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppTheme.primary
                                  : (isDark ? AppTheme.textMain : AppTheme.textMainLight),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lang['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
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
      ),
    );
  }
}
