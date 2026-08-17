import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/auth_provider.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/screens/daily_speak_recording_screen.dart';
import 'package:fluentsoul_mobile/services/api_service.dart';

class DailySpeakScreen extends StatefulWidget {
  const DailySpeakScreen({super.key});

  @override
  State<DailySpeakScreen> createState() => _DailySpeakScreenState();
}

class _DailySpeakScreenState extends State<DailySpeakScreen> {
  bool _isLoading = true;
  String _topic = "Would you rather work from home or from an office?";
  String _subtitle = "Share your thoughts and reasons.";
  int _durationSeconds = 60;
  int _streakDays = 0;
  int _completedDaysCount = 0;
  int _totalDaysCount = 7;
  List<String> _talkingPoints = [];
  List<String> _starterPhrases = [];

  List<Map<String, dynamic>> _weeklyProgress = [
    {'day': 'M', 'completed': false},
    {'day': 'T', 'completed': false},
    {'day': 'W', 'completed': false},
    {'day': 'T', 'completed': false},
    {'day': 'F', 'completed': false},
    {'day': 'S', 'completed': false},
    {'day': 'S', 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDailySpeakData();
  }

  Future<void> _fetchDailySpeakData() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService();
      if (auth.token != null) {
        api.setAuthToken(auth.token);
      }
      final data = await api.getDailySpeakToday();
      if (mounted) {
        setState(() {
          _topic = data['topic'] ?? _topic;
          _subtitle = data['subtitle'] ?? _subtitle;
          _durationSeconds = data['duration_seconds'] ?? _durationSeconds;
          _streakDays = data['streak_days'] ?? _streakDays;
          _completedDaysCount =
              data['completed_days_count'] ?? _completedDaysCount;
          _totalDaysCount = data['total_days_count'] ?? _totalDaysCount;
          if (data['weekly_progress'] != null) {
            _weeklyProgress =
                List<Map<String, dynamic>>.from(data['weekly_progress']);
          }
          if (data['talking_points'] != null) {
            _talkingPoints = List<String>.from(data['talking_points']);
          }
          if (data['starter_phrases'] != null) {
            _starterPhrases = List<String>.from(data['starter_phrases']);
          }
          _isLoading = false;
        });
      }

    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isStartingSession = false;

  Future<void> _startDailySpeaking() async {
    if (_isStartingSession) return;
    setState(() => _isStartingSession = true);

    final gd = context.read<GDProvider>();
    final success = await gd.startSession(
      topic: _topic,
      category: 'Daily Speak',
      difficulty: 'intermediate',
      personaKeys: ['riya'],
    );

    if (mounted) {
      setState(() => _isStartingSession = false);
    }

    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailySpeakRecordingScreen(
            topic: _topic,
            subtitle: _subtitle,
            streakDays: _streakDays,
            talkingPoints: _talkingPoints,
            starterPhrases: _starterPhrases,
          ),
        ),
      );
    } else if (mounted) {
      final errorMsg = gd.errorMessage ??
          'Unable to start session. Please check your network connection.';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMsg,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showProgressDetailsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.cardDark : Colors.white;
    final headingColor = isDark ? AppTheme.textMain : const Color(0xFF0F172A);
    final subtitleColor = isDark ? AppTheme.textMuted : const Color(0xFF64748B);
    final primaryColor = AppTheme.primary;
    final borderColor = isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.background : const Color(0xFFF8FAFC),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subtitleColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Analytics & History',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your daily speaking consistency breakdown',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: subtitleColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3 Metric Cards Row
              Row(
                children: [
                  _buildMetricCard(
                    icon: '🔥',
                    title: 'Current Streak',
                    value: '$_streakDays Days',
                    color: const Color(0xFFEA580C),
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                  const SizedBox(width: 10),
                  _buildMetricCard(
                    icon: '🎯',
                    title: 'This Week',
                    value: '$_completedDaysCount/$_totalDaysCount Days',
                    color: primaryColor,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                  const SizedBox(width: 10),
                  _buildMetricCard(
                    icon: '⏱️',
                    title: 'Speaking Time',
                    value: '${_completedDaysCount * 1} Mins',
                    color: Colors.green,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Detailed Weekly Breakdown Header
              Text(
                'THIS WEEK\'S SCHEDULE',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              // 7-Day Matrix List
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _weeklyProgress.map((item) {
                    final day = item['day'] ?? 'M';
                    final completed = item['completed'] == true;
                    return Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: completed
                                ? primaryColor
                                : primaryColor.withOpacity(0.08),
                            border: Border.all(
                              color: completed
                                  ? primaryColor
                                  : borderColor,
                            ),
                          ),
                          child: Center(
                            child: completed
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 20)
                                : Text(
                                    day,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: subtitleColor,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          day,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: completed ? primaryColor : subtitleColor,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Topics Log
              Text(
                'RECENT TOPICS PRACTICED',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: subtitleColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🎙️', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _topic,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: headingColor,
                            ),
                          ),
                          Text(
                            _completedDaysCount > 0
                                ? 'Completed Today • 60s Session'
                                : 'Scheduled For Today • 60s Session',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _completedDaysCount > 0
                                  ? Colors.green
                                  : subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_completedDaysCount > 0)
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.green, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.background : const Color(0xFFF8FAFC);
    final cardBg = isDark ? AppTheme.cardDark : Colors.white;
    final headingColor = isDark ? AppTheme.textMain : const Color(0xFF0F172A);
    final subtitleColor = isDark ? AppTheme.textMuted : const Color(0xFF64748B);
    final borderColor = isDark ? AppTheme.borderDark : const Color(0xFFF1F5F9);
    final primaryColor = AppTheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDailySpeakData,
          color: primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isLoading)
                  LinearProgressIndicator(
                    color: primaryColor,
                    backgroundColor: Colors.transparent,
                    minHeight: 2,
                  ),
                if (_isLoading) const SizedBox(height: 8),

                // Top Header Row (Logo, Title, Subtitle, Streak Badge)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                      Icons.local_fire_department_rounded,
                                      color: primaryColor,
                                      size: 26),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Speak Daily',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: headingColor,
                                  ),
                                ),
                                Text(
                                  'Become confident.',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Streak Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF451A03).withOpacity(0.4)
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF9A3412).withOpacity(0.4)
                              : const Color(0xFFFFEDD5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '$_streakDays Day Streak',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Main Today's Topic Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      // "TODAY'S TOPIC" tag
                      Text(
                        "TODAY'S TOPIC",
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1.1,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Topic Question (Increased Font Size)
                      Text(
                        _topic,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: headingColor,
                          height: 1.25,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle instructions
                      Text(
                        _subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: subtitleColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Circular Hero Graphic Container (Increased Size)
                      Container(
                        width: 270,
                        height: 270,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.08),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/daily_speak_hero.png',
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.mic_rounded,
                              size: 100,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Info metadata line (FittedBox to prevent overflow)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 15, color: subtitleColor),
                            const SizedBox(width: 5),
                            Text(
                              'Speak for $_durationSeconds seconds',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '|',
                                style: TextStyle(
                                    color: subtitleColor.withOpacity(0.4)),
                              ),
                            ),
                            const Text('✨', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              'AI will give you feedback',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // CTA Start Speaking Button (Sleek Purple Button with Vector Mic Badge)

                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primaryDark,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed:
                              _isStartingSession ? null : _startDailySpeaking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: _isStartingSession
                              ? const SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.mic_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Start Speaking',
                                      style: GoogleFonts.outfit(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Weekly Progress Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Progress This Week',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: headingColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: _showProgressDetailsSheet,
                            child: Text(
                              'View All',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Days Circles Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _weeklyProgress.map((item) {
                          final dayStr = item['day']?.toString() ?? '';
                          final isDone = item['completed'] == true;

                          return Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? primaryColor
                                  : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9)),
                            ),
                            child: Center(
                              child: Text(
                                dayStr,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? Colors.white
                                      : (isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      // Days completed text label
                      Text(
                        '$_completedDaysCount / $_totalDaysCount days completed',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Linear Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _totalDaysCount > 0
                              ? (_completedDaysCount / _totalDaysCount)
                              : 0,
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
