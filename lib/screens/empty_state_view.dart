import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/luxury_glass_card.dart';
import '../widgets/luxury_button.dart';

class EmptyStateView extends StatelessWidget {
  final VoidCallback onCreateProfile;
  final VoidCallback onSeedDemo;

  const EmptyStateView({
    super.key,
    required this.onCreateProfile,
    required this.onSeedDemo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: LuxuryGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          borderRadius: 28,
          hasGlow: true,
          glowColor: const Color(0xFF8B5CF6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hero Beacon Animation Container
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF3B82F6),
                      Color(0xFF06B6D4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                      blurRadius: 36,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF090C15) : Colors.white,
                        ),
                      ),
                      const Icon(
                        Icons.send_rounded,
                        size: 44,
                        color: Color(0xFF8B5CF6),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF06B6D4),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF06B6D4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Headline
              Text(
                'No profiles yet',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Plain Language Subtitle
              Text(
                'Create your sender identity once. Send instant messages and files to any webhook channel in just two taps—zero code required.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Primary Action: Create Profile
              LuxuryButton(
                text: 'Create Profile',
                icon: Icons.add_circle_outline_rounded,
                onPressed: onCreateProfile,
                gradient: AppTheme.primaryGradient,
              ),
              const SizedBox(height: 14),

              // Helper Tip
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 15,
                    color: Color(0xFF06B6D4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Takes less than 30 seconds to set up',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF06B6D4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Divider & Quick Load Demo button
              Divider(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 8),

              TextButton.icon(
                onPressed: onSeedDemo,
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: Text(
                  'Load Luxury Demo Setup (Pre-filled)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFA855F7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
