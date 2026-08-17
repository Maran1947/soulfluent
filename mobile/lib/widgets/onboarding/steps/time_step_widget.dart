import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    {
      'minutes': 1,
      'label': 'Flexible Practice',
      'tag': 'Flexible',
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OnboardingProvider>();
    final selectedMins = provider.data.dailyGoalMinutes;

    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: _timeOptions.map((time) {
          final isSelected = selectedMins == time['minutes'];
          final hasSubtitle = time['subtitle'] != null;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => provider.setDailyMinutes(time['minutes'] as int),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withOpacity(isDark ? 0.15 : 0.08)
                      : cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : borderColor,
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.15),
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
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9)),
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            time['label'] as String,
                            style: GoogleFonts.sora(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppTheme.primary
                                  : headingColor,
                            ),
                          ),
                          if (hasSubtitle) ...[
                            const SizedBox(height: 2),
                            Text(
                              time['subtitle'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        time['tag'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : subtitleColor,
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
