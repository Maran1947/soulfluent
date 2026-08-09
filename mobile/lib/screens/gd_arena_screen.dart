import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/widgets/app_header.dart';
import 'package:fluentsoul_mobile/widgets/persona_card.dart';
import 'package:fluentsoul_mobile/widgets/wave_visualizer.dart';
import 'package:fluentsoul_mobile/widgets/transcript_drawer.dart';

class GDArenaScreen extends StatelessWidget {
  const GDArenaScreen({super.key});

  String _formatTimer(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final gd = context.watch<GDProvider>();
    final session = gd.currentSession;

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        title: 'GD Practice Arena',
        showBack: true,
        onBack: () => _showExitDialog(context),
        action: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Color(0xFFF25C40)),
              const SizedBox(width: 6),
              Text(
                _formatTimer(gd.secondsRemaining),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Topic Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF1E293B),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF25C40).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          session.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFF25C40),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Difficulty: ${session.difficulty}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.topic,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // AI Persona List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ...session.personas.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PersonaCard(
                        personaKey: p.key,
                        name: p.name,
                        personality: p.personality,
                        isSpeaking: gd.activeSpeaker == p.key,
                      ),
                    );
                  }).toList(),
                  if (gd.activeScaffoldPhrases.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: gd.activeScaffoldPhrases.map((phrase) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: const Color(0xFFF25C40).withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.tips_and_updates, size: 12, color: Color(0xFFF25C40)),
                                const SizedBox(width: 6),
                                Text(
                                  phrase,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Waveform Visualizer
            WaveVisualizer(
              isActive: gd.isRecording || gd.activeSpeaker != null || gd.isProcessingTurn,
            ),

            const SizedBox(height: 12),

            // Mic Controls
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTapDown: (_) async {
                        if (!gd.isProcessingTurn && gd.activeSpeaker == null) {
                          await gd.startRecording();
                        }
                      },
                      onTapUp: (_) async {
                        if (gd.isRecording) {
                          await gd.stopRecordingAndSubmit();
                        }
                      },
                      onTapCancel: () async {
                        if (gd.isRecording) {
                          await gd.stopRecordingAndSubmit();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: gd.isRecording ? 96 : 84,
                        height: gd.isRecording ? 96 : 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: gd.isRecording
                                ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                : [const Color(0xFFFA5A3A), const Color(0xFFF25C40)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (gd.isRecording
                                      ? Colors.redAccent
                                      : const Color(0xFFF25C40))
                                  .withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            )
                          ],
                        ),
                        child: Center(
                          child: gd.isProcessingTurn
                              ? const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                  size: 36,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      gd.isProcessingTurn
                          ? 'Gemini is processing response...'
                          : (gd.isRecording
                              ? 'Release to Send Turn 🚀'
                              : 'Hold to Speak 🎙️'),
                      style: TextStyle(
                        color: gd.isRecording
                            ? Colors.redAccent
                            : const Color(0xFFCBD5E1),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Transcript Drawer Section
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Color(0xFF334155))),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF475569),
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TranscriptDrawer(
                      messages: gd.messages,
                      onPlayAudio: (url) => gd.audioService.playAudioUrl(url),
                    ),
                  ),
                ],
              ),
            ),

            // End Session Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _endSession(context),
                      child: const Text('End & View Report'),
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

  void _endSession(BuildContext context) {
    final gd = context.read<GDProvider>();
    gd.endSession();
    Navigator.pushReplacementNamed(context, '/report');
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Exit Session?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to exit? Your GD feedback report will be generated for recorded turns.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endSession(context);
            },
            child: const Text('End & Exit'),
          ),
        ],
      ),
    );
  }
}
