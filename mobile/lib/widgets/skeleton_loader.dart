import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soulfluent_mobile/config/theme.dart';
import 'package:soulfluent_mobile/widgets/logo_widgets.dart';

/// Animated Pulsing Skeleton Base Widget
class SkeletonItem extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonItem({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 14.0,
  });

  @override
  State<SkeletonItem> createState() => _SkeletonItemState();
}

class _SkeletonItemState extends State<SkeletonItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Skeleton Card for History Screen API loading
class HistorySkeletonCard extends StatelessWidget {
  const HistorySkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonItem(width: 90, height: 18, borderRadius: 10),
              SkeletonItem(width: 75, height: 22, borderRadius: 14),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonItem(width: double.infinity, height: 20, borderRadius: 8),
          const SizedBox(height: 8),
          const SkeletonItem(width: 220, height: 20, borderRadius: 8),
          const SizedBox(height: 18),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonItem(width: 110, height: 16, borderRadius: 8),
              SkeletonItem(width: 70, height: 16, borderRadius: 8),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton View for Feedback Report API loading
class ReportSkeletonView extends StatelessWidget {
  const ReportSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Skeleton Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonItem(width: 80, height: 32, borderRadius: 12),
              SkeletonItem(width: 140, height: 32, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 20),

          // Main Hero Score Board Skeleton Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                const SkeletonItem(width: 96, height: 96, borderRadius: 48),
                const SizedBox(height: 14),
                const SkeletonItem(width: 160, height: 24, borderRadius: 12),
                const SizedBox(height: 20),
                Divider(color: borderColor, height: 1),
                const SizedBox(height: 18),
                const SkeletonItem(width: double.infinity, height: 16, borderRadius: 8),
                const SizedBox(height: 12),
                const SkeletonItem(width: double.infinity, height: 16, borderRadius: 8),
                const SizedBox(height: 12),
                const SkeletonItem(width: double.infinity, height: 16, borderRadius: 8),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Metric Cards Skeletons
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonItem(width: 180, height: 20, borderRadius: 8),
                SizedBox(height: 14),
                SkeletonItem(width: double.infinity, height: 14, borderRadius: 6),
                SizedBox(height: 10),
                SkeletonItem(width: double.infinity, height: 14, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rich Animated Detailed Report Analysis Loader Widget
class AnimatedReportAnalysisLoader extends StatefulWidget {
  const AnimatedReportAnalysisLoader({super.key});

  @override
  State<AnimatedReportAnalysisLoader> createState() =>
      _AnimatedReportAnalysisLoaderState();
}

class _AnimatedReportAnalysisLoaderState
    extends State<AnimatedReportAnalysisLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _stepTimer;
  int _currentStepIndex = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'icon': Icons.mic_rounded,
      'title': 'Transcribing Audio & WPM',
      'subtitle': 'Measuring speaking speed and sentence structure...',
    },
    {
      'icon': Icons.menu_book_rounded,
      'title': 'Analyzing Vocabulary & Grammar',
      'subtitle': 'Detecting filler words, syntax fragments & richness...',
    },
    {
      'icon': Icons.psychology_rounded,
      'title': 'Evaluating Argument Logic',
      'subtitle': 'Scoring distinct points made & counter-rebuttals...',
    },
    {
      'icon': Icons.auto_awesome_rounded,
      'title': 'Formulating AI Recommendations',
      'subtitle': 'Synthesizing tailored feedback and growth areas...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _stepTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (mounted) {
        setState(() {
          _currentStepIndex = (_currentStepIndex + 1) % _steps.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0);
    final headingColor = isDark ? AppTheme.textMain : AppTheme.textMainLight;
    final subtitleColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    final step = _steps[_currentStepIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Animated Pulse Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(isDark ? 0.2 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Pulsing Logo Icon Circle
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.08);
                    final glowOpacity = 0.2 + (_pulseController.value * 0.25);

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(glowOpacity),
                        ),
                        child: const SoulFluentLogo(size: 62),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Analyzing Session Performance...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                  ),
                ),

                const SizedBox(height: 16),

                // Animated Step Ticker Container
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Container(
                    key: ValueKey(_currentStepIndex),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          step['icon'] as IconData,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step['title'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step['subtitle'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Skeleton Preview Below
          const ReportSkeletonView(),
        ],
      ),
    );
  }
}
