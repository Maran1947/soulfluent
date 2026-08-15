import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/l10n/app_localizations.dart';
import 'package:fluentsoul_mobile/models/session.dart';
import 'package:fluentsoul_mobile/providers/auth_provider.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/providers/locale_provider.dart';
import 'package:fluentsoul_mobile/services/api_service.dart';
import 'package:fluentsoul_mobile/utils/error_utils.dart';
import 'package:fluentsoul_mobile/widgets/app_header.dart';
import 'package:fluentsoul_mobile/widgets/logo_widgets.dart';
import 'package:fluentsoul_mobile/widgets/skeleton_loader.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GDSession> _sessions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final apiService = ApiService()..setAuthToken(auth.token);
      final list = await apiService.listSessions();
      setState(() {
        _sessions = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = formatUserFriendlyError(e);
        _isLoading = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      return '$day/$month/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.borderDark : const Color(0xFFF1F5F9);
    final headingColor = isDark ? AppTheme.textMain : AppTheme.textMainLight;
    final subtitleColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    return Scaffold(
      appBar: AppHeader(
        title: 'Session History',
        showBack: true,
        onBack: () => Navigator.pushReplacementNamed(context, '/home'),
      ),
      body: Stack(
        children: [
          // Ambient Waves Background
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundWavesPainter(
                color: AppTheme.primary,
                isDark: isDark,
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchHistory,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section matching screenshot reference
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Session History',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review past conversations, transcripts, and AI fluency reports.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: subtitleColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Skeleton Loading State
                    if (_isLoading)
                      Column(
                        children: List.generate(
                            4, (_) => const HistorySkeletonCard()),
                      )

                    // Error State
                    else if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 40, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: GoogleFonts.plusJakartaSans(
                                  color: headingColor, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _fetchHistory,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )

                    // Empty State
                    else if (_sessions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.forum_outlined,
                                size: 36,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No practice sessions yet',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: headingColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start your first AI Group Discussion or Debate to track your spoken English fluency and reports.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                  context, '/home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Start First Session →'),
                            ),
                          ],
                        ),
                      )

                    // Sessions List Cards
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          final s = _sessions[index];
                          final isCompleted =
                              s.status.toLowerCase() == 'completed';

                          final statusBg = isCompleted
                              ? (isDark
                                  ? const Color(0xFF064E3B).withOpacity(0.5)
                                  : const Color(0xFFE6F4EA))
                              : (isDark
                                  ? AppTheme.primary.withOpacity(0.2)
                                  : const Color(0xFFFFEBE5));

                          final statusTextColor = isCompleted
                              ? (isDark
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFF137333))
                              : AppTheme.primary;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isDark ? 0.25 : 0.05),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(22),
                                onTap: () {
                                  final gd = context.read<GDProvider>();
                                  if (s.status == 'active') {
                                    gd.loadPastSession(s.id).then((_) {
                                      if (mounted)
                                        Navigator.pushNamed(context, '/arena');
                                    });
                                  } else {
                                    gd.loadPastSession(s.id);
                                    Navigator.pushNamed(context, '/report');
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Top Badges Row: CATEGORY & STATUS
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            s.category
                                                .replaceAll('_', ' ')
                                                .toUpperCase(),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.8,
                                              color: subtitleColor,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              s.status
                                                      .substring(0, 1)
                                                      .toUpperCase() +
                                                  s.status
                                                      .substring(1)
                                                      .toLowerCase(),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: statusTextColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Topic Title matching reference design
                                      Text(
                                        s.topic,
                                        style: GoogleFonts.outfit(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: headingColor,
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 16),
                                      Divider(color: borderColor, height: 1),
                                      const SizedBox(height: 12),

                                      // Footer info: Difficulty · Duration | Date
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                s.difficulty
                                                        .substring(0, 1)
                                                        .toUpperCase() +
                                                    s.difficulty
                                                        .substring(1)
                                                        .toLowerCase(),
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: headingColor,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6),
                                                child: Text('·',
                                                    style: TextStyle(
                                                        color: subtitleColor)),
                                              ),
                                              Icon(
                                                Icons.schedule_rounded,
                                                size: 14,
                                                color: subtitleColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${s.durationMinutes}m',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: headingColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            _formatDate(s.startedAt),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: subtitleColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
