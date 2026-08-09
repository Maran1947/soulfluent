import 'package:flutter/material.dart';
import 'package:fluentsoul_mobile/models/session.dart';

class TranscriptDrawer extends StatelessWidget {
  final List<GDMessage> messages;
  final Function(String audioUrl)? onPlayAudio;

  const TranscriptDrawer({
    super.key,
    required this.messages,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text(
            'No turns recorded yet. Hold the mic to speak!',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isUser = msg.speakerType == 'user';
        final speakerName =
            isUser ? 'You' : (msg.personaKey?.toUpperCase() ?? 'PERSONA');

        final Color avatarBg = isUser
            ? const Color(0xFF6366F1)
            : (msg.personaKey == 'riya'
                ? const Color(0xFFF59E0B)
                : const Color(0xFFF25C40));

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: avatarBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        speakerName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    speakerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (msg.audioUrl != null && onPlayAudio != null)
                    GestureDetector(
                      onTap: () => onPlayAudio!(msg.audioUrl!),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 16,
                          color: Color(0xFFF25C40),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                msg.transcript,
                style: const TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
