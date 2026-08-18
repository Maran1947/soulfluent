import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/l10n/app_localizations.dart';
import 'package:fluentsoul_mobile/providers/auth_provider.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/providers/locale_provider.dart';
import 'package:fluentsoul_mobile/providers/onboarding_provider.dart';
import 'package:fluentsoul_mobile/screens/daily_speak_screen.dart';
import 'package:fluentsoul_mobile/screens/path_screen.dart';
import 'package:fluentsoul_mobile/widgets/app_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0; // 0 = 30-Day Path, 1 = Free Practice GD & Debate
  int currentStep = 1; // 1 to 4

  String selectedMode = 'gd'; // 'gd' or 'debate'
  String selectedDebateOpponent = 'alex'; // 'alex', 'emily', 'rohan', 'riya'
  List<String> selectedGdPartners = ['rohan', 'riya'];

  void _toggleGdPartner(String key) {
    setState(() {
      if (selectedGdPartners.contains(key)) {
        if (selectedGdPartners.length > 1) {
          selectedGdPartners.remove(key);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least 1 AI voice partner'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        selectedGdPartners.add(key);
      }
    });
  }

  String selectedCategory = 'current_affairs';
  String selectedTopic = 'AI replacement of jobs';
  String selectedDifficulty = 'intermediate';

  final TextEditingController _customTopicController = TextEditingController();

  final List<Map<String, String>> debateOpponents = [
    {
      'key': 'alex',
      'name': 'Alex',
      'title': 'Analytical Contrarian',
      'flag': '🇺🇸',
      'desc': 'Direct & inquisitive, pushes back with sharp counter-arguments.',
    },
    {
      'key': 'emily',
      'name': 'Emily',
      'title': 'Sharp Orator',
      'flag': '🇺🇸',
      'desc': 'Dynamic & eloquent, challenges assumptions with high clarity.',
    },
    {
      'key': 'rohan',
      'name': 'Rohan',
      'title': 'Structured Strategist',
      'flag': '🇮🇳',
      'desc': 'Methodical & logical, tests real-world business frameworks.',
    },
    {
      'key': 'riya',
      'name': 'Riya',
      'title': 'Empathetic Peacemaker',
      'flag': '🇮🇳',
      'desc': 'Articulate & bridging, tests nuanced counter-perspectives.',
    },
  ];

  final ScrollController _stepperScrollController = ScrollController();
  final GlobalKey _stepperContainerKey = GlobalKey();
  final List<GlobalKey> _stepKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = context.read<LocaleProvider>().languageString;
      context.read<GDProvider>().fetchTopics(language: lang);
      _scrollToStep(currentStep);
    });
  }

  @override
  void dispose() {
    _customTopicController.dispose();
    _stepperScrollController.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    final topic = _customTopicController.text.trim().isNotEmpty
        ? _customTopicController.text.trim()
        : selectedTopic;

    final gd = context.read<GDProvider>();

    final personaKeys = selectedMode == 'debate'
        ? [selectedDebateOpponent]
        : selectedGdPartners;

    final success = await gd.startSession(
      topic: topic,
      category: selectedCategory,
      difficulty: selectedDifficulty,
      personaKeys: personaKeys,
    );

    if (success && mounted) {
      Navigator.pushNamed(context, '/arena');
    }
  }

  void _scrollToStep(int stepNum) {
    if (!_stepperScrollController.hasClients) return;
    final index = (stepNum - 1).clamp(0, 3);
    final keyContext = _stepKeys[index].currentContext;
    final containerContext = _stepperContainerKey.currentContext;

    if (keyContext != null && containerContext != null) {
      final itemBox = keyContext.findRenderObject() as RenderBox?;
      final containerBox = containerContext.findRenderObject() as RenderBox?;

      if (itemBox != null && containerBox != null) {
        final itemPos = itemBox.localToGlobal(Offset.zero);
        final containerPos = containerBox.localToGlobal(Offset.zero);
        final itemWidth = itemBox.size.width;
        final containerWidth = containerBox.size.width;

        final itemRelativeX =
            itemPos.dx - containerPos.dx + _stepperScrollController.offset;
        final itemCenterX = itemRelativeX + (itemWidth / 2);
        final targetOffset = itemCenterX - (containerWidth / 2);

        final clampedOffset = targetOffset.clamp(
          0.0,
          _stepperScrollController.position.maxScrollExtent,
        );

        _stepperScrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _setStep(int newStep) {
    setState(() {
      currentStep = newStep;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStep(newStep);
    });
  }

  void _nextStep() {
    if (currentStep < 4) {
      _setStep(currentStep + 1);
    } else {
      _startSession();
    }
  }

  void _prevStep() {
    if (currentStep > 1) {
      _setStep(currentStep - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final gd = context.watch<GDProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!onboarding.isOnboarded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      });
      return Scaffold(
        backgroundColor: isDark ? AppTheme.background : AppTheme.lightBackground,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final cardBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final headingColor = isDark ? AppTheme.textMain : AppTheme.textMainLight;
    final subtitleColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    return Scaffold(
      appBar: _activeTab == 1 ? const AppHeader(title: 'FluentSoul') : null,
      backgroundColor: isDark ? AppTheme.background : AppTheme.lightBackground,
      body: IndexedStack(
        index: _activeTab,
        children: [
          const PathScreen(),
          SafeArea(
            child: Column(
              children: [
                // Top Stepper Navigation Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: _buildStepperHeader(isDark, cardBg, borderColor,
                      headingColor, subtitleColor, l10n),
                ),

                // Step Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dynamic Step Body
                        if (currentStep == 1)
                          _buildStep1PracticeMode(isDark, headingColor,
                              subtitleColor, borderColor, l10n)
                        else if (currentStep == 2)
                          _buildStep2Topic(isDark, headingColor, subtitleColor,
                              borderColor, cardBg, gd, l10n)
                        else if (currentStep == 3)
                          _buildStep3VoicePartners(isDark, headingColor,
                              subtitleColor, borderColor, cardBg, gd, l10n)
                        else
                          _buildStep4Launch(isDark, headingColor, subtitleColor,
                              borderColor, cardBg, l10n),

                        const SizedBox(height: 20),

                        // Navigation Buttons Footer (Back / Continue)
                        if (currentStep == 1)
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFA5A3A), Color(0xFFFF4B72)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFA5A3A).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: gd.isLoading ? null : _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n?.next ?? "Continue",
                                    style: GoogleFonts.outfit(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded,
                                      size: 18, color: Colors.white),
                                ],
                              ),
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _prevStep,
                                icon: const Icon(Icons.arrow_back_rounded,
                                    size: 16),
                                label: Text(
                                  l10n?.back ?? 'Back',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: headingColor,
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 12),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: gd.isLoading ? null : _nextStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                ),
                                child: gd.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            currentStep == 4
                                                ? (selectedMode == 'debate'
                                                    ? (l10n?.start_debate ??
                                                        'Start Karein')
                                                    : (l10n?.start_discussion ??
                                                        'Start Karein'))
                                                : (l10n?.next ?? 'Continue'),
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            currentStep == 4
                                                ? Icons.rocket_launch_rounded
                                                : Icons.arrow_forward_rounded,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const DailySpeakScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeTab,
        backgroundColor: cardBg,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: subtitleColor,
        selectedLabelStyle:
            GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _activeTab = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.alt_route_rounded),
            label: l10n?.tab_path ?? 'Fluency Track',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.stadium_rounded),
            label: l10n?.tab_practice ?? 'Arena',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.mic_rounded),
            label: 'Speak Daily',
          ),
        ],
      ),
    );
  }

  /// 1. Stepper Header Progress Bar
  Widget _buildStepperHeader(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color headingColor,
    Color subtitleColor,
    AppLocalizations? l10n,
  ) {
    final steps = [
      {'num': 1, 'title': 'Mode'},
      {'num': 2, 'title': 'Topic'},
      {'num': 3, 'title': 'AI Setup'},
      {'num': 4, 'title': 'Ready'},
    ];

    return Container(
      key: _stepperContainerKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : borderColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: steps.map((s) {
          final stepNum = s['num'] as int;
          final isActive = currentStep == stepNum;
          final isCompleted = currentStep > stepNum;

          return GestureDetector(
            key: _stepKeys[stepNum - 1],
            onTap: () => _setStep(stepNum),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFA5A3A).withOpacity(0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFFFA5A3A)
                          : (isCompleted
                              ? const Color(0xFFFA5A3A)
                              : (isDark
                                  ? const Color(0xFF231B3D)
                                  : const Color(0xFFE2E8F0))),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check,
                              size: 12, color: Colors.white)
                          : Text(
                              '$stepNum',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.white
                                    : (isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B)),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s['title'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : (isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// STEP 1: Select Your Practice Mode
  Widget _buildStep1PracticeMode(
    bool isDark,
    Color headingColor,
    Color subtitleColor,
    Color borderColor,
    AppLocalizations? l10n,
  ) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(
          'Practice Mode',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select your preferred practice mode',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Group Discussion Card
        _buildGroupDiscussionCard(isDark, l10n),

        const SizedBox(height: 16),

        // 1:1 Debate Card
        _buildDebateCard(isDark, l10n),
      ],
    );
  }

  /// Card 1: GROUP DISCUSSION
  Widget _buildGroupDiscussionCard(bool isDark, AppLocalizations? l10n) {
    final isSelected = selectedMode == 'gd';

    return GestureDetector(
      onTap: () => setState(() => selectedMode = 'gd'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Left Illustration Image (group_discussion.png)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/group_discussion.png',
                width: 120,
                height: 105,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 105,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.groups_rounded,
                      size: 48, color: AppTheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Middle Info Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Group Discussion',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Practice with 2–4 AI participants in a realistic GD environment',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right Radio Circle Checkmark
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : (isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// Card 2: 1:1 DEBATE
  Widget _buildDebateCard(bool isDark, AppLocalizations? l10n) {
    final isSelected = selectedMode == 'debate';

    return GestureDetector(
      onTap: () => setState(() => selectedMode = 'debate'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.borderDark : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Left Illustration Image (debate.png)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/debate.png',
                width: 120,
                height: 105,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 120,
                  height: 105,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.record_voice_over_rounded,
                      size: 48, color: AppTheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Middle Info Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1:1 Debate',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Face a dedicated opponent who challenges your arguments directly',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right Radio Circle Checkmark
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : (isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// STEP 2: Choose Topic / Prompt
  Widget _buildStep2Topic(
    bool isDark,
    Color headingColor,
    Color subtitleColor,
    Color borderColor,
    Color cardBg,
    GDProvider gd,
    AppLocalizations? l10n,
  ) {
    final topicsMap = gd.topics;
    final categoryList = topicsMap[selectedCategory] as List<dynamic>? ?? [];

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose Topic or Prompt',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select a trending category or enter your custom discussion topic',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: (topicsMap.keys.isNotEmpty
                    ? topicsMap.keys.toList()
                    : ['current_affairs', 'tech', 'business', 'education'])
                .map((catKey) {
              final label = catKey
                  .replaceAll('_', ' ')
                  .split(' ')
                  .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
                  .join(' ');
              IconData iconData = Icons.public;
              if (catKey.contains('tech')) iconData = Icons.memory;
              if (catKey.contains('bus')) iconData = Icons.work;
              if (catKey.contains('edu')) iconData = Icons.school;

              return _buildCategoryChip(catKey, label, iconData, isDark);
            }).toList(),
          ),
        ),

        const SizedBox(height: 18),

        // Topics Selection Cards
        if (categoryList.isNotEmpty)
          Column(
            children: categoryList.map((t) {
              final topicStr = t.toString();
              final isSelected = selectedTopic == topicStr &&
                  _customTopicController.text.isEmpty;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTopic = topicStr;
                    _customTopicController.clear();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(0.12)
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFFAFAFA)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : borderColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          topicStr,
                          style: GoogleFonts.inter(
                            color: isSelected ? AppTheme.primary : headingColor,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.primary, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 12),

        // Custom Topic Input Field
        TextFormField(
          controller: _customTopicController,
          onChanged: (val) => setState(() {}),
          style: GoogleFonts.inter(color: headingColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Or enter custom prompt / motion...',
            hintStyle: GoogleFonts.inter(color: subtitleColor, fontSize: 13),
            prefixIcon: Icon(Icons.edit_note_rounded, color: subtitleColor),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  /// STEP 3: Select AI Voice Partners
  Widget _buildStep3VoicePartners(
    bool isDark,
    Color headingColor,
    Color subtitleColor,
    Color borderColor,
    Color cardBg,
    GDProvider gd,
    AppLocalizations? l10n,
  ) {
    final isDebate = selectedMode == 'debate';
    final dynamicOpponents = gd.personas.isNotEmpty
        ? gd.personas.values
            .map((p) => {
                  'key': p.key,
                  'name': p.name,
                  'title': p.sub,
                  'flag': p.flag.isNotEmpty ? p.flag : '🌐',
                  'desc': 'AI Voice Partner (${p.sub})',
                })
            .toList()
        : debateOpponents;

    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isDebate ? 'Select AI Debate Opponent' : 'Select AI Voice Partners',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isDebate
              ? 'Choose your AI opponent for 1:1 structured rebuttal'
              : 'Tap to select 1 or more AI voice partners for your discussion',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        Column(
          children: dynamicOpponents.map((opp) {
            final key = opp['key']!;
            final isSelected = isDebate
                ? selectedDebateOpponent == key
                : selectedGdPartners.contains(key);

            return _buildVoicePartnerCard(
              opp: opp,
              isSelected: isSelected,
              isDark: isDark,
              headingColor: headingColor,
              subtitleColor: subtitleColor,
              borderColor: borderColor,
              onTap: () {
                if (isDebate) {
                  setState(() => selectedDebateOpponent = key);
                } else {
                  _toggleGdPartner(key);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVoicePartnerCard({
    required Map<String, String> opp,
    required bool isSelected,
    required bool isDark,
    required Color headingColor,
    required Color subtitleColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.08)
              : (isDark ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(opp['flag']!, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: opp['name']!,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isSelected ? AppTheme.primary : headingColor,
                          ),
                        ),
                        TextSpan(
                          text: ' · ${opp['title']}',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    opp['desc']!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: subtitleColor.withOpacity(0.85),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? AppTheme.primary
                  : subtitleColor.withOpacity(0.3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  /// STEP 4: Setup & Launch
  Widget _buildStep4Launch(
    bool isDark,
    Color headingColor,
    Color subtitleColor,
    Color borderColor,
    Color cardBg,
    AppLocalizations? l10n,
  ) {
    final finalTopic = _customTopicController.text.trim().isNotEmpty
        ? _customTopicController.text.trim()
        : selectedTopic;

    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Setup & Launch Session',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Review session configuration and select your difficulty level',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Difficulty Option Selector
        Text(
          'Difficulty Level',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, fontSize: 14, color: headingColor),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildDifficultyChip('beginner', 'Beginner', isDark, borderColor),
            const SizedBox(width: 8),
            _buildDifficultyChip(
                'intermediate', 'Intermediate', isDark, borderColor),
            const SizedBox(width: 8),
            _buildDifficultyChip('advanced', 'Advanced', isDark, borderColor),
          ],
        ),

        const SizedBox(height: 22),

        // Final Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session Overview',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const Divider(height: 18),
              _buildSummaryLine(
                  'Mode',
                  selectedMode == 'debate' ? '1:1 Debate' : 'Group Discussion',
                  headingColor,
                  subtitleColor),
              const SizedBox(height: 6),
              _buildSummaryLine(
                  'Topic', finalTopic, headingColor, subtitleColor),
              const SizedBox(height: 6),
              _buildSummaryLine(
                'AI Partner(s)',
                selectedMode == 'debate'
                    ? selectedDebateOpponent.toUpperCase()
                    : 'Rohan & Riya',
                headingColor,
                subtitleColor,
              ),
              const SizedBox(height: 6),
              _buildSummaryLine('Difficulty', selectedDifficulty.toUpperCase(),
                  headingColor, subtitleColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryLine(
      String label, String value, Color mainColor, Color mutedColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 13, color: mutedColor, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 13, color: mainColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
      String key, String label, IconData icon, bool isDark) {
    final isSelected = selectedCategory == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = key;
          final catList =
              context.read<GDProvider>().topics[key] as List<dynamic>?;
          if (catList != null && catList.isNotEmpty) {
            selectedTopic = catList.first.toString();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 15,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF475569))),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(
      String key, String label, bool isDark, Color borderColor) {
    final isSelected = selectedDifficulty == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedDifficulty = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withOpacity(0.15)
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppTheme.primary : borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? AppTheme.primary
                    : (isDark ? AppTheme.textMuted : AppTheme.textMutedLight),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
