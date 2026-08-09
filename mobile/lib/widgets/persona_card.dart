import 'package:flutter/material.dart';

class PersonaCard extends StatelessWidget {
  final String personaKey;
  final String name;
  final String personality;
  final bool isSpeaking;
  final bool isUser;

  const PersonaCard({
    super.key,
    required this.personaKey,
    required this.name,
    required this.personality,
    this.isSpeaking = false,
    this.isUser = false,
  });

  Color get avatarGradientStart {
    if (isUser) return const Color(0xFFFA5A3A);
    if (personaKey.contains('riya')) return const Color(0xFF10B981);
    if (personaKey.contains('rohan')) return const Color(0xFF3B82F6);
    if (personaKey.contains('emily')) return const Color(0xFF8B5CF6);
    return const Color(0xFFF25C40);
  }

  Color get avatarGradientEnd {
    if (isUser) return const Color(0xFFF25C40);
    if (personaKey.contains('riya')) return const Color(0xFF059669);
    if (personaKey.contains('rohan')) return const Color(0xFF1D4ED8);
    if (personaKey.contains('emily')) return const Color(0xFF6D28D9);
    return const Color(0xFFE11D48);
  }

  String get flag {
    if (isUser) return '🇮🇳';
    if (personaKey.contains('riya') || personaKey.contains('rohan'))
      return '🇮🇳';
    return '🇺🇸';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isSpeaking ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSpeaking ? const Color(0xFFF25C40) : const Color(0xFF334155),
          width: isSpeaking ? 2.5 : 1,
        ),
        boxShadow: isSpeaking
            ? [
                BoxShadow(
                  color: const Color(0xFFF25C40).withOpacity(0.35),
                  blurRadius: 18,
                  spreadRadius: 2,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Gradient Mesh
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    avatarGradientStart.withOpacity(0.08),
                    Colors.transparent,
                    avatarGradientEnd.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),

          // Center Avatar with Pulsing Speaking Ring
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isSpeaking)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.85, end: 1.25),
                      duration: const Duration(milliseconds: 700),
                      builder: (context, val, child) {
                        return Container(
                          width: 54 * val,
                          height: 54 * val,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF25C40).withOpacity(0.25),
                            border: Border.all(
                              color: const Color(0xFFF25C40).withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [avatarGradientStart, avatarGradientEnd],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: avatarGradientStart.withOpacity(0.4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top Status Indicator Tag (when speaking)
          if (isSpeaking)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF25C40),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF25C40).withOpacity(0.5),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.volume_up_rounded,
                        size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'SPEAKING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Left Google Meet Participant Overlay Tag
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSpeaking
                      ? const Color(0xFFF25C40).withOpacity(0.5)
                      : const Color(0xFF334155).withOpacity(0.6),
                ),
              ),
              child: Row(
                children: [
                  if (isSpeaking)
                    const _EqualizerBars()
                  else
                    const Icon(
                      Icons.mic_off_rounded,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$flag $name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EqualizerBars extends StatelessWidget {
  const _EqualizerBars();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Bar(delay: 0),
        SizedBox(width: 2),
        _Bar(delay: 150),
        SizedBox(width: 2),
        _Bar(delay: 300),
      ],
    );
  }
}

class _Bar extends StatefulWidget {
  final int delay;
  const _Bar({required this.delay});

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 2.5,
          height: 6 + (6 * _controller.value),
          decoration: BoxDecoration(
            color: const Color(0xFFF25C40),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
    );
  }
}
