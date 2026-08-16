import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/screens/activity_runner_screen.dart';
import 'package:fluentsoul_mobile/widgets/app_header.dart';
import 'package:fluentsoul_mobile/widgets/logo_widgets.dart';
import 'package:fluentsoul_mobile/widgets/path_skeleton_loader.dart';

class PathScreen extends StatefulWidget {
  const PathScreen({super.key});

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _dayState(CurriculumDay day, int currentDay, bool reviewMode,
      List<int> completedDays) {
    if (completedDays.contains(day.d)) return 'done';
    if (reviewMode) {
      return day.d == currentDay ? 'current' : 'unlocked';
    }
    final bool isUnlocked = (day.d == 1) || completedDays.contains(day.d - 1);
    if (!isUnlocked) return 'locked';
    if (day.d == currentDay) return 'current';
    return 'unlocked';
  }

  void _showToast(String msg, bool isDark) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔒 $msg',
            style: GoogleFonts.inter(
                color: isDark ? AppTheme.textMain : AppTheme.textMainLight)),
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  void _openSheet(CurriculumDay day, String currentTrack, bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityRunnerScreen(node: day),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gd = context.watch<GDProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final headingColor = isDark ? AppTheme.textMain : AppTheme.textMainLight;
    final subtitleColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    final currentDay = gd.currentPathDay;
    final activeTrack = gd.activeTrack;
    final reviewMode = gd.reviewMode;
    final completedDays = gd.completedPathDays;
    final stagesToRender = gd.stages;

    // Flatten all days into a single continuous list & map stage headers
    final List<CurriculumDay> allDays = [];
    final Map<int, String> stageHeaders = {};

    int count = 0;
    for (final stage in stagesToRender) {
      for (int i = 0; i < stage.nodes.length; i++) {
        if (i == 0) {
          stageHeaders[count] = stage.title;
        }
        allDays.add(stage.nodes[i]);
        count++;
      }
    }

    return Scaffold(
      appBar: const AppHeader(title: 'FluentSoul'),
      body: Stack(
        children: [
          // Ambient Waves Background in Both Dark and Light Modes
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundWavesPainter(
                color: AppTheme.primary,
                isDark: isDark,
              ),
            ),
          ),

          SafeArea(
            child: gd.isLoadingCurriculum
                ? const PathSkeletonLoader()
                : stagesToRender.isEmpty
                    ? _buildEmptyState(context, isDark, cardBg, borderColor,
                        headingColor, subtitleColor, gd)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            // Continuous Connected Path Widget
                            _ContinuousPathWidget(
                              days: allDays,
                              stageHeaders: stageHeaders,
                              currentDay: currentDay,
                              reviewMode: reviewMode,
                              completedDays: completedDays,
                              activeTrack: activeTrack,
                              isDark: isDark,
                              headingColor: headingColor,
                              subtitleColor: subtitleColor,
                              pulseAnimation: _pulseAnimation,
                              onOpenSheet: _openSheet,
                              onShowToast: _showToast,
                              dayState: _dayState,
                            ),

                            const SizedBox(height: 20),

                            // Bottom Simple Card
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B).withOpacity(0.5)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: borderColor.withOpacity(0.6)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            AppTheme.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text('🌟',
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'New stages added regularly',
                                            style: GoogleFonts.inter(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w500,
                                              color: subtitleColor,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Keep practicing daily to build lasting fluency',
                                            style: GoogleFonts.outfit(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w600,
                                              color: headingColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color headingColor,
    Color subtitleColor,
    GDProvider gd,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cardBg.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.25), width: 1.5),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 36,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Path Data Found',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'We couldn\'t retrieve your learning path at this moment. Tap below to try again.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: subtitleColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => gd.fetchCurriculum(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Refresh Path',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Winding Curved Line Painter
class _WindingPathDashedPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  _WindingPathDashedPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midY = (p0.dy + p1.dy) / 2;

      final controlPoint1 = Offset(p0.dx, midY);
      final controlPoint2 = Offset(p1.dx, midY);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    final dashWidth = 8.0;
    final dashSpace = 6.0;

    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final len = (distance + dashWidth < pathMetric.length)
            ? dashWidth
            : pathMetric.length - distance;
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + len),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WindingPathDashedPainter oldDelegate) => true;
}

/// Continuous Connected Path Widget with S-Curve Layout & Stage Header Badges
class _ContinuousPathWidget extends StatelessWidget {
  final List<CurriculumDay> days;
  final Map<int, String> stageHeaders;
  final int currentDay;
  final bool reviewMode;
  final List<int> completedDays;
  final String activeTrack;
  final bool isDark;
  final Color headingColor;
  final Color subtitleColor;
  final Animation<double> pulseAnimation;
  final Function(CurriculumDay, String, bool) onOpenSheet;
  final Function(String, bool) onShowToast;
  final String Function(CurriculumDay, int, bool, List<int>) dayState;

