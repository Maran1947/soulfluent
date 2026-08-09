import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentsoul_mobile/config/theme.dart';

class AIPreviewStepWidget extends StatefulWidget {
  const AIPreviewStepWidget({super.key});

  @override
  State<AIPreviewStepWidget> createState() => _AIPreviewStepWidgetState();
}

class _AIPreviewStepWidgetState extends State<AIPreviewStepWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),

          // Headline
          Text(
            'How You Grow With FluentSoul',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textMain : AppTheme.textMainLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Watch your speaking confidence & vocabulary compound over time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
            ),
          ),
          const SizedBox(height: 18),

          // Main Hero Growth Journey Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1E293B),
                        const Color(0xFF0F172A),
                      ]
                    : [
                        const Color(0xFFFFEBE5),
                        Colors.white,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Header Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fluency Progression',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textMain : AppTheme.textMainLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '+95% Mastery',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Animated Growth Graph Canvas (No Days)
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _GrowthProgressionPainter(
                          progress: _controller.value,
                          isDark: isDark,
                          primaryColor: AppTheme.primary,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Before vs. After Comparison Row
                Row(
                  children: [
                    // Starting Out Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Starting Out',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Hesitant & Pausing',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.textMain : AppTheme.textMainLight,
                              ),
                            ),
                            const Text(
                              '45% Confidence',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    // With FluentSoul Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'With FluentSoul',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Fluent & Natural',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.textMain : AppTheme.textMainLight,
                              ),
                            ),
                            const Text(
                              '95% Fluency Goal',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

/// Custom Painter drawing the Fluency Progression trajectory with stage nodes (Start -> Practice -> Confidence -> Mastery)
class _GrowthProgressionPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color primaryColor;

  _GrowthProgressionPainter({
    required this.progress,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height - 24; // Leave room for stage labels

    // Stage Milestone Data Points (No Days!)
    final List<Map<String, dynamic>> stages = [
      {'label': 'Start', 'x': width * 0.08, 'y': height * 0.85, 'score': '45%'},
      {'label': 'Practice', 'x': width * 0.35, 'y': height * 0.65, 'score': '65%'},
      {'label': 'Confidence', 'x': width * 0.65, 'y': height * 0.40, 'score': '82%'},
      {'label': 'Mastery', 'x': width * 0.92, 'y': height * 0.15, 'score': '95%'},
    ];

    // Grid Horizontal Reference Lines
    final Paint gridPaint = Paint()
      ..color = (isDark ? Colors.white10 : Colors.black12)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final double y = height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Build Curve Path connecting stage nodes
    final Path curvePath = Path()..moveTo(stages[0]['x'] as double, stages[0]['y'] as double);
    for (int i = 0; i < stages.length - 1; i++) {
      final double x1 = stages[i]['x'] as double;
      final double y1 = stages[i]['y'] as double;
      final double x2 = stages[i + 1]['x'] as double;
      final double y2 = stages[i + 1]['y'] as double;
      final double controlX = (x1 + x2) / 2;
      curvePath.cubicTo(controlX, y1, controlX, y2, x2, y2);
    }

    // Gradient Area Fill Below Curve
    final Path fillPath = Path.from(curvePath)
      ..lineTo(stages.last['x'] as double, height)
      ..lineTo(stages.first['x'] as double, height)
      ..close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withOpacity(0.35),
          primaryColor.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(fillPath, fillPaint);

    // Main Trajectory Line
    final Paint linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(curvePath, linePaint);

    // Draw Stage Nodes & Labels
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < stages.length; i++) {
      final double mx = stages[i]['x'] as double;
      final double my = stages[i]['y'] as double;
      final String label = stages[i]['label'] as String;
      final String score = stages[i]['score'] as String;

      // Pulse highlight effect on active stage node
      final bool isActive = i == (progress * (stages.length - 1)).round();
      if (isActive) {
        final Paint pulsePaint = Paint()
          ..color = primaryColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(mx, my), 12, pulsePaint);
      }

      // Outer & Inner Node Circles
      final Paint outerCircle = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      final Paint innerCircle = Paint()
        ..color = isActive ? primaryColor : (isDark ? const Color(0xFF1E293B) : Colors.white);

      canvas.drawCircle(Offset(mx, my), 6, innerCircle);
      canvas.drawCircle(Offset(mx, my), 6, outerCircle);

      // Score text above node
      textPainter.text = TextSpan(
        text: score,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: isActive ? primaryColor : (isDark ? AppTheme.textMuted : AppTheme.textMutedLight),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(mx - textPainter.width / 2, my - 18));

      // Stage Label below canvas height
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(mx - textPainter.width / 2, height + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthProgressionPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
