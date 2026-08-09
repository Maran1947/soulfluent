import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/auth_provider.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/screens/challenges_screen.dart';
import 'package:fluentsoul_mobile/screens/path_screen.dart';
import 'package:fluentsoul_mobile/widgets/app_header.dart';
import 'package:fluentsoul_mobile/widgets/logo_widgets.dart';

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
      context.read<GDProvider>().fetchTopics();
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
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Stack(
            children: [
              // Ambient Waves Background
              Positioned.fill(
                child: CustomPaint(
                  painter: BackgroundWavesPainter(
                    color: AppTheme.primary,
                    isDark: isDark,
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // Top Welcome & Stepper Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Column(
                        children: [
                          // User Greeting Subtitle
                          Row(
                            children: [
                              Text(
                                'Welcome, ${user?.name ?? 'Practitioner'} 👋',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: headingColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Stepper Navigation Header Card (1 Practice Mode | 2 Topic / Prompt | 3 AI Voice Partners | 4 Setup & Launch)
                          _buildStepperHeader(isDark, cardBg, borderColor,
                              headingColor, subtitleColor),
                        ],
                      ),
                    ),

                    // Step Content Card
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 520),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isDark ? 0.3 : 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Step Indicator Badge ("✨ Step X of 4")
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBE5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '✨ Step $currentStep of 4',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Dynamic Step Body
                              if (currentStep == 1)
                                _buildStep1PracticeMode(isDark, headingColor,
                                    subtitleColor, borderColor)
                              else if (currentStep == 2)
                                _buildStep2Topic(isDark, headingColor,
                                    subtitleColor, borderColor, cardBg, gd)
                              else if (currentStep == 3)
                                _buildStep3VoicePartners(isDark, headingColor,
                                    subtitleColor, borderColor, cardBg)
                              else
                                _buildStep4Launch(isDark, headingColor,
                                    subtitleColor, borderColor, cardBg),

                              const SizedBox(height: 24),

                              // Navigation Buttons Footer (Back / Continue)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (currentStep > 1)
                                    OutlinedButton.icon(
                                      onPressed: _prevStep,
                                      icon: const Icon(Icons.arrow_back_rounded,
                                          size: 16),
                                      label: Text(
                                        'Back',
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: headingColor,
                                        side: BorderSide(color: borderColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 12),
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
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
                                                    ? 'Start Session'
                                                    : 'Continue',
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(
                                                currentStep == 4
                                                    ? Icons
                                                        .rocket_launch_rounded
                                                    : Icons
                                                        .arrow_forward_rounded,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
          const ChallengesScreen(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.alt_route_rounded),
            label: 'Fluency Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stadium_rounded),
            label: 'Arena',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt_rounded),
            label: 'Challenges',
          ),
        ],
      ),
    );
  }

  /// 1. Stepper Header Progress Bar matching reference design
  Widget _buildStepperHeader(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color headingColor,
    Color subtitleColor,
  ) {
    final steps = [
      {'num': 1, 'title': 'Practice Mode'},
      {'num': 2, 'title': 'Topic / Prompt'},
      {'num': 3, 'title': 'AI Voice Partners'},
      {'num': 4, 'title': 'Setup & Launch'},
    ];

    return Container(
      key: _stepperContainerKey,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: _stepperScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: steps.map((s) {
            final stepNum = s['num'] as int;
            final isActive = currentStep == stepNum;
            final isCompleted = currentStep > stepNum;

            return GestureDetector(
              onTap: () => _setStep(stepNum),
              child: AnimatedContainer(
                key: _stepKeys[stepNum - 1],
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primary
                      : (isCompleted
                          ? AppTheme.primary.withOpacity(0.12)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? Colors.white
                            : (isCompleted
                                ? AppTheme.primary
                                : subtitleColor.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : Text(
                                '$stepNum',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? AppTheme.primary
                                      : subtitleColor,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : (isCompleted ? AppTheme.primary : subtitleColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// STEP 1: Select Your Practice Mode (Group Discussion vs 1:1 Debate)
  Widget _buildStep1PracticeMode(
    bool isDark,
    Color headingColor,
    Color subtitleColor,
    Color borderColor,
  ) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Your Practice Mode',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose between group discussion with multiple AI peers or sharp 1:1 debate',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // Group Discussion Card (Selected State in Screenshot)
        _buildModeOptionCard(
          keyName: 'gd',
          title: 'Group Discussion',
          description:
              'Multi-persona room with AI peers & moderator. Practice natural turn-taking & group dynamics.',
          icon: Icons.groups_rounded,
          iconBgColor: const Color(0xFFFFEBE5),
          iconColor: AppTheme.primary,
          isDark: isDark,
          borderColor: borderColor,
        ),

        const SizedBox(height: 16),

        // 1:1 Debate Card
        _buildModeOptionCard(
          keyName: 'debate',
          title: '1:1 Debate',
          description:
              'Direct argument & counter-rebuttal challenge with 1 AI opponent. Sharpen logic under pressure.',
          icon: Icons.record_voice_over_rounded,
          iconBgColor: const Color(0xFFEEF2FF),
          iconColor: const Color(0xFF6366F1),
          isDark: isDark,
          borderColor: borderColor,
        ),
      ],
    );
  }

  /// Card item for Step 1 Practice Mode
  Widget _buildModeOptionCard({
    required String keyName,
    required String title,
    required String description,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isDark,
    required Color borderColor,
  }) {
    final isSelected = selectedMode == keyName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = keyName;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppTheme.primary.withOpacity(0.15)
                  : const Color(0xFFFFF7F5))
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Squircle Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),

                // Selected Pill Badge
                if (isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, size: 13, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Selected',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                height: 1.4,
              ),
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
            children: [
              _buildCategoryChip(
                  'current_affairs', 'Current Affairs', Icons.public, isDark),
              _buildCategoryChip('tech', 'Technology', Icons.memory, isDark),
              _buildCategoryChip('business', 'Business', Icons.work, isDark),
              _buildCategoryChip(
                  'education', 'Education', Icons.school, isDark),
            ],
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
  ) {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          selectedMode == 'debate'
              ? 'Select AI Debate Opponent'
              : 'Select AI Voice Partners',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          selectedMode == 'debate'
              ? 'Choose your AI opponent for 1:1 structured rebuttal'
              : 'Tap to select 1 or more AI voice partners for your discussion',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        if (selectedMode == 'debate')
          Column(
            children: debateOpponents.map((opp) {
              final isSelected = selectedDebateOpponent == opp['key'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDebateOpponent = opp['key']!;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(0.12)
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFFAFAFA)),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(opp['flag']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${opp['name']} · ${opp['title']}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isSelected
                                    ? AppTheme.primary
                                    : headingColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              opp['desc']!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected
                            ? AppTheme.primary
                            : subtitleColor.withOpacity(0.4),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        else ...[
          Column(
            children: debateOpponents.map((opp) {
              final isSelected = selectedGdPartners.contains(opp['key']);

              return GestureDetector(
                onTap: () => _toggleGdPartner(opp['key']!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(0.12)
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFFAFAFA)),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(opp['flag']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${opp['name']} · ${opp['title']}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isSelected
                                    ? AppTheme.primary
                                    : headingColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              opp['desc']!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        color: isSelected
                            ? AppTheme.primary
                            : subtitleColor.withOpacity(0.4),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFF7F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy_rounded,
                    color: AppTheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Group Moderator Included',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: headingColor,
                        ),
                      ),
                      Text(
                        'Automated turn-taking & performance analytics',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// STEP 4: Setup & Launch
  Widget _buildStep4Launch(
    bool isDark,
    Color headingColor,
    Color subtitleColor,
    Color borderColor,
    Color cardBg,
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
