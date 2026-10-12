import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/dispatch_record.dart';
import '../widgets/luxury_glass_card.dart';
import '../widgets/luxury_button.dart';
import '../widgets/glowing_avatar.dart';
import '../widgets/destination_chip.dart';

class SendSuccessScreen extends StatelessWidget {
  final DispatchRecord record;

  const SendSuccessScreen({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedTime = DateFormat('MMM dd, yyyy • HH:mm:ss').format(record.timestamp);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // 1. Floating Top Toast / Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF13182C).withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF10B981),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sent ✓ • Delivered in ${record.latencyMs}ms',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Hero Success Celebration Ring
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                        Color(0xFF047857),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.45),
                        blurRadius: 36,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Dispatched Successfully!',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Your message reached ${record.targetTitle} with zero delays.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // 3. Telemetry & Receipt Breakdown Card
              LuxuryGlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                hasGlow: true,
                glowColor: const Color(0xFF10B981),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DELIVERY TELEMETRY & RECEIPT',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF10B981),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sender Row
                    _buildReceiptRow(
                      label: 'Sender Identity',
                      widget: Row(
                        children: [
                          GlowingAvatar(
                            avatarValue: record.profileAvatar,
                            size: 24,
                            showGlow: false,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            record.profileName,
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            record.profileHandle,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                      isDark: isDark,
                    ),
                    const Divider(height: 20),

                    // Destination Row
                    _buildReceiptRow(
                      label: 'Destination',
                      widget: Row(
                        children: [
                          DestinationChip(
                            platform: record.targetPlatform,
                            showLiveDot: true,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              record.targetTitle,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      isDark: isDark,
                    ),
                    const Divider(height: 20),

                    // Timestamp Row
                    _buildReceiptRow(
                      label: 'Timestamp',
                      widget: Text(
                        formattedTime,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),
                      isDark: isDark,
                    ),
                    const Divider(height: 20),

                    // Status & Round-trip Row
                    _buildReceiptRow(
                      label: 'HTTP Response',
                      widget: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${record.statusCode} OK',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06B6D4).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${record.latencyMs} ms',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF06B6D4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      isDark: isDark,
                    ),
                    const Divider(height: 20),

                    // Payload Summary
                    _buildReceiptRow(
                      label: 'Dispatched Content',
                      widget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.message,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (record.attachmentName != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.attach_file_rounded, size: 14, color: Color(0xFF06B6D4)),
                                const SizedBox(width: 4),
                                Text(
                                  record.attachmentName!,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    color: const Color(0xFF06B6D4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Copy Receipt Button
              OutlinedButton.icon(
                onPressed: () {
                  final text = '''
[HookDeck Delivery Receipt]
ID: ${record.id}
Time: $formattedTime
Sender: ${record.profileName} (${record.profileHandle})
Destination: ${record.targetTitle} (${record.targetPlatform})
Status: ${record.statusCode} (${record.latencyMs}ms)
Payload: ${record.message}
''';
                  Clipboard.setData(ClipboardData(text: text));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delivery receipt copied to clipboard ✓'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy Delivery Receipt'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Primary Actions
              LuxuryButton(
                text: 'Send Another Message',
                icon: Icons.send_rounded,
                onPressed: () {
                  Navigator.pop(context); // returns to composer or home
                },
              ),
              const SizedBox(height: 12),

              LuxuryButton(
                text: 'Back to Profiles',
                isSecondary: true,
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow({
    required String label,
    required Widget widget,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 115,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(child: widget),
      ],
    );
  }
}
