import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlowingAvatar extends StatelessWidget {
  final String avatarValue;
  final String? customImageUrl;
  final String? initials;
  final double size;
  final bool showGlow;
  final Widget? badge;
  final VoidCallback? onTap;

  const GlowingAvatar({
    super.key,
    required this.avatarValue,
    this.customImageUrl,
    this.initials,
    this.size = 52,
    this.showGlow = false,
    this.badge,
    this.onTap,
  });

  static Color getLuxuryBg(String preset) {
    switch (preset.toLowerCase()) {
      case 'camel':
      case 'brown':
        return const Color(0xFF8C5E38);
      case 'espresso':
      case 'noir':
        return const Color(0xFF262320);
      case 'terracotta':
        return const Color(0xFF9E4732);
      case 'olive':
        return const Color(0xFF55604C);
      case 'slate':
        return const Color(0xFF475569);
      case 'champagne':
        return const Color(0xFFC59B6D);
      default:
        return const Color(0xFF8C5E38);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackColor = getLuxuryBg(avatarValue);

    Widget innerContent;

    // 1. If custom image URL is provided and valid
    if (customImageUrl != null && customImageUrl!.trim().isNotEmpty) {
      innerContent = Image.network(
        customImageUrl!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsFallback(fallbackColor);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    } else if (avatarValue.startsWith('http://') || avatarValue.startsWith('https://')) {
      innerContent = Image.network(
        avatarValue.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsFallback(fallbackColor);
        },
      );
    } else if (avatarValue == 'brand' ||
        avatarValue == 'logo' ||
        avatarValue == 'hookdeck' ||
        initials == 'H' ||
        initials == 'HD') {
      innerContent = ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsFallback(fallbackColor);
          },
        ),
      );
    } else {
      innerContent = _buildInitialsFallback(fallbackColor);
    }

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fallbackColor,
        border: Border.all(
          color: isDark
              ? const Color(0xFFC59B6D).withValues(alpha: 0.35)
              : const Color(0xFF8C5E38).withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: (isDark ? const Color(0xFFC59B6D) : const Color(0xFF8C5E38))
                      .withValues(alpha: 0.2),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipOval(child: innerContent),
    );

    if (badge != null) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            bottom: -1,
            right: -1,
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

  Widget _buildInitialsFallback(Color bg) {
    final text = initials ??
        (avatarValue.length <= 3 ? avatarValue.toUpperCase() : avatarValue.substring(0, 1).toUpperCase());

    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class BotVerifiedBadge extends StatelessWidget {
  const BotVerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF8C5E38),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'VERIFIED',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
