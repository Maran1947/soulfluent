import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/screens/day_detail_screen.dart';
import 'package:fluentsoul_mobile/widgets/app_header.dart';
import 'package:fluentsoul_mobile/widgets/logo_widgets.dart';

class PathScreen extends StatefulWidget {
  const PathScreen({super.key});

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late List<CurriculumWeek> _weeks;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _weeks = WEEKS_DATA.map((w) => CurriculumWeek.fromJson(w)).toList();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getWeekSubtitle(String range) {
    if (range.contains('1-7') || range.contains('1–7')) {
      return 'Start your journey. Build momentum.';
    }
    if (range.contains('8-14') || range.contains('8–14')) {
      return 'Organize thoughts with conviction.';
    }
    if (range.contains('15-21') || range.contains('15–21')) {
      return 'Debate with grace and clarity.';
    }
    return 'Command presence in any room.';
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
        builder: (_) => DayDetailScreen(day: day),
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
            child: Column(
              children: [
                // ---------- TOP BAR ----------
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: cardBg.withOpacity(0.92),
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Fluency Track',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: headingColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Text('🔥',
                                    style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  '${gd.streakDays} day streak',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Progress Strip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Day $currentDay of 30',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: subtitleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            activeTrack == 'A'
                                ? 'Track A · Unfreeze'
                                : 'Track B · Scratch',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: subtitleColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: (currentDay / 30).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------- PATH scrollview ----------
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        ..._weeks.map((week) {
                          return Column(
                            children: [
                              // Week Banner Card matching reference screenshot 1
                              Container(
                                margin: const EdgeInsets.only(
                                    bottom: 28, top: 14, left: 16, right: 16),
                                padding:
                                    const EdgeInsets.fromLTRB(20, 18, 18, 18),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFFA5A3A)
                                        .withOpacity(0.45),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFA5A3A)
                                          .withOpacity(0.12),
                                      blurRadius: 18,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            week.range.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: const Color(0xFFFA5A3A),
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            week.title,
                                            style: GoogleFonts.outfit(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: headingColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getWeekSubtitle(week.range),
                                            style: GoogleFonts.inter(
                                              fontSize: 12.5,
                                              color: subtitleColor,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Glowing 3D Flame Icon on Base Platform
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFFFEBE5),
                                        border: Border.all(
                                          color: const Color(0xFFFA5A3A)
                                              .withOpacity(0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFA5A3A)
                                                .withOpacity(0.3),
                                            blurRadius: 14,
                                            spreadRadius: 2,
                                          )
                                        ],
                                      ),
                                      child: const Center(
                                        child: Text('🔥',
                                            style: TextStyle(fontSize: 26)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Week Days Nodes with S-Curve Layout & Connecting Dashed Line
                              _WeekNodesWidget(
                                week: week,
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
                            ],
                          );
                        }),

                        const SizedBox(height: 32),

                        // ---------- MORE DAYS COMING SOON BANNER & MOTIVATIONAL MESSAGE ----------
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppTheme.primary.withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Cute Glowing Rocket Squircle Badge
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFA5A3A),
                                          Color(0xFFF25C40)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF25C40)
                                              .withOpacity(0.4),
                                          blurRadius: 10,
                                        )
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text('🚀',
                                          style: TextStyle(fontSize: 22)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '✨ MORE TRACKS COMING SOON',
                                            style: GoogleFonts.inter(
                                              color: AppTheme.primary,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Your voice is your superpower 🌟',
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: headingColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppTheme.primary.withOpacity(0.2)),
                                ),
                                child: Text(
                                  'Keep practicing daily — new fluency paths and challenges are unlocking soon!',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: subtitleColor,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed Curve Line Painter for path nodes
class _WindingPathDashedPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  _WindingPathDashedPainter({
    required this.points,
    this.color = const Color(0xFF475569),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlY = (p1.dy + p2.dy) / 2;
      path.cubicTo(p1.dx, controlY, p2.dx, controlY, p2.dx, p2.dy);
    }

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      const dashWidth = 5.0;
      const dashSpace = 6.0;

      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + len);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WindingPathDashedPainter oldDelegate) => true;
}

/// Week Nodes Widget with connecting dashed curves
class _WeekNodesWidget extends StatelessWidget {
  final CurriculumWeek week;
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

  const _WeekNodesWidget({
    required this.week,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const nodeRowHeight = 118.0;
    final totalHeight = week.days.length * nodeRowHeight;
    const xFractions = [0.22, 0.52, 0.78, 0.48, 0.22, 0.52, 0.78];

    // Calculate (X, Y) center coordinates for each node
    final List<Offset> points = [];
    for (int i = 0; i < week.days.length; i++) {
      final xFrac = xFractions[i % xFractions.length];
      final x = screenWidth * xFrac;
      final y = (i + 0.5) * nodeRowHeight - 18;
      points.add(Offset(x, y));
    }

    return Container(
      height: totalHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // 1. Dashed Curve Line Painter behind nodes
          Positioned.fill(
            child: CustomPaint(
              painter: _WindingPathDashedPainter(
                points: points,
                color:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
          ),

          // 2. Day Nodes
          ...week.days.asMap().entries.map((entry) {
            final i = entry.key;
            final day = entry.value;
            final state = dayState(day, currentDay, reviewMode, completedDays);
            final isMilestone = day.mode == 'milestone';

            final xFrac = xFractions[i % xFractions.length];
            final nodeSize = isMilestone ? 68.0 : 60.0;
            final isCurrent = state == 'current';
            final isDone = state == 'done';
            final isLocked = state == 'locked';

            return Positioned(
              top: i * nodeRowHeight,
              left: (screenWidth * xFrac) - (nodeSize / 2),
              child: GestureDetector(
                onTap: () {
                  if (isLocked) {
                    onShowToast(
                        'Complete Day ${day.d - 1} to unlock Day ${day.d}',
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
                                              : const Color(0xFFCBD5E1))),
                                  width: isCurrent ? 3 : 2,
                                ),
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFFA5A3A)
                                              .withOpacity(0.4),
                                          blurRadius: 18 + pulseAnimation.value,
                                          spreadRadius:
                                              2 + (pulseAnimation.value / 3),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        )
                                      ],
                              ),
                              child: Center(
                                child: isLocked
                                    ? const Icon(Icons.lock_outline_rounded,
                                        color: Color(0xFF64748B), size: 22)
                                    : (isMilestone
                                        ? const Text('🏆',
                                            style: TextStyle(fontSize: 24))
                                        : (isDone
                                            ? const Icon(Icons.check_rounded,
                                                color: Colors.white, size: 28)
                                            : Text(
                                                '${day.d}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ))),
                              ),
                            );
                          },
                        ),

                        // Green Top Right Checkmark Badge ONLY when Day is ACTUALLY COMPLETED
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
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
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
                    const SizedBox(height: 5),
                    Text(
                      'Day ${day.d}',
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
            );
          }),
        ],
      ),
    );
  }
}
