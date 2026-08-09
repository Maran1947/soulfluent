import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fluentsoul_mobile/config/theme.dart';

/// FluentSoul Audio Wave Logo Widget matching the design reference screenshot
class FluentSoulLogo extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color backgroundColor;
  final bool useAssetImage;

  const FluentSoulLogo({
    super.key,
    this.size = 58.0,
    this.primaryColor = AppTheme.primary,
    this.backgroundColor = const Color(0xFFFFEBE5),
    this.useAssetImage = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useAssetImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.32),
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildWaveFallback(),
        ),
      );
    }
    return _buildWaveFallback();
  }

  Widget _buildWaveFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBar(size * 0.22),
            SizedBox(width: size * 0.06),
            _buildBar(size * 0.42),
            SizedBox(width: size * 0.06),
            _buildBar(size * 0.54),
            SizedBox(width: size * 0.06),
            _buildBar(size * 0.38),
            SizedBox(width: size * 0.06),
            _buildBar(size * 0.24),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: size * 0.07,
      height: height,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(size * 0.035),
      ),
    );
  }
}

/// Custom Google 'G' Logo Icon Painter
class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({super.key, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final double scale = s / 24.0;
    canvas.scale(scale, scale);

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // 1. Blue Path (#4285F4)
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(22.56, 12.25)
      ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10.0)
      ..lineTo(12.0, 10.0)
      ..lineTo(12.0, 14.26)
      ..lineTo(17.92, 14.26)
      ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
      ..lineTo(15.71, 20.34)
      ..lineTo(19.28, 20.34)
      ..cubicTo(21.36, 18.42, 22.56, 15.6, 22.56, 12.25)
      ..close();
    canvas.drawPath(bluePath, paint);

    // 2. Green Path (#34A853)
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(12.0, 23.0)
      ..cubicTo(14.97, 23.0, 17.46, 22.02, 19.28, 20.34)
      ..lineTo(15.71, 17.57)
      ..cubicTo(14.73, 18.23, 13.48, 18.63, 12.0, 18.63)
      ..cubicTo(9.14, 18.63, 6.71, 16.7, 5.84, 14.1)
      ..lineTo(2.18, 14.1)
      ..lineTo(2.18, 16.94)
      ..cubicTo(3.99, 20.53, 7.7, 23.0, 12.0, 23.0)
      ..close();
    canvas.drawPath(greenPath, paint);

    // 3. Yellow Path (#FBBC05)
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(5.84, 14.09)
      ..cubicTo(5.62, 13.43, 5.49, 12.73, 5.49, 12.0)
      ..cubicTo(5.49, 11.27, 5.62, 10.57, 5.84, 9.91)
      ..lineTo(5.84, 7.07)
      ..lineTo(2.18, 7.07)
      ..cubicTo(1.43, 8.55, 1.0, 10.22, 1.0, 12.0)
      ..cubicTo(1.0, 13.78, 1.43, 15.45, 2.18, 16.93)
      ..lineTo(5.03, 14.71)
      ..lineTo(5.84, 14.09)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // 4. Red Path (#EA4335)
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(12.0, 5.38)
      ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
      ..lineTo(19.36, 3.87)
      ..cubicTo(17.45, 2.09, 14.97, 1.0, 12.0, 1.0)
      ..cubicTo(7.7, 1.0, 3.99, 3.47, 2.18, 7.07)
      ..lineTo(5.84, 9.91)
      ..cubicTo(6.71, 7.31, 9.14, 5.38, 12.0, 5.38)
      ..close();
    canvas.drawPath(redPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Brand Header Title Widget: "FluentSoul" with split color styling matching the design
class FluentSoulBrandText extends StatelessWidget {
  final double fontSize;
  final bool isDark;
  final bool showTagline;

  const FluentSoulBrandText({
    super.key,
    this.fontSize = 26.0,
    this.isDark = false,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FluentSoulLogo(size: 36),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 'Fluent',
                    style: TextStyle(color: textColor),
                  ),
                  const TextSpan(
                    text: 'Soul',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            'Speak English Fluently & Confidently',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

/// Precise Background Wave Lines Painter matching the reference screenshot's acoustic fan pattern
class BackgroundWavesPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  BackgroundWavesPainter({
    this.color = const Color(0xFFF25C40),
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double opacityMultiplier = isDark ? 0.22 : 0.35;
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const int lineCount = 18;
    for (int i = 0; i < lineCount; i++) {
      final double t = i / (lineCount - 1); // 0.0 to 1.0

      // Opacity gradient: subtle fade towards outer edges
      final double alpha =
          (0.08 + 0.18 * math.sin(t * math.pi)) * opacityMultiplier;
      paint.color = color.withOpacity(alpha.clamp(0.03, 0.40));
      paint.strokeWidth = 1.0 + (i % 2) * 0.5;

      final Path path = Path();

      // Start clustered near bottom left
      final double startX = -size.width * 0.15 + (i * 4.0);
      final double startY = size.height * 1.02 - (i * 8.0);

      // Control points fanning upward and rightward like acoustic soundwaves
      final double control1X = size.width * (0.05 + t * 0.25);
      final double control1Y = size.height * (0.75 - t * 0.35);

      final double control2X = size.width * (0.25 + t * 0.35);
      final double control2Y = size.height * (0.45 - t * 0.30);

      // End points sweeping toward upper middle/right
      final double endX = size.width * (0.50 + t * 0.60);
      final double endY = size.height * (0.15 - t * 0.25);

      path.moveTo(startX, startY);
      path.cubicTo(control1X, control1Y, control2X, control2Y, endX, endY);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundWavesPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}
