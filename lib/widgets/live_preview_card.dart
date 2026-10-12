import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';
import 'glowing_avatar.dart';

class LivePreviewCard extends StatelessWidget {
  final String displayName;
  final String handle;
  final String avatarValue;
  final String? customImageUrl;
  final String? sampleMessage;

  const LivePreviewCard({
    super.key,
    required this.displayName,
    required this.handle,
    required this.avatarValue,
    this.customImageUrl,
    this.sampleMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedName = displayName.trim().isEmpty ? 'Identity Name' : displayName.trim();
    final resolvedHandle = handle.trim().isEmpty ? '@handle' : handle.trim();
    final message = sampleMessage ?? 'Deployment #204 passed in production • 4 checks verified, 0 alerts.';

    return LuxuryGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'LIVE SENDER PREVIEW',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFC59B6D) : const Color(0xFF8C5E38),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                'Real Destination Output',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF78716C) : const Color(0xFFA8A29E),
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
                customImageUrl: customImageUrl,
                size: 38,
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
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1C1917),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const BotVerifiedBadge(),
                        const SizedBox(width: 6),
                        Text(
                          'Just now',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF78716C) : const Color(0xFFA8A29E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resolvedHandle,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: isDark ? const Color(0xFFC59B6D) : const Color(0xFF8C5E38),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1D1A) : const Color(0xFFF7F5F0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2B2824) : const Color(0xFFE5E0D5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        message,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? const Color(0xFFE7E5E4) : const Color(0xFF292524),
                          height: 1.4,
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
