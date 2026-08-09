import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/onboarding_provider.dart';

class PlanGeneratorStepWidget extends StatefulWidget {
  const PlanGeneratorStepWidget({super.key});

  @override
  State<PlanGeneratorStepWidget> createState() => _PlanGeneratorStepWidgetState();
}

class _PlanGeneratorStepWidgetState extends State<PlanGeneratorStepWidget> {
  int _progressStep = 0;
  Timer? _timer;

  final List<String> _loadingMessages = [
    'Analyzing CEFR level & fluency goals...',
    'Calibrating speech feedback & AI bot personas...',
    'Customizing daily speaking practice targets...',
    'Finalizing your personalized FluentSoul plan...',
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      if (_progressStep < _loadingMessages.length) {
        setState(() {
          _progressStep++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OnboardingProvider>();
    final data = provider.data;
    final isDoneLoading = _progressStep >= _loadingMessages.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFFFF8A65)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isDoneLoading
                ? 'Your Custom Plan is Ready!'
                : 'Building Your Fluency Plan...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textMain : AppTheme.textMainLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isDoneLoading
                ? 'We customized FluentSoul based on your choices.'
                : 'Please wait while AI configures your learning path.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 20),

          // Loading checklist steps
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            child: Column(
              children: List.generate(_loadingMessages.length, (index) {
                final isCompleted = _progressStep > index;
                final isCurrent = _progressStep == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppTheme.primary
                              : (isCurrent
                                  ? AppTheme.primary.withOpacity(0.2)
                                  : (isDark ? Colors.white10 : Colors.black12)),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : (isCurrent
                                ? const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primary,
                                    ),
                                  )
                                : null),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _loadingMessages[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent || isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isCompleted
                                ? (isDark ? AppTheme.textMain : AppTheme.textMainLight)
                                : (isCurrent
                                    ? AppTheme.primary
                                    : (isDark
                                        ? AppTheme.textMuted
                                        : AppTheme.textMutedLight)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          if (isDoneLoading) ...[
            const SizedBox(height: 18),
            // Customized Plan Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppTheme.primary.withOpacity(0.2),
                          const Color(0xFF1E293B),
                        ]
                      : [
                          AppTheme.primary.withOpacity(0.1),
                          Colors.white,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level: ${data.cefrLevel.isNotEmpty ? data.cefrLevel : "B1"}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        'Language: ${data.preferredLanguage.isNotEmpty ? data.preferredLanguage : "English"}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryMetric(
                          context,
                          'Daily Goal',
                          '${data.dailyGoalMinutes > 0 ? data.dailyGoalMinutes : 10} Mins',
                          Icons.timer_rounded,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryMetric(
                          context,
                          'Focus Areas',
                          '${data.selectedGoals.length} Selected',
                          Icons.star_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.completeOnboarding(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Start My Journey',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(
      BuildContext context, String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textMain : AppTheme.textMainLight,
          ),
        ),
      ],
    );
  }
}
