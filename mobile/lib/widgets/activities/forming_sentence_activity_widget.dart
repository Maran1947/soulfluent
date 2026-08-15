import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';

class FormingSentenceActivityWidget extends StatefulWidget {
  final TrackActivity activity;
  final TrackNode node;
  final VoidCallback onCompleted;

  const FormingSentenceActivityWidget({
    super.key,
    required this.activity,
    required this.node,
    required this.onCompleted,
  });

  @override
  State<FormingSentenceActivityWidget> createState() =>
      _FormingSentenceActivityWidgetState();
}

class _FormingSentenceActivityWidgetState
    extends State<FormingSentenceActivityWidget> {
  final List<String> _targetWords = [
    'Good',
    'morning,',
    'nice',
    'to',
    'meet',
    'you'
  ];
  late List<String> _availableTiles;
  final List<String> _selectedTiles = [];
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _availableTiles = List.from(_targetWords)..shuffle();
  }

  void _addTile(String word) {
    setState(() {
      _availableTiles.remove(word);
      _selectedTiles.add(word);
      _isCorrect = null;
    });
  }

  void _removeTile(String word) {
    setState(() {
      _selectedTiles.remove(word);
      _availableTiles.add(word);
      _isCorrect = null;
    });
  }

  void _checkAnswer() {
    final userSentence = _selectedTiles.join(' ');
    final targetSentence = _targetWords.join(' ');
    setState(() {
      _isCorrect = (userSentence == targetSentence);
    });
    if (_isCorrect == true) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) widget.onCompleted();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131C2E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

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
                const Icon(Icons.extension_rounded, size: 14, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  'SENTENCE BUILD',
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
            'Tap the word tiles below in correct order to build the target expression.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: subtitleColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Sentence Target Slots Area
          Container(
            constraints: const BoxConstraints(minHeight: 110),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isCorrect == true
                    ? const Color(0xFF10B981)
                    : (_isCorrect == false ? Colors.redAccent : borderColor),
                width: _isCorrect != null ? 2.0 : 1.0,
              ),
            ),
            child: _selectedTiles.isEmpty
                ? Center(
                    child: Text(
                      'Tap word tiles to form sentence...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: _selectedTiles.map((word) {
                      return GestureDetector(
                        onTap: () => _removeTile(word),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            word,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 24),

          // Available Word Tiles Bank
          Text(
            'Word Tiles',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableTiles.map((word) {
              return GestureDetector(
                onTap: () => _addTile(word),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    word,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: headingColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          if (_isCorrect == true)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  Text(
                    'Perfect! Sentence built correctly.',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),

          // Check Answer Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedTiles.isNotEmpty ? _checkAnswer : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Check Answer',
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
