import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/models/challenge.dart';
import 'package:fluentsoul_mobile/providers/challenges_provider.dart';

class ChallengePlayScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengePlayScreen({super.key, required this.challenge});

  @override
  State<ChallengePlayScreen> createState() => _ChallengePlayScreenState();
}

class _ChallengePlayScreenState extends State<ChallengePlayScreen> {
  bool _hasStarted = false;
  bool _isCompleted = false;
  String? _selectedMood;

  // Timer states
  Timer? _timer;
  int _secondsLeft = 0;
  int _secondsElapsed = 0;

  // Quiet challenge minigame states
  final TextEditingController _textController = TextEditingController();
  final List<String> _typedWords = [];
  String? _selectedGapWord;

  @override
  void initState() {
    super.initState();
    if (widget.challenge.timerType == 'countdown') {
      _secondsLeft = widget.challenge.timerSeconds ?? 60;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _startChallenge() {
    setState(() => _hasStarted = true);

    if (widget.challenge.timerType == 'countdown') {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_secondsLeft > 1) {
          setState(() => _secondsLeft--);
        } else {
          t.cancel();
          _finishChallenge();
        }
      });
    } else if (widget.challenge.timerType == 'count_up') {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _secondsElapsed++);
      });
    }
  }

  void _finishChallenge() {
    _timer?.cancel();
    final provider = Provider.of<ChallengesProvider>(context, listen: false);
    provider.completeChallenge(widget.challenge);
    setState(() {
      _isCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF131829) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1B2138) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2A3150) : const Color(0xFFE2E8F0);
    final headingColor =
        isDark ? const Color(0xFFEDEFF7) : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF8A8FA3) : const Color(0xFF64748B);
    const coralPrimary = Color(0xFFFF8B5E);
    const coralTextDark = Color(0xFF3A1D0E);

    final challenge = widget.challenge;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: headingColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          challenge.title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: headingColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Challenge Prompt Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: headingColor,
                      ),
                    ),
                    if (!_hasStarted || _isCompleted) ...[
                      const SizedBox(height: 6),
                      Text(
                        challenge.description,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: subtitleColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mood Check-in Step (if challenge has_mood_checkin and not started yet)
              if (challenge.hasMoodCheckin &&
                  !_hasStarted &&
                  !_isCompleted) ...[
                Text(
                  'How are you feeling right now?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMoodEmoji('😰', 'nervous'),
                    const SizedBox(width: 16),
                    _buildMoodEmoji('😐', 'neutral'),
                    const SizedBox(width: 16),
                    _buildMoodEmoji('😊', 'confident'),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Challenge Active Area
              Expanded(
                child: _isCompleted
                    ? _buildCompletionSummary(cardBg, borderColor, headingColor,
                        subtitleColor, coralPrimary)
                    : (!_hasStarted
                        ? _buildPreStartScreen(coralPrimary, coralTextDark)
                        : _buildInteractiveArea(cardBg, borderColor,
                            headingColor, subtitleColor, coralPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreStartScreen(Color coralPrimary, Color coralTextDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.crop_square_rounded, size: 48, color: coralPrimary),
        const SizedBox(height: 16),
        Text(
          '+${widget.challenge.xp} XP',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: coralPrimary,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: coralPrimary,
              foregroundColor: coralTextDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _startChallenge,
            child: Text(
              'Begin',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveArea(
    Color cardBg,
    Color borderColor,
    Color headingColor,
    Color subtitleColor,
    Color coralPrimary,
  ) {
    final timerType = widget.challenge.timerType;

    return Column(
      children: [
        // Timer View (Countdown / Count up / None)
        if (timerType == 'countdown') ...[
          Text(
            _formatDuration(_secondsLeft),
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (widget.challenge.timerSeconds ?? 60) > 0
                  ? _secondsLeft / (widget.challenge.timerSeconds ?? 60)
                  : 0.0,
              minHeight: 6,
              backgroundColor: borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(coralPrimary),
            ),
          ),
        ] else if (timerType == 'count_up') ...[
          Text(
            _formatDuration(_secondsElapsed),
            style: GoogleFonts.inter(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: headingColor,
            ),
          ),
        ],

        const SizedBox(height: 32),

        // Interactive Component based on Voice vs Quiet Challenge ID
        Expanded(
          child: SingleChildScrollView(
            child: widget.challenge.requiresVoice
                ? _buildVoiceRecordingArea(
                    coralPrimary, headingColor, subtitleColor)
                : _buildQuietMinigameArea(cardBg, borderColor, headingColor,
                    subtitleColor, coralPrimary),
          ),
        ),

        const SizedBox(height: 16),

        // Finish Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: coralPrimary,
              foregroundColor: const Color(0xFF3A1D0E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _finishChallenge,
            child: Text(
              'Complete Challenge',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceRecordingArea(
      Color coralPrimary, Color headingColor, Color subtitleColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: coralPrimary.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: coralPrimary, width: 2),
          ),
          child: Icon(Icons.mic_rounded, color: coralPrimary, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          'Listening... Speak out loud',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: headingColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuietMinigameArea(
    Color cardBg,
    Color borderColor,
    Color headingColor,
    Color subtitleColor,
    Color coralPrimary,
  ) {
    final id = widget.challenge.id;

    if (id == 'word_race') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category: Technology & AI',
            style: GoogleFonts.inter(
                fontSize: 14,
                color: subtitleColor,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            style: GoogleFonts.inter(color: headingColor),
            decoration: InputDecoration(
              hintText: 'Type a matching word...',
              hintStyle: GoogleFonts.inter(color: subtitleColor),
              filled: true,
              fillColor: cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.send_rounded, color: coralPrimary),
                onPressed: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _typedWords.add(text);
                      _textController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: _typedWords.map((w) {
              return Chip(
                backgroundColor: cardBg,
                side: BorderSide(color: borderColor),
                label: Text(w,
                    style:
                        GoogleFonts.inter(color: headingColor, fontSize: 13)),
              );
            }).toList(),
          ),
        ],
      );
    } else if (id == 'fill_the_gap') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sentence:',
            style: GoogleFonts.inter(fontSize: 13, color: subtitleColor),
          ),
          const SizedBox(height: 8),
          Text(
            'The speaker delivered a very ${_selectedGapWord ?? "____"} performance today.',
            style: GoogleFonts.inter(
                fontSize: 16, color: headingColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            children: ['articulate', 'hesitant', 'silent'].map((word) {
              final isSel = _selectedGapWord == word;
              return ChoiceChip(
                selected: isSel,
                selectedColor: coralPrimary,
                backgroundColor: cardBg,
                label: Text(
                  word,
                  style: GoogleFonts.inter(
                    color: isSel ? const Color(0xFF3A1D0E) : headingColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onSelected: (val) {
                  setState(() => _selectedGapWord = word);
                },
              );
            }).toList(),
          ),
        ],
      );
    } else {
      // Default generic quiet interaction fallback (e.g. Emoji Translate / Mistake Hunt)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prompt: 🗣️ ⏱️ 🎯',
            style: GoogleFonts.inter(fontSize: 22),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            style: GoogleFonts.inter(color: headingColor),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              hintStyle: GoogleFonts.inter(color: subtitleColor),
              filled: true,
              fillColor: cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCompletionSummary(
    Color cardBg,
    Color borderColor,
    Color headingColor,
    Color subtitleColor,
    Color coralPrimary,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline_rounded, size: 64, color: coralPrimary),
        const SizedBox(height: 16),
        Text(
          'Challenge Complete!',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '+${widget.challenge.xp} XP Earned',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: coralPrimary,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: headingColor,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  setState(() {
                    _hasStarted = false;
                    _isCompleted = false;
                    _secondsLeft = widget.challenge.timerSeconds ?? 60;
                    _secondsElapsed = 0;
                  });
                },
                child: Text('Try again',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: coralPrimary,
                  foregroundColor: const Color(0xFF3A1D0E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Back to challenges',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF8B5E).withOpacity(0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: const Color(0xFFFF8B5E), width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
