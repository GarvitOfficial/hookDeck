import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'luxury_glass_card.dart';
import 'glowing_avatar.dart';

class LivePreviewCard extends StatelessWidget {
  final String displayName;
  final String handle;
  final String avatarValue;
  final String? sampleMessage;

  const LivePreviewCard({
    super.key,
    required this.displayName,
    required this.handle,
    required this.avatarValue,
    this.sampleMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedName = displayName.trim().isEmpty ? 'Deploy Bot' : displayName.trim();
    final resolvedHandle = handle.trim().isEmpty ? '@deploy_bot' : handle.trim();
    final message = sampleMessage ?? '🚀 Build #204 passed in production • 4 tests passed, 0 failures';

    return LuxuryGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      hasGlow: true,
      glowColor: const Color(0xFF8B5CF6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.visibility_rounded,
                size: 15,
                color: Color(0xFF06B6D4),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE SENDER PREVIEW',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF06B6D4),
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF5865F2).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Discord / Slack Simulation',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF818CF8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlowingAvatar(
                avatarValue: avatarValue,
                size: 42,
                showGlow: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            resolvedName,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const BotVerifiedBadge(),
                        const SizedBox(width: 8),
                        Text(
                          'Just now',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resolvedHandle,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0A0D18).withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Text(
                        message,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
