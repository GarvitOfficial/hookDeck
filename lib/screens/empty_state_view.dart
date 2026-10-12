import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/tactile_button.dart';

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

    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final iconRingBorder = isDark
        ? AppTheme.bronzeGold.withValues(alpha: 0.3)
        : AppTheme.luxuryBrown.withValues(alpha: 0.25);
    final iconBg = isDark ? const Color(0xFF1C1A17) : const Color(0xFFF5EFE6);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          child: LuxuryGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            borderRadius: 24,
            hasGlow: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minimalist Luxury Crest
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: iconRingBorder, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: iconBg,
                        child: Center(
                          child: Icon(
                            Icons.fingerprint_rounded,
                            size: 38,
                            color: isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Headline
                Text(
                  'No profiles yet',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                    letterSpacing: -0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  'Create your bespoke sender identity. Dispatch messages and media to webhooks in one tap—pure simplicity, zero code.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: secondaryText,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Primary Action: Create Profile
                LuxuryButton(
                  text: 'Create Profile',
                  icon: Icons.add_rounded,
                  onPressed: onCreateProfile,
                ),
                const SizedBox(height: 16),

                // Load Sample Profiles (Understated text action)
                TextButton(
                  onPressed: onSeedDemo,
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    'Load Starter Profiles',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
