import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:soulfluent_mobile/data/challenges_data.dart';
import 'package:soulfluent_mobile/models/challenge.dart';
import 'package:soulfluent_mobile/providers/challenges_provider.dart';
import 'package:soulfluent_mobile/screens/challenge_play_screen.dart';
import 'package:soulfluent_mobile/screens/zone_detail_screen.dart';
import 'package:soulfluent_mobile/widgets/inventory_sheet.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  bool _isVoiceMode = true; // true = Voice, false = Quiet mode

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChallengesProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF131829) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1B2138) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3150) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? const Color(0xFFEDEFF7) : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF8A8FA3) : const Color(0xFF64748B);
    const coralPrimary = Color(0xFFFF8B5E);
    const coralTextDark = Color(0xFF3A1D0E);

    final rankProgress = provider.rankProgress;
    final dailyChallenge = getDailyChallenge(DateTime.now());
    final quietChallenges = getQuietModeChallenges();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title + Backpack Inventory Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Challenges',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: headingColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.inventory_2_outlined,
                      color: headingColor,
                      size: 22,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const InventorySheet(),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Segmented Toggle Switch: Voice / Quiet mode
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2138) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isVoiceMode = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isVoiceMode ? coralPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.crop_square_rounded,
                                size: 16,
                                color: _isVoiceMode ? coralTextDark : subtitleColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Voice',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _isVoiceMode ? coralTextDark : subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isVoiceMode = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isVoiceMode ? coralPrimary : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.crop_square_rounded,
                                size: 16,
                                color: !_isVoiceMode ? coralTextDark : subtitleColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Quiet mode',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: !_isVoiceMode ? coralTextDark : subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Rank Card with 6px Progress Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.crop_square_rounded,
                              size: 18,
                              color: coralPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              rankProgress.current.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: headingColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          rankProgress.next != null
                              ? '${rankProgress.xp} / ${rankProgress.next!.minXp} xp'
                              : '${rankProgress.xp} xp',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: subtitleColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: rankProgress.progress,
                        minHeight: 6,
                        backgroundColor: borderColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(coralPrimary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mode Specific Content
              if (_isVoiceMode) ...[
                // VOICE MODE VIEW
                Text(
                  "Today's challenge",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: subtitleColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),

                // Featured Daily Challenge Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      _buildIconChip(
                        bg: const Color(0xFF04342C),
                        iconColor: const Color(0xFF5DCAA5),
                        icon: Icons.crop_square_rounded,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dailyChallenge.title,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: headingColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${dailyChallenge.timerSeconds ?? 60}s · +${dailyChallenge.xp} xp',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: coralPrimary,
                          foregroundColor: coralTextDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChallengePlayScreen(challenge: dailyChallenge),
                            ),
                          );
                        },
                        child: Text(
                          'Start',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Zones',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: subtitleColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),

                // Zone 1: Confidence
                _buildZoneCard(
                  title: ZONES_DATA['confidence']!.name,
                  statusText: '${getChallengesByZone("confidence").length} challenges',
                  iconBg: const Color(0xFF4B1528),
                  iconColor: const Color(0xFFED93B1),
                  borderColor: borderColor,
                  cardBg: cardBg,
                  headingColor: headingColor,
                  subtitleColor: subtitleColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZoneDetailScreen(zone: ZONES_DATA['confidence']!),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Zone 2: Social
                _buildZoneCard(
                  title: ZONES_DATA['social']!.name,
                  statusText: '${getChallengesByZone("social").length} challenges',
                  iconBg: const Color(0xFF26215C),
                  iconColor: const Color(0xFFAFA9EC),
                  borderColor: borderColor,
                  cardBg: cardBg,
                  headingColor: headingColor,
                  subtitleColor: subtitleColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZoneDetailScreen(zone: ZONES_DATA['social']!),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Zone 3: Boss battles (Special Gradient Card)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZoneDetailScreen(zone: ZONES_DATA['boss']!),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3A2115), Color(0xFF1B2138)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF0997B), width: 1),
                    ),
                    child: Row(
                      children: [
                        _buildIconChip(
                          bg: const Color(0xFF4A1B0C),
                          iconColor: const Color(0xFFF0997B),
                          icon: Icons.crop_square_rounded,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ZONES_DATA['boss']!.name,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: headingColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '1 new this week',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFFF0997B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.crop_square_rounded, color: subtitleColor, size: 18),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // QUIET MODE VIEW
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.crop_square_rounded, color: subtitleColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No talking needed here. Great for a commute or a quiet room. XP is capped daily to keep speaking practice as your main path.',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: subtitleColor,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Quiet Challenges List
                ...quietChallenges.map((qc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          _buildIconChip(
                            bg: const Color(0xFF2C2C2A),
                            iconColor: const Color(0xFFB4B2A9),
                            icon: Icons.crop_square_rounded,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  qc.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: headingColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${qc.timerSeconds != null ? "${qc.timerSeconds}s" : "No timer"} · +${qc.xp} xp',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: headingColor,
                              side: BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChallengePlayScreen(challenge: qc),
                                ),
                              );
                            },
                            child: Text(
                              'Play',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Nudge Banner (Shown when quiet streak >= 2)
                if (provider.shouldNudge) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF0997B), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.crop_square_rounded, color: const Color(0xFFF0997B), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "You've done 2 quiet games in a row. Ready to say it out loud?",
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: headingColor,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconChip({
    required Color bg,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: iconColor),
    );
  }

  Widget _buildZoneCard({
    required String title,
    required String statusText,
    required Color iconBg,
    required Color iconColor,
    required Color borderColor,
    required Color cardBg,
    required Color headingColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            _buildIconChip(bg: iconBg, iconColor: iconColor, icon: Icons.crop_square_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: headingColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.crop_square_rounded, color: subtitleColor, size: 18),
          ],
        ),
      ),
    );
  }
}
