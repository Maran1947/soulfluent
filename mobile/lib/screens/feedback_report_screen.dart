import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/l10n/app_localizations.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/providers/locale_provider.dart';
import 'package:fluentsoul_mobile/widgets/app_header.dart';
import 'package:fluentsoul_mobile/widgets/logo_widgets.dart';
import 'package:fluentsoul_mobile/widgets/skeleton_loader.dart';

class FeedbackReportScreen extends StatefulWidget {
  const FeedbackReportScreen({super.key});

  @override
  State<FeedbackReportScreen> createState() => _FeedbackReportScreenState();
}

class _FeedbackReportScreenState extends State<FeedbackReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gd = context.read<GDProvider>();
      if (gd.currentReport == null &&
          gd.currentSession != null &&
          !gd.isLoading) {
        gd.loadPastSession(gd.currentSession!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gd = context.watch<GDProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final report = gd.currentReport;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0);
    final headingColor = isDark ? AppTheme.textMain : AppTheme.textMainLight;
    final subtitleColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    if (gd.isLoading) {
      return Scaffold(
        appBar: AppHeader(
          title: 'Feedback Report',
          showBack: true,
          onBack: () => Navigator.pushReplacementNamed(context, '/history'),
        ),
        body: const SafeArea(
          child: AnimatedReportAnalysisLoader(),
        ),
      );
    }

    if (gd.errorMessage != null && report == null) {
      return Scaffold(
        appBar: AppHeader(
          title: 'Feedback Report',
          showBack: true,
          onBack: () => Navigator.pushReplacementNamed(context, '/history'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  gd.errorMessage!,
                  style: GoogleFonts.plusJakartaSans(
                      color: headingColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    if (gd.currentSession != null) {
                      gd.loadPastSession(gd.currentSession!.id);
                    } else {
                      Navigator.pushReplacementNamed(context, '/history');
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (report == null) {
      return Scaffold(
        appBar: AppHeader(
          title: 'Feedback Report',
          showBack: true,
          onBack: () => Navigator.pushReplacementNamed(context, '/history'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No report available for this session.',
                style: GoogleFonts.plusJakartaSans(color: subtitleColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/history'),
                child: const Text('Back to History'),
              ),
            ],
          ),
        ),
      );
    }

    final fm = report.fluencyMetrics;
    final vm = report.vocabularyMetrics;
    final am = report.argumentMetrics;
    final subScores = report.subScores;

    final scoreTier = report.overallScore >= 80
        ? {
            'title': 'Outstanding Fluency',
            'color': const Color(0xFF10B981),
            'bg': const Color(0xFFECFDF5)
          }
        : report.overallScore >= 60
            ? {
                'title': 'Solid Speaking Performance',
                'color': AppTheme.primary,
                'bg': const Color(0xFFFFF0ED)
              }
            : {
                'title': 'Building Confidence',
                'color': const Color(0xFFF59E0B),
                'bg': const Color(0xFFFEF3C7)
              };

    final session = gd.currentSession;

    return Scaffold(
      appBar: AppHeader(
        title: 'Performance Report',
        showBack: true,
        onBack: () => Navigator.pushReplacementNamed(context, '/history'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundWavesPainter(
                color: AppTheme.primary,
                isDark: isDark,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Session Topic Title & Metadata Banner Card
                  if (session != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  session.category
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            session.topic,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: headingColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.speed_rounded,
                                  size: 14, color: subtitleColor),
                              const SizedBox(width: 4),
                              Text(
                                session.difficulty
                                        .substring(0, 1)
                                        .toUpperCase() +
                                    session.difficulty
                                        .substring(1)
                                        .toLowerCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: subtitleColor,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('·',
                                    style: TextStyle(color: subtitleColor)),
                              ),
                              Icon(Icons.timer_outlined,
                                  size: 14, color: subtitleColor),
                              const SizedBox(width: 4),
                              Text(
                                '${session.durationMinutes}m',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // HERO VISUAL SCORE BOARD CARD matching frontend ScoreGauge
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Gauge Ring Visual
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFFAFAFA),
                            border: Border.all(
                              color: scoreTier['color'] as Color,
                              width: 6,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${report.overallScore}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: headingColor,
                                  ),
                                ),
                                Text(
                                  'OVERALL',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: subtitleColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Score Tier Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: scoreTier['bg'] as Color,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            scoreTier['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: scoreTier['color'] as Color,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Divider(color: borderColor, height: 1),
                        const SizedBox(height: 18),

                        // Sub-Scores Skill Progress Bars
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'CORE COMPETENCY BREAKDOWN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildSubScoreProgress(
                          'Speech Fluency',
                          subScores['fluency'] ?? 40.0,
                          const Color(0xFFF25C40),
                          headingColor,
                          borderColor,
                        ),
                        const SizedBox(height: 10),
                        _buildSubScoreProgress(
                          'Vocabulary Richness',
                          subScores['vocabulary'] ?? 50.0,
                          const Color(0xFF6366F1),
                          headingColor,
                          borderColor,
                        ),
                        const SizedBox(height: 10),
                        _buildSubScoreProgress(
                          'Argument Structure',
                          subScores['argument_quality'] ?? 30.0,
                          const Color(0xFF10B981),
                          headingColor,
                          borderColor,
                        ),
                        const SizedBox(height: 10),
                        _buildSubScoreProgress(
                          'Listening & Rebuttals',
                          subScores['relevance'] ?? 40.0,
                          const Color(0xFF06B6D4),
                          headingColor,
                          borderColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // OBJECTIVE METRICS GRID CARDS
                  Text(
                    'Objective Metrics',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: headingColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Card 1: Speech Pace & Fluency
                  _buildMetricCardContainer(
                    title: 'Speech Pace & Fluency',
                    badge: '${fm.wordsPerMinute.round()} WPM',
                    badgeColor: const Color(0xFFF59E0B),
                    icon: Icons.bolt_rounded,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    headingColor: headingColor,
                    subtitleColor: subtitleColor,
                    rows: [
                      _buildMetricRow(
                          'Words / Minute',
                          '${fm.wordsPerMinute.round()} (Target: 120-150)',
                          headingColor,
                          subtitleColor),
                      _buildMetricRow(
                          'Filler Words',
                          '${fm.fillerWordCount} used',
                          headingColor,
                          subtitleColor),
                      _buildMetricRow(
                          'Sentence Completion',
                          '${(fm.sentenceCompletionRate * 100).round()}%',
                          headingColor,
                          subtitleColor),
                      _buildMetricRow(
                          'Avg Sentence Length',
                          '${fm.averageSentenceLength.round()} words',
                          headingColor,
                          subtitleColor),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Card 2: Vocabulary & Syntax
                  _buildMetricCardContainer(
                    title: 'Vocabulary & Syntax',
                    badge:
                        '${(vm.vocabularyRichnessScore * 100).round()}% Richness',
                    badgeColor: const Color(0xFF6366F1),
                    icon: Icons.menu_book_rounded,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    headingColor: headingColor,
                    subtitleColor: subtitleColor,
                    rows: [
                      _buildMetricRow(
                          'Richness Score',
                          '${(vm.vocabularyRichnessScore * 100).round()}%',
                          headingColor,
                          subtitleColor),
                      _buildMetricRow(
                          'Grammar Issues',
                          '${vm.grammarErrors.length} flagged',
                          headingColor,
                          subtitleColor),
                      _buildMetricRow(
                          'Repeated Phrases',
                          '${vm.repeatedPhrases.length} detected',
                          headingColor,
                          subtitleColor),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Card 3: Argument & Logic
                  _buildMetricCardContainer(
                    title: 'Argument & Logic',
                    badge: '${(am.relevanceScore * 100).round()}% Relevance',
                    badgeColor: const Color(0xFF10B981),
                    icon: Icons.bar_chart_rounded,
                    isDark: isDark,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    headingColor: headingColor,
                    subtitleColor: subtitleColor,
                    rows: [
                      _buildMetricRow(
                          'Points Made',
                          '${am.distinctPointsMade} argument(s)',
                          headingColor,
                          subtitleColor),
                      _buildMetricRow(
                          'Points Defended',
                          '${am.pointsSuccessfullyDefended} defended',
                          headingColor,
                          subtitleColor),
                      _buildMetricRow(
                          'Talk Time Share',
                          '${am.talkTimePercentage.toStringAsFixed(1)}% of session',
                          headingColor,
                          subtitleColor),
                    ],
                  ),

                  // VOCABULARY UPGRADES & SWAPS CARD
                  if (vm.phrasesToAvoid.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 18, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Vocabulary Upgrades & Swaps',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: headingColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...List.generate(vm.phrasesToAvoid.length, (i) {
                            final avoid = vm.phrasesToAvoid[i];
                            final replace = i < vm.replacementSuggestions.length
                                ? vm.replacementSuggestions[i]
                                : 'Stronger expression';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.redAccent.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        avoid,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.arrow_forward_rounded,
                                        size: 14, color: AppTheme.primary),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        replace,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: const Color(0xFF10B981),
                                          fontWeight: FontWeight.bold,
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
                    ),
                  ],

                  // GRAMMAR ERRORS CARD
                  if (vm.grammarErrors.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.g_mobiledata_rounded,
                                  size: 24, color: Colors.amber),
                              const SizedBox(width: 6),
                              Text(
                                'Grammar & Syntax Feedback',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: headingColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...vm.grammarErrors.map((err) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      size: 16, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      err,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: headingColor,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // KEY STRENGTHS & GROWTH AREAS SIDE-BY-SIDE CARDS
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Strengths Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF064E3B).withOpacity(0.2)
                                : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    const Color(0xFF6EE7B7).withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.emoji_events_rounded,
                                      size: 18, color: Color(0xFF10B981)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Highlights',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...report.strengths.map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.check_circle_outline,
                                            size: 14, color: Color(0xFF10B981)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            s,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: headingColor,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Growth Areas Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF78350F).withOpacity(0.2)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    const Color(0xFFF59E0B).withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.track_changes_rounded,
                                      size: 18, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Focus Areas',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...report.growthAreas.map((g) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.error_outline_rounded,
                                            size: 14, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            g,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: headingColor,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // AI RECOMMENDATION BANNER
                  if (report.recommendation.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withOpacity(0.12),
                            const Color(0xFF6366F1).withOpacity(0.12),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 18, color: AppTheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'AI Recommendation for Next Session',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            report.recommendation,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: headingColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Token & Cost Footer
                  Center(
                    child: Text(
                      '${report.totalTokens} tokens processed · \$${report.totalCostUsd.toStringAsFixed(4)} estimated cost',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: subtitleColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubScoreProgress(
    String label,
    double value,
    Color color,
    Color textColor,
    Color borderColor,
  ) {
    final pct = (value / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Text(
              '${value.round()} / 100',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCardContainer({
    required String title,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color headingColor,
    required Color subtitleColor,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: badgeColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: headingColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildMetricRow(
      String label, String value, Color headingColor, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: subtitleColor,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
        ],
      ),
    );
  }
}
