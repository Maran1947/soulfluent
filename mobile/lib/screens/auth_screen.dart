import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/config/theme.dart';
import 'package:fluentsoul_mobile/providers/auth_provider.dart';
import 'package:fluentsoul_mobile/providers/theme_provider.dart';
import 'package:fluentsoul_mobile/widgets/logo_widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'you@example.com');
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    bool success = false;

    if (isLogin) {
      success = await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await auth.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In selected. Connecting...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password reset link sent to your email.'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final cardBgColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textMainColor = isDark ? AppTheme.textMain : AppTheme.textMainLight;
    final textMutedColor =
        isDark ? AppTheme.textMuted : AppTheme.textMutedLight;
    final borderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    final inputBgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA);

    return Scaffold(
      body: Stack(
        children: [
          // Elegant Background Waves
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundWavesPainter(
                color: AppTheme.primary,
                isDark: isDark,
              ),
            ),
          ),

          // Main Scrollable Area
          SafeArea(
            child: Column(
              children: [
                // Top Header Row with Theme Toggle Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand text indicator matching the screenshot (Soul in dark, Fluent in coral)
                      FluentSoulBrandText(
                        fontSize: 20,
                        isDark: isDark,
                      ),
                      // Moon / Sun Theme toggle icon button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isDark
                                ? Icons.wb_sunny_outlined
                                : Icons.nightlight_round_outlined,
                            size: 20,
                            color: textMainColor,
                          ),
                          onPressed: () => themeProvider.toggleTheme(!isDark),
                          tooltip: 'Toggle Theme',
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Scrollable Card
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 440),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.borderDark
                                : const Color(0xFFF1F5F9),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(isDark ? 0.35 : 0.08),
                              blurRadius: 30,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Logo Icon
                            const Center(
                              child: FluentSoulLogo(size: 58),
                            ),

                            const SizedBox(height: 20),

                            // 2. Welcome Title
                            Text(
                              isLogin ? 'Welcome back' : 'Create your account',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textMainColor,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Subtitle
                            Text(
                              isLogin
                                  ? 'Continue your fluency journey'
                                  : 'Start your spoken English journey today',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: textMutedColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // 3. Form Inputs
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Register Full Name Field
                                  if (!isLogin) ...[
                                    _buildInputLabel(
                                        'Full Name', textMainColor),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _nameController,
                                      style: GoogleFonts.inter(
                                          color: textMainColor, fontSize: 14),
                                      decoration: _buildInputDecoration(
                                        hintText: 'John Doe',
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                        inputBgColor: inputBgColor,
                                        borderColor: borderColor,
                                        textMutedColor: textMutedColor,
                                      ),
                                      validator: (val) =>
                                          val == null || val.trim().isEmpty
                                              ? 'Please enter your full name'
                                              : null,
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Email Field
                                  _buildInputLabel(
                                      'Email address', textMainColor),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.inter(
                                        color: textMainColor, fontSize: 14),
                                    decoration: _buildInputDecoration(
                                      hintText: 'you@example.com',
                                      prefixIcon: Icons.email_outlined,
                                      inputBgColor: inputBgColor,
                                      borderColor: borderColor,
                                      textMutedColor: textMutedColor,
                                    ),
                                    validator: (val) => val == null ||
                                            !val.contains('@')
                                        ? 'Please enter a valid email address'
                                        : null,
                                  ),

                                  const SizedBox(height: 16),

                                  // Password Field
                                  _buildInputLabel('Password', textMainColor),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: GoogleFonts.inter(
                                        color: textMainColor, fontSize: 14),
                                    decoration: _buildInputDecoration(
                                      hintText: 'Enter your password',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      inputBgColor: inputBgColor,
                                      borderColor: borderColor,
                                      textMutedColor: textMutedColor,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 19,
                                          color: textMutedColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (val) => val == null ||
                                            val.length < 6
                                        ? 'Password must be at least 6 characters'
                                        : null,
                                  ),

                                  if (isLogin) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: _handleForgotPassword,
                                        child: Text(
                                          'Forgot password?',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Error Message Banner
                            if (auth.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.redAccent.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        size: 18, color: Colors.redAccent),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        auth.errorMessage!,
                                        style: GoogleFonts.inter(
                                          color: Colors.redAccent,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // 4. Primary Button: Log in to FluentSoul ->
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isLogin
                                                ? 'Log in to FluentSoul'
                                                : 'Create account',
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 5. "or continue with" Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: borderColor,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  child: Text(
                                    'or continue with',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: textMutedColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: borderColor,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // 6. Google Sign-In Button
                            SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _handleGoogleLogin,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  foregroundColor: textMainColor,
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const GoogleLogoIcon(size: 19),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textMainColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 7. Footer Toggle: Don't have an account? Sign up
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isLogin = !isLogin;
                                  });
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: textMutedColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: isLogin
                                            ? "Don't have an account? "
                                            : "Already have an account? ",
                                      ),
                                      TextSpan(
                                        text: isLogin ? 'Sign up' : 'Log in',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text, Color textColor) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required Color inputBgColor,
    required Color borderColor,
    required Color textMutedColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        color: textMutedColor.withOpacity(0.7),
        fontSize: 14,
      ),
      filled: true,
      fillColor: inputBgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: Icon(prefixIcon, size: 20, color: textMutedColor),
      suffixIcon: suffixIcon,
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
    );
  }
}
