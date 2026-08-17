import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/services/audio_service.dart';

class DailySpeakRecordingScreen extends StatefulWidget {
  final String topic;
  final String subtitle;
  final int streakDays;
  final List<String> talkingPoints;
  final List<String> starterPhrases;

  const DailySpeakRecordingScreen({
    super.key,
    required this.topic,
    required this.subtitle,
    required this.streakDays,
    this.talkingPoints = const [],
    this.starterPhrases = const [],
  });

  @override
  State<DailySpeakRecordingScreen> createState() =>
      _DailySpeakRecordingScreenState();
}

class _DailySpeakRecordingScreenState extends State<DailySpeakRecordingScreen>
    with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  Timer? _timer;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  int _secondsElapsed = 0;
  final int _maxSeconds = 60;
  bool _isFinished = false;
  bool _isSubmitting = false;
  bool _showHints = false;
  bool _isSpeaking = false;
  double _currentVolume = 0.0;

  List<String> get _activeTalkingPoints => widget.talkingPoints.isNotEmpty
      ? widget.talkingPoints
      : const [
          'Remote work saves daily commute time and offers flexible hours',
          'In-office environments foster faster team collaboration & bonding',
          'A hybrid model combines flexibility and human connection',
        ];

  List<String> get _activeStarterPhrases => widget.starterPhrases.isNotEmpty
      ? widget.starterPhrases
      : const [
          'In my experience, working from home...',
          'While office collaboration is essential, I believe...',
          'The main reason I prefer...',
          'On the balance, a hybrid approach...',
        ];

  late AnimationController _waveAnimationController;

  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _startRecordingSession();
  }

  Future<void> _startRecordingSession() async {
    try {
      await _audioService.startRecording();
      _amplitudeSubscription =
          _audioService.onAmplitudeChanged().listen((amp) {
        if (!mounted) return;
        // Normalize decibels: amp.current ranges from -160 (silent) to 0 (loud)
        final norm = ((amp.current + 50.0) / 50.0).clamp(0.0, 1.0);
        setState(() {
          _isSpeaking = norm > 0.08;
          _currentVolume = norm;
        });
      });
    } catch (e) {
      debugPrint('Audio recording start error: $e');
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });

      if (_secondsElapsed >= _maxSeconds) {
        _finishSpeaking();
      }
    });
  }

  Future<void> _finishSpeaking() async {
    if (_isFinished || _isSubmitting) return;
    _isFinished = true;
    _timer?.cancel();
    _amplitudeSubscription?.cancel();

    setState(() {
      _isSubmitting = true;
    });

    final gd = context.read<GDProvider>();

    try {
      final recordedPath = await _audioService.stopRecording();
      if (recordedPath != null && gd.currentSession != null) {
        await gd.submitRecordedFile(recordedPath);
      }
      await gd.endSession();
    } catch (e) {
      debugPrint('Error finishing speaking: $e');
      try {
        await gd.endSession();
      } catch (_) {}
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/report');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();
    _waveAnimationController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.background : const Color(0xFFF8FAFC);
    final cardBg = isDark ? AppTheme.cardDark : Colors.white;
    final headingColor = isDark ? AppTheme.textMain : const Color(0xFF0F172A);
    final subtitleColor = isDark ? AppTheme.textMuted : const Color(0xFF64748B);
    final borderColor = isDark ? AppTheme.borderDark : const Color(0xFFF1F5F9);
    final primaryColor = AppTheme.primary;

    final progressRatio = (_secondsElapsed / _maxSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Circle Button
                  GestureDetector(
                    onTap: () {
                      _timer?.cancel();
                      _audioService.stopRecording();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cardBg,
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: headingColor,
                        size: 26,
                      ),
                    ),
                  ),

                  // Center Title & Segment Dots
                  Column(
                    children: [
                      Text(
                        'Daily Speak',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 3 Segment Dots
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 5,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 10,
                            height: 5,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 10,
                            height: 5,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Streak Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF451A03).withOpacity(0.4)
                          : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF9A3412).withOpacity(0.4)
                            : const Color(0xFFFFEDD5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.streakDays} Day Streak',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEA580C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // TODAY'S TOPIC tag
                    Text(
                      "TODAY'S TOPIC",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 1.1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Topic Title Question
                    Text(
                      widget.topic,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: headingColor,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Instruction Subtitle
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Hints Toggle Pill (Starts OFF by default)
                    GestureDetector(
                      onTap: () => setState(() => _showHints = !_showHints),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _showHints
                              ? primaryColor.withOpacity(0.14)
                              : cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _showHints
                                ? primaryColor.withOpacity(0.35)
                                : borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 6),
                            Text(
                              _showHints ? 'Hide Hints & Ideas' : 'Need Hints or Ideas?',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: _showHints
                                    ? primaryColor
                                    : subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Center Hero Circle with Progress Ring, Waveforms & Mic Image
                    SizedBox(
                      width: 290,
                      height: 290,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Soft Outer Circle
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor.withOpacity(0.04),
                            ),
                          ),

                          // Progress Ring Arc
                          SizedBox(
                            width: 282,
                            height: 282,
                            child: CircularProgressIndicator(
                              value: progressRatio,
                              strokeWidth: 4,
                              backgroundColor: primaryColor.withOpacity(0.12),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),

                          // Inner Content Column
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Elapsed & Total Time Readout
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _formatTime(_secondsElapsed),
                                    style: GoogleFonts.outfit(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '/ 01:00',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Center Mic Image & Sound Waveforms Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Left Waveform Bars
                                  _buildWaveformBars(primaryColor, true),

                                  const SizedBox(width: 8),

                                  // mic_orange.png image
                                  Image.asset(
                                    'assets/images/mic_orange.png',
                                    width: 125,
                                    height: 125,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.mic_rounded,
                                      size: 90,
                                      color: primaryColor,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Right Waveform Bars
                                  _buildWaveformBars(primaryColor, false),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Red Dot "Recording..." Capsule Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFFFEE2E2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Recording...',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // 💡 Hints & Starter Phrases Card
                    if (_showHints) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor, width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text('💡', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'IDEAS & HINTS TO SUPPORT YOUR ANSWER',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._activeTalkingPoints.map(
                              (point) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: GoogleFonts.inter(
                                          fontSize: 12.5,
                                          color: headingColor.withOpacity(0.9),
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'STARTER PHRASES:',
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: subtitleColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _activeStarterPhrases.map((phrase) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: primaryColor.withOpacity(0.25),
                                        ),
                                      ),
                                      child: Text(
                                        phrase,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Action Button ("Finish Speaking")
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _finishSpeaking,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primaryColor, width: 1.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.stop_rounded,
                                    color: primaryColor,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Finish Speaking',
                                    style: GoogleFonts.outfit(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
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
          ],
        ),
      ),
    );
  }

  Widget _buildWaveformBars(Color color, bool isLeft) {
    if (!_isSpeaking) {
      // Silent State (Google Meet style flat dim bars)
      return Row(
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 3.5,
            height: 6,
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      );
    }

    // Active Voice State (Live audio amplitude visualizer)
    return AnimatedBuilder(
      animation: _waveAnimationController,
      builder: (context, _) {
        final val = _waveAnimationController.value;
        return Row(
          children: List.generate(4, (index) {
            final multiplier =
                math.sin((val * math.pi) + (index * 0.8)) * 0.5 + 0.5;
            final h = 10 + (_currentVolume * multiplier * 26);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3.5,
              height: h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.5 + (_currentVolume * 0.5)),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
