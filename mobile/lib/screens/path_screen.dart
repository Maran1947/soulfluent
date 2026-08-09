import 'dart:math' as math;
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
                                'Your Path',
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
                              // Week Banner Card
                              Container(
                                margin:
                                    const EdgeInsets.only(bottom: 24, top: 12),
                                width: MediaQuery.of(context).size.width * 0.88,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(isDark ? 0.2 : 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      week.range.toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.08,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      week.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: headingColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Week Days Nodes
                              ...week.days.asMap().entries.map((entry) {
                                final i = entry.key;
                                final day = entry.value;
                                final state = _dayState(
                                    day, currentDay, reviewMode, completedDays);
                                final isMilestone = day.mode == 'milestone';

                                // Calculate X fraction for serpentine S-curve layout
                                final xFrac = 0.5 + math.sin(i * 1.05) * 0.28;
                                final size = isMilestone ? 72.0 : 64.0;

                                return Container(
                                  height: 92,
                                  width: double.infinity,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        left:
                                            (MediaQuery.of(context).size.width *
                                                    xFrac) -
                                                (size / 2),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (state == 'locked') {
                                                  _showToast(
                                                      'Complete Day ${day.d - 1} to unlock Day ${day.d}',
                                                      isDark);
                                                  return;
                                                }
                                                _openSheet(
                                                    day, activeTrack, isDark);
                                              },
                                              child: AnimatedBuilder(
                                                animation: _pulseAnimation,
                                                builder: (context, child) {
                                                  return Container(
                                                    width: size,
                                                    height: size,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: state == 'done'
                                                          ? const Color(
                                                              0xFF10B981)
                                                          : (state == 'current'
                                                              ? AppTheme.primary
                                                              : (isDark
                                                                  ? const Color(
                                                                      0xFF1E293B)
                                                                  : const Color(
                                                                      0xFFE2E8F0))),
                                                      border: Border.all(
                                                        color: isMilestone
                                                            ? AppTheme.primary
                                                            : (state == 'locked'
                                                                ? borderColor
                                                                : Colors
                                                                    .transparent),
                                                        width: isMilestone
                                                            ? 3
                                                            : (state == 'locked'
                                                                ? 2
                                                                : 0),
                                                      ),
                                                      boxShadow: state ==
                                                              'current'
                                                          ? [
                                                              BoxShadow(
                                                                color: AppTheme
                                                                    .primary
                                                                    .withOpacity(
                                                                        0.35),
                                                                blurRadius: 18 +
                                                                    _pulseAnimation
                                                                        .value,
                                                                spreadRadius: 2 +
                                                                    (_pulseAnimation
                                                                            .value /
                                                                        3),
                                                              ),
                                                            ]
                                                          : [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.1),
                                                                blurRadius: 8,
                                                                offset:
                                                                    const Offset(
                                                                        0, 4),
                                                              )
                                                            ],
                                                    ),
                                                    child: Center(
                                                      child: state == 'locked'
                                                          ? Icon(
                                                              Icons
                                                                  .lock_outline,
                                                              color:
                                                                  subtitleColor,
                                                              size: 20)
                                                          : (isMilestone
                                                              ? const Text(
                                                                  '🏆',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          24))
                                                              : (state == 'done'
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 28)
                                                                  : Text(
                                                                      '${day.d}',
                                                                      style: GoogleFonts
                                                                          .outfit(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ))),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Day ${day.d}',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: subtitleColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
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
                                        colors: [Color(0xFFFA5A3A), Color(0xFFF25C40)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF25C40).withOpacity(0.4),
                                          blurRadius: 10,
                                        )
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text('🚀', style: TextStyle(fontSize: 22)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
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
