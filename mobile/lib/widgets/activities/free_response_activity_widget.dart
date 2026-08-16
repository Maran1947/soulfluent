import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';

class FreeResponseActivityWidget extends StatefulWidget {
  final TrackActivity activity;
  final TrackNode node;
  final VoidCallback onCompleted;

  const FreeResponseActivityWidget({
    super.key,
    required this.activity,
    required this.node,
    required this.onCompleted,
  });

  @override
  State<FreeResponseActivityWidget> createState() =>
      _FreeResponseActivityWidgetState();
}

class _FreeResponseActivityWidgetState
    extends State<FreeResponseActivityWidget> {
  bool _isRecording = false;
  String _transcript = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final prompt = widget.activity.config['instruction']?.toString() ??
        'Produce spontaneous speech for ${widget.node.theme}.';

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
                const Icon(Icons.mic_rounded,
                    size: 14, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  'FREE SPEECH',
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
            prompt,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: subtitleColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Live Speech Transcript Box
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Speech Transcript',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _transcript.isNotEmpty
                      ? _transcript
                      : (_isRecording
                          ? 'Listening to your speech...'
                          : 'Tap record button below and state your thoughts in English.'),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color:
                        _transcript.isNotEmpty ? headingColor : subtitleColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Speech Recorder Button
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isRecording = !_isRecording;
                      if (!_isRecording) {
                        _transcript =
                            'I think greetings are essential because they set a warm, friendly tone for any conversation.';
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.redAccent : AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? Colors.redAccent
                                  : AppTheme.primary)
                              .withOpacity(0.4),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isRecording
                      ? 'Recording... Tap to finish'
                      : 'Tap mic to speak',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isRecording ? Colors.redAccent : subtitleColor,
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
                'Complete Activity',
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
