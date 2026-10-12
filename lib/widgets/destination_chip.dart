import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DestinationChip extends StatelessWidget {
  final String platform;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showLiveDot;

  const DestinationChip({
    super.key,
    required this.platform,
    this.isSelected = false,
    this.onTap,
    this.showLiveDot = false,
  });

  static String getPlatformTitle(String platform) {
    switch (platform.toLowerCase()) {
      case 'discord':
        return 'Discord';
      case 'slack':
        return 'Slack';
      case 'telegram':
        return 'Telegram';
      default:
        return 'Custom API';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark
        ? const Color(0xFFC59B6D).withValues(alpha: 0.18)
        : const Color(0xFF8C5E38).withValues(alpha: 0.12);

    final selectedBorder = isDark
        ? const Color(0xFFC59B6D)
        : const Color(0xFF8C5E38);

    final unselectedBg = isDark
        ? const Color(0xFF1E1D1A)
        : const Color(0xFFF2EFE9);

    final unselectedBorder = isDark
        ? const Color(0xFF2E2B26)
        : const Color(0xFFE2DDD3);

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? selectedBg : unselectedBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? selectedBorder : unselectedBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLiveDot) ...[
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2E7D52), // Refined forest emerald
              ),
            ),
          ],
          Text(
            getPlatformTitle(platform),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? (isDark ? const Color(0xFFC59B6D) : const Color(0xFF8C5E38))
                  : (isDark ? const Color(0xFFA8A29E) : const Color(0xFF57534E)),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: chip,
      );
    }
    return chip;
  }
}
