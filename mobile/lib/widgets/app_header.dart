import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/providers/auth_provider.dart';
import 'package:fluentsoul_mobile/providers/gd_provider.dart';
import 'package:fluentsoul_mobile/providers/theme_provider.dart';
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
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentIsDark = context.watch<ThemeProvider>().isDarkMode;

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: currentIsDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: currentIsDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: currentIsDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User Info Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFF25C40),
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Practitioner',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: currentIsDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: currentIsDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(
                      color: currentIsDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),

                  // Session History Link
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      leading:
                          const Icon(Icons.history, color: Color(0xFFF25C40)),
                      title: Text(
                        'Session History',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: currentIsDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, '/history');
                      },
                    ),
                  ),

                  // Learner Track Setting Dropdown
                  Consumer<GDProvider>(
                    builder: (context, gd, _) {
                      final activeTrack = gd.activeTrack;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: currentIsDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: currentIsDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LEARNER TRACK',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: currentIsDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                letterSpacing: 0.05,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: activeTrack,
                                isExpanded: true,
                                dropdownColor: currentIsDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFFF25C40)),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: currentIsDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                                onChanged: (String? val) {
                                  if (val != null) {
                                    gd.setActiveTrack(val);
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: 'A',
                                    child: Text('Track A · Unfreeze (Default)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'B',
                                    child: Text('Track B · Scratch'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Theme Toggle Switch
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      leading: Icon(
                        currentIsDark ? Icons.dark_mode : Icons.light_mode,
                        color: const Color(0xFFF59E0B),
                      ),
                      title: Text(
                        'Theme',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: currentIsDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        currentIsDark ? 'Dark Mode' : 'Light Mode',
                        style: TextStyle(
                          fontSize: 12,
                          color: currentIsDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      trailing: Switch(
                        value: currentIsDark,
                        activeColor: const Color(0xFFF25C40),
                        onChanged: (val) {
                          context.read<ThemeProvider>().toggleTheme(val);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Divider(
                      color: currentIsDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),

                  // Logout
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      leading:
                          const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text(
                        'Log out',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.redAccent,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/auth');
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGreetingHeaderWidget(String? userName) {
    final hour = DateTime.now().hour;
    final firstName = (userName != null && userName.trim().isNotEmpty)
        ? userName.trim().split(' ')[0]
        : 'Practitioner';
    final timeGreeting = hour < 12
        ? 'Good Morning'
        : (hour < 17 ? 'Good Afternoon' : 'Good Evening');

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
                  color: Colors.white,
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
          "Keep showing up",
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
                ? _buildGreetingHeaderWidget(user?.name)
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
          const Spacer(),

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
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
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
