import 'package:flutter/material.dart';

class PersonaCard extends StatelessWidget {
  final String personaKey;
  final String name;
  final String personality;
  final bool isSpeaking;

  const PersonaCard({
    super.key,
    required this.personaKey,
    required this.name,
    required this.personality,
    this.isSpeaking = false,
  });

  Color get avatarGradientStart {
    if (personaKey.contains('riya')) return const Color(0xFFF59E0B);
    return const Color(0xFFF25C40);
  }

  Color get avatarGradientEnd {
    if (personaKey.contains('riya')) return const Color(0xFFF25C40);
    return const Color(0xFFE11D48);
  }

  String get flag {
    if (personaKey.contains('riya') || personaKey.contains('meera')) return '🇮🇳';
    return '🇺🇸';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSpeaking ? const Color(0xFFF25C40) : const Color(0xFF334155),
          width: isSpeaking ? 2 : 1,
        ),
        boxShadow: isSpeaking
            ? [
                BoxShadow(
                  color: const Color(0xFFF25C40).withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          // Avatar circle
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSpeaking)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.2),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, val, child) {
                    return Container(
                      width: 56 * val,
                      height: 56 * val,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF25C40).withOpacity(0.2),
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
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : 'P',
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$flag $name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (isSpeaking)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF25C40).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.volume_up, size: 14, color: Color(0xFFF25C40)),
                            SizedBox(width: 4),
                            Text(
                              'Speaking',
                              style: TextStyle(
                                color: Color(0xFFF25C40),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  personality,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
