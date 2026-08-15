import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';

typedef NodeDetailScreen = DayDetailScreen;

class DayDetailScreen extends StatefulWidget {
  final TrackNode day;

  const DayDetailScreen({super.key, required this.day});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  bool _showAllPhrases = false;
  bool _showHearItFirst = false;
  bool _showSampleExchange = false;
  String? _selectedMood;

  final Map<String, PersonaInfo> _personas = const {
    'riya': PersonaInfo(
      key: 'riya',
      name: 'Riya',
      initial: 'R',
      color: Color(0xFFFF5A36),
      sub: '🇮🇳 Empathetic Peacemaker',
      flag: '🇮🇳',
    ),
    'rohan': PersonaInfo(
      key: 'rohan',
      name: 'Rohan',
      initial: 'R',
      color: Color(0xFFE3B23C),
      sub: '🇮🇳 Structured Strategist',
      flag: '🇮🇳',
    ),
    'emily': PersonaInfo(
      key: 'emily',
      name: 'Emily',
      initial: 'E',
      color: Color(0xFFF0455C),
      sub: '🇺🇸 Sharp Orator',
      flag: '🇺🇸',
    ),
    'alex': PersonaInfo(
      key: 'alex',
      name: 'Alex',
      initial: 'A',
      color: Color(0xFF3A86FF),
      sub: '🇬🇧 Critical Debater',
      flag: '🇬🇧',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final gd = Provider.of<GDProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final day = widget.day;
    final currentTrack = gd.activeTrack;
    final phrases = currentTrack == 'A' ? day.phrasesA : day.phrasesB;
    final p = _personas[day.persona] ?? _personas['riya']!;

    final modeLabel = <String, String>{
          'foundation': '1:1 Foundation',
          'debate': '1:1 Debate',
          'group': 'Group Discussion',
          'milestone': 'Milestone Test',
          'echo': 'Listen & Echo',
          'production': 'Word to Phrase',
          'roleplay': 'Roleplay Practice',
          'bridge': 'Bridge Module',
        }[day.mode] ??
        '1:1 Foundation';

    final displayPhrases = _showAllPhrases
        ? phrases
        : (phrases.isNotEmpty ? [phrases.first] : <String>[]);
    final hasMorePhrases = phrases.length > 1;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: headingColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: p.color.withOpacity(0.6), width: 1.2),
              ),
              child: Text(
                modeLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: p.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              'Day ${day.d}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: subtitleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Title
                    Text(
                      day.theme,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Persona Avatar & Opening AI Line
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          margin: const EdgeInsets.only(top: 2, right: 12),
                          decoration: BoxDecoration(
                            color: p.color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              p.initial,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            day.shortHook,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: headingColor,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Instruction (Unboxed clean text)
                    Text(
                      day.shortInstruction,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: subtitleColor,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3 Icon Stat Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildIconStatCard(
                            icon: Icons.access_time_rounded,
                            value: day.wpm > 0 ? '${day.wpm} wpm' : 'free pace',
                            cardBg: cardBg,
                            borderColor: borderColor,
                            headingColor: headingColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildIconStatCard(
                            icon: Icons.track_changes_rounded,
                            value: day.filler,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            headingColor: headingColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildIconStatCard(
                            icon: Icons.support_rounded,
                            value: day.rescuePhrases.isNotEmpty
                                ? 'rescue on'
                                : 'standard',
                            cardBg: cardBg,
                            borderColor: borderColor,
                            headingColor: headingColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Scaffolding Phrases Row
                    if (phrases.isNotEmpty) ...[
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ...displayPhrases.map((ph) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: borderColor),
                              ),
                              child: Text(
                                ph,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  color: headingColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }),
                          if (hasMorePhrases && !_showAllPhrases)
                            InkWell(
                              onTap: () {
                                setState(() => _showAllPhrases = true);
                              },
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Text(
                                  '+${phrases.length - 1} more',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          if (_showAllPhrases && hasMorePhrases)
                            InkWell(
                              onTap: () {
                                setState(() => _showAllPhrases = false);
                              },
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Text(
                                  'Show less',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    Divider(color: borderColor, height: 1),

                    // Accordion 1: Hear it first
                    _buildAccordionTile(
                      icon: Icons.headphones_rounded,
                      title: 'Hear it first',
                      isOpen: _showHearItFirst,
                      borderColor: borderColor,
                      headingColor: headingColor,
                      onTap: () {
                        setState(() => _showHearItFirst = !_showHearItFirst);
                      },
                      content: day.shadowLine != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 12),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.play_circle_fill_rounded,
                                        color: AppTheme.primary,
                                        size: 36),
                                    onPressed: () {},
                                  ),
                                  Expanded(
                                    child: Text(
                                      day.shadowLine!,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: headingColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 12),
                              child: Text(
                                day.aiLine,
                                style: GoogleFonts.inter(
                                    fontSize: 13.5, color: headingColor),
                              ),
                            ),
                    ),

                    Divider(color: borderColor, height: 1),

                    // Accordion 2: Sample exchange
                    _buildAccordionTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Sample exchange',
                      isOpen: _showSampleExchange,
                      borderColor: borderColor,
                      headingColor: headingColor,
                      onTap: () {
                        setState(
                            () => _showSampleExchange = !_showSampleExchange);
                      },
                      content: day.script.isNotEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: day.script.map((line) {
                                  final isYou = line.startsWith('You:');
                                  final text = line.replaceFirst(
                                      RegExp(
                                          r'^(You|Riya|Rohan|Emily|Alex):\s*'),
                                      '');
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      '${isYou ? "You" : p.name}: $text',
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        color: isYou
                                            ? AppTheme.primary
                                            : headingColor,
                                        fontWeight: isYou
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 12),
                              child: Text(
                                'No sample exchange available for this module.',
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: subtitleColor),
                              ),
                            ),
                    ),

                    Divider(color: borderColor, height: 1),

                    const SizedBox(height: 28),

                    // Mood Check-in Selector
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Feeling before this? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: subtitleColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildMoodEmoji('😰', 'nervous'),
                              const SizedBox(width: 12),
                              _buildMoodEmoji('😐', 'neutral'),
                              const SizedBox(width: 12),
                              _buildMoodEmoji('😊', 'confident'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed Bottom CTA Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                    top: BorderSide(color: borderColor.withOpacity(0.5))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF25C40),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final success = await gd.startPathDaySession(
                      day: day,
                      track: currentTrack,
                    );
                    if (success) {
                      nav.pushNamed('/arena');
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic_rounded,
                          color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Enter voice room',
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }

  Widget _buildIconStatCard({
    required IconData icon,
    required String value,
    required Color cardBg,
    required Color borderColor,
    required Color headingColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: headingColor.withOpacity(0.8)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionTile({
    required IconData icon,
    required String title,
    required bool isOpen,
    required Color borderColor,
    required Color headingColor,
    required VoidCallback onTap,
    required Widget content,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: headingColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: headingColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: headingColor.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
        if (isOpen) content,
      ],
    );
  }

  Widget _buildMoodEmoji(String emoji, String moodKey) {
    final isSelected = _selectedMood == moodKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = isSelected ? null : moodKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
