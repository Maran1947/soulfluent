import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';

class EchoActivityWidget extends StatefulWidget {
  final TrackActivity activity;
  final TrackNode node;
  final VoidCallback onCompleted;

  const EchoActivityWidget({
    super.key,
    required this.activity,
    required this.node,
    required this.onCompleted,
  });

  @override
  State<EchoActivityWidget> createState() => _EchoActivityWidgetState();
}

class _EchoActivityWidgetState extends State<EchoActivityWidget> {
  bool _isPlayingAudio = false;
  bool _isRecording = false;
  bool _hasRecorded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final phraseToEcho = widget.node.phrasesA.isNotEmpty
        ? widget.node.phrasesA.first
        : 'Good morning, how are you doing today?';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
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
                const Icon(Icons.headphones_rounded, size: 14, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  'LISTEN & ECHO',
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
            'Listen to the native audio below and speak the phrase out loud.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: subtitleColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Native Audio Player Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _isPlayingAudio = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _isPlayingAudio = false);
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Native Pronunciation',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: headingColor,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _isPlayingAudio ? 'Playing audio...' : 'Tap to listen',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Center(
                    child: Text(
                      '"$phraseToEcho"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: headingColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // User Recording Section
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isRecording = !_isRecording;
                      if (!_isRecording) _hasRecorded = true;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? Colors.redAccent
                          : (_hasRecorded ? const Color(0xFF10B981) : AppTheme.primary),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? Colors.redAccent
                                  : AppTheme.primary)
                              .withOpacity(0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isRecording
                            ? Icons.stop_rounded
                            : (_hasRecorded ? Icons.check_rounded : Icons.mic_rounded),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isRecording
                      ? 'Listening... Speak now!'
                      : (_hasRecorded ? 'Great echo! 96% Match' : 'Tap mic to echo phrase'),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isRecording
                        ? Colors.redAccent
                        : (_hasRecorded ? const Color(0xFF10B981) : subtitleColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

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
                'Continue',
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
