import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/l10n/app_localizations.dart';
import 'package:fluentsoul_mobile/providers/locale_provider.dart';
import 'package:fluentsoul_mobile/providers/onboarding_provider.dart';
import 'package:fluentsoul_mobile/widgets/logo_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = context.read<OnboardingProvider>().currentIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    context.read<OnboardingProvider>().goToStep(index);
  }

  void _nextStep() {
    final provider = context.read<OnboardingProvider>();
    if (!provider.isLastStep && provider.currentStep.isValid(provider.data)) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    final provider = context.read<OnboardingProvider>();
    if (!provider.isFirstStep) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OnboardingProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final currentStep = provider.currentStep;
    final isLastStep = provider.isLastStep;
    final isValid = currentStep.isValid(provider.data);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.background : AppTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Brand Header & Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (!provider.isFirstStep && !isLastStep)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 20),
                          onPressed: _previousStep,
                          color: isDark
                              ? AppTheme.textMain
                              : AppTheme.textMainLight,
                        )
                      else
                        const SizedBox(width: 40),
                      Expanded(
                        child: Column(
                          children: [
                            const Center(
                              child: FluentSoulBrandText(
                                fontSize: 20,
                                showLogo: true,
                                showTagline: false,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Step ${provider.currentIndex + 1} of ${provider.steps.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppTheme.textMuted
                                    : AppTheme.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: provider.progressRatio,
                      minHeight: 5,
                      backgroundColor:
                          isDark ? AppTheme.cardDark : AppTheme.borderLight,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Step Title & Subtitle Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(currentStep.icon,
                            color: AppTheme.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            currentStep.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.textMain
                                  : AppTheme.textMainLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentStep.subtitle,
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
            ),

            const SizedBox(height: 4),

            // PageView of Dynamic Steps
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Controlled via buttons
                onPageChanged: _onPageChanged,
                itemCount: provider.steps.length,
                itemBuilder: (context, index) {
                  return provider.steps[index].builder(context);
                },
              ),
            ),

            // Bottom Navigation Footer (Hides on final plan reveal step)
            if (!isLastStep)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                  border: Border(
                    top: BorderSide(
                      color:
                          isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (!provider.isFirstStep)
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: isDark
                                  ? AppTheme.borderDark
                                  : AppTheme.borderLight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textMain
                                  : AppTheme.textMainLight,
                            ),
                          ),
                        ),
                      ),
                    if (!provider.isFirstStep) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isValid
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: isValid ? _nextStep : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            disabledBackgroundColor:
                                isDark ? Colors.white10 : Colors.black12,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                provider.isFirstStep
                                    ? 'Get Started'
                                    : 'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isValid ? Colors.white : Colors.white38,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: isValid ? Colors.white : Colors.white38,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
