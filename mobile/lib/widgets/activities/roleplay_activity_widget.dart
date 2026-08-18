import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';

class RoleplayActivityWidget extends StatefulWidget {
  final TrackActivity activity;
  final TrackNode node;
  final VoidCallback onCompleted;

  const RoleplayActivityWidget({
    super.key,
    required this.activity,
    required this.node,
    required this.onCompleted,
  });

  @override
  State<RoleplayActivityWidget> createState() => _RoleplayActivityWidgetState();
}

class _RoleplayActivityWidgetState extends State<RoleplayActivityWidget> {
  late List<Map<String, String>> _messages;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    final initialText = widget.node.aiLine.isNotEmpty
        ? widget.node.aiLine
        : (widget.activity.config['initial_message']?.toString() ??
            'Hello there! Welcome to our session. How are you doing today?');
    _messages = [
      {'sender': 'coach', 'text': initialText},
    ];
  }

  void _sendReply(String text) {
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'coach',
            'text':
                'That sounds great! I am glad to hear that. Shall we continue our practice?'
          });
        });
      }
    });
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

    final suggestions = widget.node.phrasesA.isNotEmpty
        ? widget.node.phrasesA
        : ['I am doing great, thank you!', 'Good morning! Ready to practice.'];

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
                const Icon(Icons.record_voice_over_rounded,
                    size: 14, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  'AI ROLEPLAY SIMULATION',
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
            'Practice natural turn-taking in this real-time conversational simulation.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: subtitleColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Exchange Thread Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: _messages.map((msg) {
                final isCoach = msg['sender'] == 'coach';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isCoach
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      if (isCoach) ...[
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('R',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isCoach
                                ? (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9))
                                : AppTheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['text'] ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              color: isCoach ? headingColor : Colors.white,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Suggested Quick Replies
          Text(
            'Suggested Expressions',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((sug) {
              return ActionChip(
                label: Text(
                  sug,
                  style: GoogleFonts.inter(fontSize: 13, color: headingColor),
                ),
                backgroundColor:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(color: borderColor),
                ),
                onPressed: () => _sendReply(sug),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Speech Input Button
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() => _isRecording = !_isRecording);
                if (!_isRecording) {
                  _sendReply('I am feeling confident and ready to practice!');
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.redAccent : AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isRecording ? Colors.redAccent : AppTheme.primary)
                              .withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Complete Button
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
                'Complete Roleplay',
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
