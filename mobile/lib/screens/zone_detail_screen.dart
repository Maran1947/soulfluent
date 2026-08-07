import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:soulfluent_mobile/data/challenges_data.dart';
import 'package:soulfluent_mobile/models/challenge.dart';
import 'package:soulfluent_mobile/providers/challenges_provider.dart';
import 'package:soulfluent_mobile/screens/challenge_play_screen.dart';

class ZoneDetailScreen extends StatelessWidget {
  final Zone zone;

  const ZoneDetailScreen({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChallengesProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF131829) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1B2138) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3150) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? const Color(0xFFEDEFF7) : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF8A8FA3) : const Color(0xFF64748B);

    final zoneChallenges = getChallengesByZone(zone.id);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: headingColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zone.name,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: headingColor,
              ),
            ),
            Text(
              zone.tagline,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: subtitleColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: zoneChallenges.length,
          itemBuilder: (context, index) {
            final c = zoneChallenges[index];
            final isLocked = zone.id == 'boss' &&
                c.unlock == 'weekly' &&
                !provider.unlockedWeeklyBossIds.contains(c.id);

            return Opacity(
              opacity: isLocked ? 0.5 : 1.0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildDifficultyBadge(c.difficulty, isDark),
                        const SizedBox(width: 8),
                        Text(
                          c.timerSeconds != null ? '${c.timerSeconds}s' : 'No timer',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+${c.xp} XP',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFFFF8B5E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          isLocked ? Icons.lock_outline_rounded : Icons.crop_square_rounded,
                          size: 20,
                          color: headingColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: headingColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.description,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: subtitleColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLocked
                              ? borderColor
                              : const Color(0xFFFF8B5E),
                          foregroundColor: isLocked
                              ? subtitleColor
                              : const Color(0xFF3A1D0E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLocked
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChallengePlayScreen(challenge: c),
                                  ),
                                );
                              },
                        child: Text(
                          isLocked ? 'Unlocks Weekly' : 'Start Challenge',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty, bool isDark) {
    Color bg;
    Color fg;
    switch (difficulty.toLowerCase()) {
      case 'gold':
        bg = const Color(0xFF4A3B12);
        fg = const Color(0xFFE3B23C);
        break;
      case 'silver':
        bg = const Color(0xFF2A3150);
        fg = const Color(0xFFEDEFF7);
        break;
      case 'bronze':
      default:
        bg = const Color(0xFF3A241A);
        fg = const Color(0xFFFF8B5E);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
