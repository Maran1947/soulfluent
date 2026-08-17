import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/onboarding_provider.dart';
import 'package:fluentsoul_mobile/services/audio_service.dart';

class VoiceExerciseStepWidget extends StatefulWidget {
  const VoiceExerciseStepWidget({super.key});

  @override
  State<VoiceExerciseStepWidget> createState() =>
      _VoiceExerciseStepWidgetState();
}

class _VoiceExerciseStepWidgetState extends State<VoiceExerciseStepWidget> {
  bool _isPlayingAudio = false;

  final List<Map<String, dynamic>> _exerciseLinesData = const [
    {
      'text': 'English is a journey, and I am ready to take the first step.',
      'icon': Icons.explore_rounded,
      'tag': 'First Step',
    },
    {
      'text': 'I may make mistakes, but I will never let them stop me.',
      'icon': Icons.shield_rounded,
      'tag': 'Courage',
    },
    {
      'text': 'Every word I speak makes me stronger and more confident.',
      'icon': Icons.fitness_center_rounded,
      'tag': 'Confidence',
    },
    {
      'text':
          'I will speak even when I feel nervous, because my voice deserves to be heard.',
      'icon': Icons.record_voice_over_rounded,
      'tag': 'Your Voice',
    },
    {
      'text':
          'I will keep learning, keep growing, and keep pushing myself forward.',
      'icon': Icons.trending_up_rounded,
      'tag': 'Growth',
    },
    {
      'text':
          'I trust my journey. I believe in my voice. I will make my soul fluent.',
      'icon': Icons.stars_rounded,
      'tag': 'Mastery',
    },
  ];

  Future<void> _playCurrentLineAudio(int index) async {
    setState(() => _isPlayingAudio = true);
    final text = _exerciseLinesData[index]['text'] as String;
    final encodedText = Uri.encodeComponent(text);
    final ttsUrl =
        'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=en&q=$encodedText';

    await AudioService().playAudioUrl(ttsUrl);
    if (mounted) {
      setState(() => _isPlayingAudio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<OnboardingProvider>();
    final currentIndex = provider.voiceExerciseLine;

    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final isLastCard = currentIndex == _exerciseLinesData.length - 1;
    final currentLine = _exerciseLinesData[currentIndex];
    final currentText = currentLine['text'] as String;
    final lineIcon = currentLine['icon'] as IconData;
    final lineTag = currentLine['tag'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // 6-Dot Line Progress Bar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_exerciseLinesData.length, (index) {
              final isCompleted = index <= currentIndex;
              final isCurrent = index == currentIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: isCurrent ? 24 : 8,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.primary
                      : (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 14),

          // Main Interactive Center Card with Line Quote Icon Box & Swipe Gestures
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < 0) {
                    provider.nextVoiceExerciseLine(); // Swipe left -> Next Line
                  } else if (details.primaryVelocity! > 0) {
                    provider.prevVoiceExerciseLine(); // Swipe right -> Prev Line
                  }
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.96, end: 1.0)
                          .animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey<int>(currentIndex),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isLastCard
                          ? AppTheme.primary.withOpacity(0.7)
                          : borderColor,
                      width: isLastCard ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isLastCard
                            ? AppTheme.primary.withOpacity(0.2)
                            : AppTheme.primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Top Row: Line Tag & Audio Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Line ${currentIndex + 1} / ${_exerciseLinesData.length} · $lineTag',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _playCurrentLineAudio(currentIndex),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isPlayingAudio
                                    ? AppTheme.primary
                                    : AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isPlayingAudio
                                        ? Icons.volume_up_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 16,
                                    color: _isPlayingAudio
                                        ? Colors.white
                                        : AppTheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isPlayingAudio
                                        ? 'Playing...'
                                        : 'Listen Audio',
                                    style: GoogleFonts.sora(
                                      fontSize: 11.5,
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

                      const Spacer(),

                      // Line Specific Quote Icon / Image Illustration Container
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(0.15),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            lineIcon,
                            size: 28,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Center Speech Text
                      Text(
                        currentText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sora(
                          fontSize: isLastCard ? 18.5 : 17.5,
                          fontWeight:
                              isLastCard ? FontWeight.bold : FontWeight.w600,
                          height: 1.5,
                          color: isLastCard ? AppTheme.primary : headingColor,
                        ),
                      ),

                      const Spacer(),

                      // Footer Hint
                      if (isLastCard)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 14, color: Color(0xFF22C55E)),
                              const SizedBox(width: 6),
                              Text(
                                'Voice Primed! Tap Continue below.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22C55E),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          'Swipe or tap Next Line below',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
