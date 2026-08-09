import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fluentsoul_mobile/config/theme.dart';

/// FluentSoul Audio Wave Logo Widget matching the design reference screenshot
class FluentSoulLogo extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color backgroundColor;

  const FluentSoulLogo({
    super.key,
    this.size = 58.0,
    this.primaryColor = AppTheme.primary,
    this.backgroundColor = const Color(0xFFFFEBE5),
  });

  @override
  Widget build(BuildContext context) {
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
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double radius = w / 2;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Blue sweep (Right & Top right)
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(cx, cy)
      ..lineTo(w, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        0,
        -math.pi * 0.45,
        false,
      )
      ..close();
    canvas.drawPath(bluePath, paint);

    // Red sweep (Top left)
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        -math.pi * 0.45,
        -math.pi * 0.55,
        false,
      )
      ..close();
    canvas.drawPath(redPath, paint);

    // Yellow sweep (Bottom left)
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        math.pi,
        -math.pi * 0.45,
        false,
      )
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Green sweep (Bottom right)
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(cx, cy)
      ..arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        math.pi * 0.55,
        -math.pi * 0.55,
        false,
      )
      ..close();
    canvas.drawPath(greenPath, paint);

    // Center cutout hole
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), radius * 0.55, paint);

    // Horizontal bar cutout in white
    paint.color = Colors.white;
    final Rect cutoutRect = Rect.fromLTRB(cx, cy - radius * 0.55, w, cy);
    canvas.drawRect(cutoutRect, paint);

    // Blue horizontal bar
    paint.color = const Color(0xFF4285F4);
    final Rect blueBarRect = Rect.fromLTRB(
        cx - radius * 0.1, cy - radius * 0.28, w, cy + radius * 0.28);
    canvas.drawRRect(
        RRect.fromRectAndRadius(blueBarRect, const Radius.circular(1)), paint);
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
