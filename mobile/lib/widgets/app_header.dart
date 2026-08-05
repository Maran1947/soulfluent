import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soulfluent_mobile/providers/auth_provider.dart';
import 'package:soulfluent_mobile/providers/theme_provider.dart';

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
    final themeProvider = context.read<ThemeProvider>();
    final user = auth.currentUser;
    final isDark = themeProvider.isDarkMode;

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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: currentIsDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
                      color: currentIsDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
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
                          user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
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
                                color: currentIsDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: currentIsDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: currentIsDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  const SizedBox(height: 12),

                  // Session History Link
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: const Icon(Icons.history, color: Color(0xFFF25C40)),
                    title: Text(
                      'Session History',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: currentIsDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/history');
                    },
                  ),

                  // Theme Toggle Switch
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: Icon(
                      currentIsDark ? Icons.dark_mode : Icons.light_mode,
                      color: const Color(0xFFF59E0B),
                    ),
                    title: Text(
                      'Theme',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: currentIsDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      currentIsDark ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(
                        fontSize: 12,
                        color: currentIsDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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

                  const SizedBox(height: 8),
                  Divider(color: currentIsDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),

                  // Logout
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
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

                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (showBack) ...[
            IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              onPressed: onBack ?? () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
          ],
          // SoulFluent Brand Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFA5A3A), Color(0xFFF25C40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 2, height: 10, color: Colors.white),
                const SizedBox(width: 2),
                Container(width: 2, height: 16, color: Colors.white),
                const SizedBox(width: 2),
                Container(width: 2, height: 12, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Soul',
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
                TextSpan(
                  text: 'Fluent',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
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
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
