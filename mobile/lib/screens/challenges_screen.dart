import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/screens/word_search_game_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  void _notifyComingSoon(String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚀 $title is coming soon in the next update!',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.background : AppTheme.lightBackground;
    final cardBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final headingColor = isDark ? AppTheme.textMain : AppTheme.textMainLight;
    final subtitleColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Challenges',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sharpen your fluency through minigames',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '120 XP',
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

              const SizedBox(height: 24),

              // Section 1: Playable Now
              Text(
                'Playable Now',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 12),

              // Featured Game Card: Word Search Grid
              _buildPlayableGameCard(
                context: context,
                title: 'Word Search Grid',
                description:
                    'Find hidden fluency words in a letter grid to boost word recall under pressure.',
                category: 'Vocabulary',
                reward: '+50 XP',
                duration: '3 Mins',
                icon: Icons.grid_on_rounded,
                gradientColors: [
                  const Color(0xFFFF6B6B),
                  const Color(0xFFFF8E53)
                ],
                cardBg: cardBg,
                borderColor: borderColor,
                headingColor: headingColor,
                subtitleColor: subtitleColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordSearchGameScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Section 2: Coming Soon Games
              Row(
                children: [
                  Text(
                    'Upcoming Games',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: headingColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: subtitleColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Coming Soon Game 1: Speed Vocab Match
              _buildComingSoonCard(
                title: 'Speed Vocab Match',
                description:
                    'Match synonyms, antonyms, and definitions at breakneck speed.',
                category: 'Vocabulary • Timed',
                icon: Icons.flash_on_rounded,
                iconColor: const Color(0xFFF59E0B),
                cardBg: cardBg,
                borderColor: borderColor,
                headingColor: headingColor,
                subtitleColor: subtitleColor,
                onTap: () => _notifyComingSoon('Speed Vocab Match'),
              ),

              const SizedBox(height: 12),

              // Coming Soon Game 2: Idiom Master Quiz
              _buildComingSoonCard(
                title: 'Idiom Master Quiz',
                description:
                    'Master native English idioms and context clues through scenario puzzles.',
                category: 'Expressions • Trivia',
                icon: Icons.lightbulb_outline_rounded,
                iconColor: const Color(0xFF8B5CF6),
                cardBg: cardBg,
                borderColor: borderColor,
                headingColor: headingColor,
                subtitleColor: subtitleColor,
                onTap: () => _notifyComingSoon('Idiom Master Quiz'),
              ),

              const SizedBox(height: 12),

              // Coming Soon Game 3: Grammar Detective
              _buildComingSoonCard(
                title: 'Grammar Detective',
                description:
                    'Spot and fix subtle grammar errors hidden inside real-world paragraphs.',
                category: 'Grammar • Accuracy',
                icon: Icons.find_in_page_rounded,
                iconColor: const Color(0xFF10B981),
                cardBg: cardBg,
                borderColor: borderColor,
                headingColor: headingColor,
                subtitleColor: subtitleColor,
                onTap: () => _notifyComingSoon('Grammar Detective'),
              ),

              const SizedBox(height: 12),

              // Coming Soon Game 4: Pronunciation Sprint
              _buildComingSoonCard(
                title: 'Pronunciation Sprint',
                description:
                    'Speak target sentences aloud and get instant AI phoneme feedback.',
                category: 'Voice AI • Fluency',
                icon: Icons.mic_rounded,
                iconColor: const Color(0xFF3B82F6),
                cardBg: cardBg,
                borderColor: borderColor,
                headingColor: headingColor,
                subtitleColor: subtitleColor,
                onTap: () => _notifyComingSoon('Pronunciation Sprint'),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayableGameCard({
    required BuildContext context,
    required String title,
    required String description,
    required String category,
    required String reward,
    required String duration,
    required IconData icon,
    required List<Color> gradientColors,
    required Color cardBg,
    required Color borderColor,
    required Color headingColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image / Header Area
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    icon,
                    size: 90,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_circle_fill,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'PLAY NOW',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        reward,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: gradientColors[0],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: headingColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: subtitleColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Tags + Action Row
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTagPill(category, subtitleColor, cardBg),
                        const SizedBox(width: 8),
                        _buildTagPill(duration, subtitleColor, cardBg),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Play Game',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard({
    required String title,
    required String description,
    required String category,
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required Color borderColor,
    required Color headingColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Icon Badge with Lock Overlay
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_rounded,
                        size: 14, color: subtitleColor),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LOCK',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: subtitleColor.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: subtitleColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: iconColor,
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

  Widget _buildTagPill(String text, Color textColor, Color cardBg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
