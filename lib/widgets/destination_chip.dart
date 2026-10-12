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

  static Color getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'discord':
        return const Color(0xFF5865F2);
      case 'slack':
        return const Color(0xFFECB22E);
      case 'telegram':
        return const Color(0xFF229ED9);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

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

  static IconData getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'discord':
        return Icons.chat_bubble_rounded;
      case 'slack':
        return Icons.tag_rounded;
      case 'telegram':
        return Icons.send_rounded;
      default:
        return Icons.webhook_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getPlatformColor(platform);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.22)
            : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLiveDot) ...[
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10B981),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF10B981),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ] else ...[
            Icon(getPlatformIcon(platform), size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            getPlatformTitle(platform),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? color
                  : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }
    return chip;
  }
}
