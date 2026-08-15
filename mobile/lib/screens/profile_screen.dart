import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/auth_provider.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/providers/locale_provider.dart';
import 'package:fluentsoul_mobile/providers/theme_provider.dart';
import 'package:fluentsoul_mobile/screens/history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final gd = context.watch<GDProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    final user = auth.currentUser;
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? AppTheme.background : AppTheme.lightBackground;
    final cardBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final headingColor = isDark ? AppTheme.textMain : AppTheme.textMainLight;
    final subtitleColor = isDark ? AppTheme.textMuted : AppTheme.textMutedLight;

    final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: headingColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'User Profile',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: headingColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        initial,
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Fluent Practitioner',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: headingColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // App & Practice Language Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRACTICE & APP LANGUAGE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: localeProvider.languageString,
                        isExpanded: true,
                        dropdownColor: cardBg,
                        icon: const Icon(Icons.translate_rounded, color: AppTheme.primary),
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            localeProvider.setLanguageString(val);
                            context.read<GDProvider>().fetchTopics(language: val);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'Hinglish',
                            child: Text('🇮🇳 Hinglish (Hindi + English)'),
                          ),
                          DropdownMenuItem(
                            value: 'Hindi',
                            child: Text('🇮🇳 Hindi (हिंदी)'),
                          ),
                          DropdownMenuItem(
                            value: 'English',
                            child: Text('🌐 Pure English'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Learner Track Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEARNER TRACK',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: gd.activeTrack,
                        isExpanded: true,
                        dropdownColor: cardBg,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            gd.setActiveTrack(val);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'A',
                            child: Text('Track A · Unfreeze & Confidence'),
                          ),
                          DropdownMenuItem(
                            value: 'B',
                            child: Text('Track B · From Scratch Beginner'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Progress Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEARNING PROGRESS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: subtitleColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildProgressStat(
                            icon: '🔥',
                            title: 'Streak',
                            value: '${gd.streakDays} Days',
                            cardBg: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            headingColor: headingColor,
                            subtitleColor: subtitleColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildProgressStat(
                            icon: '🏆',
                            title: 'Current Unit',
                            value: 'Unit ${gd.currentPathDay}',
                            cardBg: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            headingColor: headingColor,
                            subtitleColor: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Options List
              Material(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.history_rounded, color: AppTheme.primary),
                        title: Text('Session History', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: headingColor)),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                        },
                      ),
                      Divider(height: 1, color: borderColor),
                      ListTile(
                        leading: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppTheme.primary),
                        title: Text('Dark Theme', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: headingColor)),
                        trailing: Switch(
                          value: isDark,
                          activeColor: AppTheme.primary,
                          onChanged: (val) => themeProvider.toggleTheme(val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.12),
                    elevation: 0,
                    side: const BorderSide(color: Colors.red, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                  label: Text(
                    'Logout Account',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStat({
    required String icon,
    required String title,
    required String value,
    required Color cardBg,
    required Color headingColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: headingColor)),
        ],
      ),
    );
  }
}
