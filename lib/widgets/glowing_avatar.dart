import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlowingAvatar extends StatelessWidget {
  final String avatarValue;
  final double size;
  final bool showGlow;
  final Widget? badge;
  final VoidCallback? onTap;

  const GlowingAvatar({
    super.key,
    required this.avatarValue,
    this.size = 56,
    this.showGlow = true,
    this.badge,
    this.onTap,
  });

  static IconData getIconForPreset(String preset) {
    switch (preset.toLowerCase()) {
      case 'robot':
        return Icons.smart_toy_rounded;
      case 'terminal':
        return Icons.terminal_rounded;
      case 'flame':
        return Icons.local_fire_department_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'user':
        return Icons.person_rounded;
      case 'rocket':
        return Icons.rocket_launch_rounded;
      default:
        return Icons.face_rounded;
    }
  }

  static LinearGradient getGradientForPreset(String preset) {
    switch (preset.toLowerCase()) {
      case 'robot':
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'terminal':
        return const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'flame':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'bolt':
        return const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'shield':
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rocket':
        return const LinearGradient(
          colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = getGradientForPreset(avatarValue);
    final icon = getIconForPreset(avatarValue);

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: size * 0.35,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.52,
          color: Colors.white,
        ),
      ),
    );

    if (badge != null) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            bottom: -2,
            right: -2,
            child: badge!,
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}

class BotVerifiedBadge extends StatelessWidget {
  const BotVerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF5865F2), // Discord blue
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5865F2).withValues(alpha: 0.5),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        'BOT',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
