import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluentsoul_mobile/providers/challenges_provider.dart';

class InventorySheet extends StatelessWidget {
  const InventorySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<ChallengesProvider>(context);

    final cardBg = isDark ? const Color(0xFF1B2138) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3150) : const Color(0xFFE2E8F0);
    final headingColor = isDark ? const Color(0xFFEDEFF7) : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF8A8FA3) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131829) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: subtitleColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: headingColor, size: 20),
              const SizedBox(width: 10),
              Text(
                'Inventory',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: headingColor,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close_rounded, color: subtitleColor, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInventoryCard(
                  icon: Icons.support_rounded,
                  name: 'Rescue tokens',
                  count: provider.rescueTokens,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  headingColor: headingColor,
                  subtitleColor: subtitleColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInventoryCard(
                  icon: Icons.shield_outlined,
                  name: 'Streak shields',
                  count: provider.streakShields,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  headingColor: headingColor,
                  subtitleColor: subtitleColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInventoryCard(
                  icon: Icons.replay_rounded,
                  name: 'Rewinds',
                  count: provider.rewinds,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  headingColor: headingColor,
                  subtitleColor: subtitleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard({
    required IconData icon,
    required String name,
    required int count,
    required Color cardBg,
    required Color borderColor,
    required Color headingColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: const Color(0xFFFF8B5E)),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: subtitleColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