  const _ContinuousPathWidget({
    required this.days,
    required this.stageHeaders,
    required this.currentDay,
    required this.reviewMode,
    required this.completedDays,
    required this.activeTrack,
    required this.isDark,
    required this.headingColor,
    required this.subtitleColor,
    required this.pulseAnimation,
    required this.onOpenSheet,
    required this.onShowToast,
    required this.dayState,
  });

  String _formatStageTitle(String title) {
    if (title.toUpperCase().startsWith('STAGE ')) {
      final parts = title.split(':');
      if (parts.length == 2) {
        final stageNum = parts[0].trim().replaceAll('STAGE ', 'Stage ');
        final stageName = parts[1].trim();
        final words = stageName.split(' ').map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        }).join(' ');
        return '$stageNum · $words';
      }
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const nodeRowHeight = 125.0;
    final totalHeight = days.length * nodeRowHeight;
    const xFractions = [0.22, 0.52, 0.78, 0.52];

    final List<Offset> points = [];
    for (int i = 0; i < days.length; i++) {
      final xFrac = xFractions[i % xFractions.length];
      final x = screenWidth * xFrac;
      final y = (i + 0.5) * nodeRowHeight;
      points.add(Offset(x, y));
    }

    return Container(
      height: totalHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _WindingPathDashedPainter(
                points: points,
                color:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
          ),
          ...days.asMap().entries.map((entry) {
            final i = entry.key;
            final day = entry.value;
            final state = dayState(day, currentDay, reviewMode, completedDays);
            final isMilestone = day.mode == 'milestone';

            final xFrac = xFractions[i % xFractions.length];
            final nodeSize = isMilestone ? 66.0 : 58.0;
            final isCurrent = state == 'current';
            final isDone = state == 'done';
            final isLocked = state == 'locked';

            final stageTitle = stageHeaders[i];

            return Positioned(
              top: i * nodeRowHeight,
              left: 0,
              right: 0,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  // Stage Header Badge above starting node of a Stage
                  if (stageTitle != null)
                    Positioned(
                      top: -16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B).withOpacity(0.92)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFFFA5A3A).withOpacity(0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFA5A3A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatStageTitle(stageTitle),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Node Circle Container
                  Padding(
                    padding:
                        EdgeInsets.only(top: stageTitle != null ? 30.0 : 0.0),
                    child: Align(
                      alignment: Alignment((xFrac * 2) - 1.0, 0),
                      child: GestureDetector(
                        onTap: () {
                          if (isLocked) {
                            onShowToast(
                                'Complete Unit ${day.d - 1} to unlock Unit ${day.d}',
                                isDark);
                            return;
                          }
                          onOpenSheet(day, activeTrack, isDark);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedBuilder(
                                  animation: pulseAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      width: nodeSize,
                                      height: nodeSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isCurrent
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFFFA5A3A),
                                                  Color(0xFFF25C40)
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        color: isDone
                                            ? const Color(0xFF10B981)
                                            : (isCurrent
                                                ? null
                                                : (isDark
                                                    ? const Color(0xFF161E2E)
                                                    : const Color(0xFFE2E8F0))),
                                        border: Border.all(
                                          color: isCurrent
                                              ? const Color(0xFFFF8A75)
                                              : (isDone
                                                  ? const Color(0xFF34D399)
                                                  : (isDark
                                                      ? const Color(0xFF334155)
                                                      : const Color(
                                                          0xFFCBD5E1))),
                                          width: isCurrent ? 3 : 2,
                                        ),
                                        boxShadow: isCurrent
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFFFA5A3A)
                                                      .withOpacity(0.4),
                                                  blurRadius:
                                                      18 + pulseAnimation.value,
                                                  spreadRadius: 2 +
                                                      (pulseAnimation.value /
                                                          3),
                                                ),
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.12),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                )
                                              ],
                                      ),
                                      child: Center(
                                        child: isLocked
                                            ? const Icon(
                                                Icons.lock_outline_rounded,
                                                color: Color(0xFF64748B),
                                                size: 22)
                                            : (isMilestone
                                                ? const Text('🏆',
                                                    style:
                                                        TextStyle(fontSize: 24))
                                                : Text(
                                                    '${day.d}',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                      ),
                                    );
                                  },
                                ),

                                // Green Checkmark Badge
                                if (isDone)
                                  Positioned(
                                    top: -1,
                                    right: -1,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF10B981),
                                        border: Border.all(
                                            color: Colors.white, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            blurRadius: 4,
                                          )
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.check_rounded,
                                            color: Colors.white, size: 12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Unit ${day.d}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? const Color(0xFFFA5A3A)
                                    : (isDone
                                        ? const Color(0xFF10B981)
                                        : subtitleColor),
                              ),
                            ),
                            Text(
                              isCurrent
                                  ? "Let's begin!"
                                  : (isDone ? "Completed" : "Locked"),
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isCurrent
                                    ? const Color(0xFFFA5A3A).withOpacity(0.85)
                                    : subtitleColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
