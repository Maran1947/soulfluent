import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/models/curriculum.dart';
import 'package:fluentsoul_mobile/widgets/activities/lesson_activity_widget.dart';
import 'package:fluentsoul_mobile/widgets/activities/echo_activity_widget.dart';
import 'package:fluentsoul_mobile/widgets/activities/forming_sentence_activity_widget.dart';
import 'package:fluentsoul_mobile/widgets/activities/express_image_activity_widget.dart';
import 'package:fluentsoul_mobile/widgets/activities/free_response_activity_widget.dart';
import 'package:fluentsoul_mobile/widgets/activities/roleplay_activity_widget.dart';

class ActivityRunnerScreen extends StatefulWidget {
  final TrackNode node;
  final int initialIndex;

  const ActivityRunnerScreen({
    super.key,
    required this.node,
    this.initialIndex = 0,
  });

  @override
  State<ActivityRunnerScreen> createState() => _ActivityRunnerScreenState();
}

class _ActivityRunnerScreenState extends State<ActivityRunnerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isNodeFinished = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextActivity() {
    final activities = widget.node.activities;
    if (_currentIndex < activities.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _isNodeFinished = true);
    }
  }

  Widget _buildActivityContent(TrackActivity act) {
    final type = act.type.toLowerCase();

    if (type.contains('lesson')) {
      return LessonActivityWidget(
        activity: act,
        node: widget.node,
        onCompleted: _nextActivity,
      );
    } else if (type.contains('echo') || type.contains('listen')) {
      return EchoActivityWidget(
        activity: act,
        node: widget.node,
        onCompleted: _nextActivity,
      );
    } else if (type.contains('sentence') || type.contains('forming') || type.contains('production')) {
      return FormingSentenceActivityWidget(
        activity: act,
        node: widget.node,
        onCompleted: _nextActivity,
      );
    } else if (type.contains('image')) {
      return ExpressImageActivityWidget(
        activity: act,
        node: widget.node,
        onCompleted: _nextActivity,
      );
    } else if (type.contains('free') || type.contains('response') || type.contains('speech')) {
      return FreeResponseActivityWidget(
        activity: act,
        node: widget.node,
        onCompleted: _nextActivity,
      );
    } else if (type.contains('roleplay') || type.contains('debate')) {
      return RoleplayActivityWidget(
        activity: act,
        node: widget.node,
        onCompleted: _nextActivity,
      );
    }

    // Default Fallback
    return LessonActivityWidget(
      activity: act,
      node: widget.node,
      onCompleted: _nextActivity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC);
    final headingColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final activities = widget.node.activities.isNotEmpty
        ? widget.node.activities
        : [
            TrackActivity(
              id: '1',
              sequence: 1,
              title: 'Learn in Context',
              type: 'lesson',
              config: const {'instruction': 'Learn core expressions'},
            ),
          ];

    if (_isNodeFinished) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🎉', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Unit Completed!',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: headingColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'You finished all ${activities.length} activities for ${widget.node.theme}. Keep building fluency!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: subtitleColor,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          '+50 Fluency XP Earned',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Return to Path',
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
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: headingColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unit ${widget.node.unit} · ${widget.node.theme}',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Activity ${_currentIndex + 1} of ${activities.length}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: List.generate(activities.length, (idx) {
                  final isDone = idx < _currentIndex;
                  final isCurrent = idx == _currentIndex;

                  return Expanded(
                    child: Container(
                      height: 5,
                      margin: EdgeInsets.only(
                          right: idx == activities.length - 1 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: isDone || isCurrent
                            ? AppTheme.primary
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // PageView of Activities
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  return _buildActivityContent(activities[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
