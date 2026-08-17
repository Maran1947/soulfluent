import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';
import 'package:fluentsoul_mobile/services/audio_service.dart';

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
  final AudioService _audioService = AudioService();
  int _currentPhraseIndex = 0;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    // Auto-play first expression pronunciation when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoPlayCurrentPhrase();
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _autoPlayCurrentPhrase() {
    final phrases = _extractPhrases();
    if (phrases.isNotEmpty && _currentPhraseIndex < phrases.length) {
      _playPronunciation(phrases[_currentPhraseIndex]);
    }
  }

  Future<void> _playPronunciation(String phrase) async {
    setState(() {
      _isPlayingAudio = true;
    });

    try {
      final encoded = Uri.encodeComponent(phrase);
      final ttsUrl =
          'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=en&q=$encoded';
      await _audioService.playAudioUrl(ttsUrl);
    } catch (e) {
      debugPrint('Error playing pronunciation audio: $e');
    } finally {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  List<String> _extractPhrases() {
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
    return phrases;
  }

  void _goToNext(int total) {
    if (_currentPhraseIndex < total - 1) {
      setState(() {
        _currentPhraseIndex++;
      });
      _autoPlayCurrentPhrase();
    } else {
      widget.onCompleted();
    }
  }

  void _goToPrevious() {
    if (_currentPhraseIndex > 0) {
      setState(() {
        _currentPhraseIndex--;
      });
      _autoPlayCurrentPhrase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final phrases = _extractPhrases();
    final totalPhrases = phrases.length;
    final currentPhrase = phrases[_currentPhraseIndex];

    return Column(
      children: [
        // Scrollable Focus Card Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Clean & Non-Redundant)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              size: 14, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'KEY EXPRESSIONS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentPhraseIndex + 1} / $totalPhrases',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 🌟 Hero Focus Card for Current Expression
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_currentPhraseIndex),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.4),
                          width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'LISTEN & LEARN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Expression Text
                        Text(
                          currentPhrase,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sora(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: headingColor,
                            height: 1.28,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Replay Audio Pronunciation Button
                        GestureDetector(
                          onTap: () => _playPronunciation(currentPhrase),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: _isPlayingAudio
                                  ? AppTheme.primary
                                  : AppTheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppTheme.primary.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPlayingAudio
                                      ? Icons.volume_up_rounded
                                      : Icons.play_arrow_rounded,
                                  color: _isPlayingAudio
                                      ? Colors.white
                                      : AppTheme.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isPlayingAudio
                                      ? 'Playing Audio...'
                                      : 'Tap to Listen Again',
                                  style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _isPlayingAudio
                                        ? Colors.white
                                        : AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Context Usage Tip Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B).withOpacity(0.6)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAB308).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.lightbulb_outline_rounded,
                              size: 20, color: Color(0xFFEAB308)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'USAGE TIP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: headingColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Practice saying this phrase out loud 2-3 times to lock it in memory.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: subtitleColor,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pinned Bottom Navigation Action Bar
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(
                top: BorderSide(color: borderColor.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                if (_currentPhraseIndex > 0)
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _goToPrevious,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: headingColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _goToNext(totalPhrases),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPhraseIndex == totalPhrases - 1
                                ? 'Finish Lesson'
                                : 'Next Expression',
                            style: GoogleFonts.sora(
                              fontSize: 16,
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
        ),
      ],
    );
  }
}
