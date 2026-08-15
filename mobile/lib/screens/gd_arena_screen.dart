import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/l10n/app_localizations.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/providers/locale_provider.dart';
import 'package:fluentsoul_mobile/widgets/persona_card.dart';
import 'package:fluentsoul_mobile/widgets/transcript_drawer.dart';
import 'package:fluentsoul_mobile/widgets/logo_widgets.dart';

class GDArenaScreen extends StatefulWidget {
  const GDArenaScreen({super.key});

  @override
  State<GDArenaScreen> createState() => _GDArenaScreenState();
}

class _GDArenaScreenState extends State<GDArenaScreen> {
  bool _showCaptionsSheet = false;

  String _formatTimer(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final gd = context.watch<GDProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final session = gd.currentSession;

    if (gd.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              gd.errorMessage!,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        gd.clearError();
      });
    }

    if (session == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF090D16),
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final personas = session.personas;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Google Meet Top App Bar Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: Colors.white),
                    onPressed: () => _showExitDialog(context),
                  ),
                  const SizedBox(width: 4),
                  const FluentSoulLogo(size: 28),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFA5A3A), Color(0xFFF25C40)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Live GD Room',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.6),
                          blurRadius: 6,
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Meeting Timer Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          _formatTimer(gd.secondsRemaining),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Topic & Category Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF0F172A).withOpacity(0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          session.category.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: AppTheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Difficulty: ${session.difficulty}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.topic,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 3. Meeting Grid Layout (Google Meet Flexible Grid Tiles)
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final allTiles = <Widget>[
                      ...personas.map((p) {
                        return PersonaCard(
                          personaKey: p.key,
                          name: p.name,
                          personality: p.personality,
                          isSpeaking: gd.activeSpeaker == p.key,
                          isUser: false,
                        );
                      }),
                      PersonaCard(
                        personaKey: 'user',
                        name: 'You',
                        personality: gd.isRecording
                            ? 'Speaking...'
                            : 'Active Participant',
                        isSpeaking:
                            gd.isRecording || gd.activeSpeaker == 'user',
                        isUser: true,
                      ),
                    ];

                    return _buildSquareMeetingGrid(
                      allTiles,
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                  },
                ),
              ),
            ),

            // 4. Scaffold Phrases Bar (if path day mode)
            if (gd.activeScaffoldPhrases.isNotEmpty)
              Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: gd.activeScaffoldPhrases.length,
                  itemBuilder: (context, index) {
                    final phrase = gd.activeScaffoldPhrases[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tips_and_updates,
                              size: 13, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            phrase,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // 5. Collapsible Captions / Transcript Drawer Sheet
            if (_showCaptionsSheet)
              Container(
                height: 220,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCaptionsSheet = false;
                          });
                        },
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF475569),
                            borderRadius: BorderRadius.circular(2),
                          ),
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

            // 6. Google Meet Bottom Floating Dock Bar
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF1E293B)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Captions / Transcript Toggle Button
                  Stack(
                    children: [
                      IconButton(
                        iconSize: 24,
                        icon: Icon(
                          _showCaptionsSheet
                              ? Icons.subtitles_rounded
                              : Icons.subtitles_outlined,
                          color: _showCaptionsSheet
                              ? AppTheme.primary
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _showCaptionsSheet = !_showCaptionsSheet;
                          });
                        },
                      ),
                      if (gd.messages.isNotEmpty)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${gd.messages.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Center Mic Button (Hold to Speak / Tap to Toggle)
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
                      width: gd.isRecording ? 68 : 60,
                      height: gd.isRecording ? 68 : 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: gd.isRecording
                              ? [
                                  const Color(0xFFEF4444),
                                  const Color(0xFFDC2626)
                                ]
                              : [
                                  const Color(0xFFFA5A3A),
                                  const Color(0xFFF25C40)
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (gd.isRecording
                                    ? Colors.redAccent
                                    : const Color(0xFFF25C40))
                                .withOpacity(0.45),
                            blurRadius: 16,
                            spreadRadius: 3,
                          )
                        ],
                      ),
                      child: Center(
                        child: gd.isProcessingTurn
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Icon(
                                gd.isRecording
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                      ),
                    ),
                  ),

                  // End Call / Leave Meeting Red Button
                  IconButton(
                    iconSize: 24,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.call_end_rounded),
                    onPressed: () => _endSession(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareMeetingGrid(
    List<Widget> tiles,
    double availableWidth,
    double availableHeight,
  ) {
    final count = tiles.length;
    if (count == 0) return const SizedBox.shrink();

    // Determine grid columns and rows based on participant count
    int cols = (count <= 1) ? 1 : 2;
    int rows = (count / cols).ceil();

    // Calculate maximum possible tile width and height to fit in available space
    double spacing = 10.0;
    double maxTileWidth = (availableWidth - (spacing * (cols + 1))) / cols;
    double maxTileHeight = (availableHeight - (spacing * (rows + 1))) / rows;

    // Use a clean target aspect ratio (1.05 for slightly rounded landscape square)
    double targetRatio = 1.05; // width / height

    double tileWidth = maxTileWidth;
    double tileHeight = tileWidth / targetRatio;

    // If tile height exceeds max height allowed by container, scale tile size down based on height
    if (tileHeight > maxTileHeight) {
      tileHeight = maxTileHeight;
      tileWidth = tileHeight * targetRatio;
    }

    // Build rows of tiles
    List<Widget> rowWidgets = [];
    for (int r = 0; r < rows; r++) {
      List<Widget> rowTiles = [];
      for (int c = 0; c < cols; c++) {
        int index = r * cols + c;
        if (index < count) {
          rowTiles.add(
            SizedBox(
              width: tileWidth,
              height: tileHeight,
              child: tiles[index],
            ),
          );
        }
      }

      rowWidgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : spacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowTiles.map((t) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: t,
              );
            }).toList(),
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: rowWidgets,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Leave Call?',
            style: GoogleFonts.outfit(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to leave the call? Your GD feedback report will be generated for recorded turns.',
          style:
              GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _endSession(context);
            },
            child: const Text('Leave & View Report'),
          ),
        ],
      ),
    );
  }
}
