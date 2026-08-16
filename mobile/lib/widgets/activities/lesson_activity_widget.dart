import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';

class LessonActivityWidget extends StatefulWidget {
  final TrackActivity activity;
  final TrackNode node;
  final VoidCallback onCompleted;

  const LessonActivityWidget({
    super.key,
    required this.activity,
    required this.node,
    required this.onCompleted,
  });

  @override
  State<LessonActivityWidget> createState() => _LessonActivityWidgetState();
}

class _LessonActivityWidgetState extends State<LessonActivityWidget> {
  bool _isPlayingAudio = false;
  int? _selectedPhraseIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final instruction = widget.activity.config['instruction']?.toString() ??
        'Learn core expressions and context for ${widget.node.theme}.';

    final List<String> phrases = [];
    final config = widget.activity.config;
    if (config['content'] is Map && config['content']['items'] is List) {
      for (var item in config['content']['items']) {
        if (item is Map) {
          final val = item['example']?.toString() ?? item['word']?.toString();
          if (val != null && val.isNotEmpty && !phrases.contains(val)) {
            phrases.add(val);
          }
        }
      }
    }
    if (phrases.isEmpty && widget.node.phrasesA.isNotEmpty) {
      phrases.addAll(widget.node.phrasesA);
    }
    if (phrases.isEmpty) {
      phrases.addAll(
          ['Hello, nice to meet you!', 'Good morning! How are you doing?']);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge & Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_rounded,
                    size: 14, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  'CONTEXT LESSON',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(
            widget.activity.title,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            instruction,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: subtitleColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Key Phrases Section
          Text(
            'Key Expressions',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 12),

          ...phrases.asMap().entries.map((entry) {
            final idx = entry.key;
            final phrase = entry.value;
            final isSelected = _selectedPhraseIndex == idx;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPhraseIndex = idx;
                  _isPlayingAudio = true;
                });
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _isPlayingAudio = false);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppTheme.primary.withOpacity(0.1) : cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : borderColor,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          (isSelected && _isPlayingAudio)
                              ? Icons.volume_up_rounded
                              : Icons.play_arrow_rounded,
                          color: isSelected ? Colors.white : AppTheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phrase,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: headingColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to listen pronunciation',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Context Usage Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E293B).withOpacity(0.6)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        size: 18, color: Color(0xFFEAB308)),
                    const SizedBox(width: 8),
                    Text(
                      'Usage Tip',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Use these expressions naturally in daily greetings without overthinking translations.',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: subtitleColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onCompleted,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Understand & Continue',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
