import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/l10n/app_localizations.dart';
import 'package:fluentsoul_mobile/providers/auth_provider.dart';
import 'package:fluentsoul_mobile/screens/profile_screen.dart';
import 'package:fluentsoul_mobile/widgets/logo_widgets.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? action;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.action,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  void _showProfileModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  Widget _buildGreetingHeaderWidget(BuildContext context, String? userName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    final firstName = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim().split(' ')[0]
        : 'Practitioner';
    final timeGreeting = hour < 12
        ? (l10n?.good_morning ?? 'Good Morning')
        : (hour < 17
            ? (l10n?.good_afternoon ?? 'Good Afternoon')
            : (l10n?.good_evening ?? 'Good Evening'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$timeGreeting, ',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFA5A3A),
                ),
              ),
              Text(
                firstName,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 3),
              const Text(
                '👋',
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Text(
          l10n?.keep_showing_up ?? "Keep showing up",
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final gd = context.watch<GDProvider>();
    final user = auth.currentUser;

    final isDefaultGreeting = (title.isEmpty || title == 'FluentSoul');

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: isDefaultGreeting ? 64 : 56,
      title: Row(
        children: [
          if (showBack) ...[
            IconButton(
              icon: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : const Color(0xFF0F172A)),
              onPressed: onBack ?? () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
          ],
          const FluentSoulLogo(size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: isDefaultGreeting
                ? _buildGreetingHeaderWidget(context, user?.name)
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFA5A3A), Color(0xFFF25C40)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),

          // Streak Badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '${gd.streakDays}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Action or User Avatar
          if (action != null)
            action!
          else if (user != null)
            GestureDetector(
              onTap: () => _showProfileModal(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF25C40),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
