import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/dispatch_record.dart';
import '../theme/app_theme.dart';
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
    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final primaryAccent = isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown;
    final borderColor = isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC);

    final formattedTime = DateFormat('MMM dd, yyyy • HH:mm:ss').format(record.timestamp);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                const SizedBox(height: 16),
                // Minimalist Check Crest
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.successGreen.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppTheme.successGreen.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 36,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Dispatched Successfully',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                    letterSpacing: -0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                Text(
                  'Delivered to ${record.targetTitle} in ${record.latencyMs}ms',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Telemetry & Receipt Breakdown Card
                LuxuryGlassCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 18,
                  hasGlow: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DISPATCH RECEIPT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: primaryAccent,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sender Identity
                      _buildReceiptRow(
                        label: 'Sender',
                        widget: Row(
                          children: [
                            GlowingAvatar(
                              avatarValue: record.profileAvatar,
                              size: 22,
                              showGlow: false,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              record.profileName,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: primaryText,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              record.profileHandle,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                        isDark: isDark,
                      ),
                      Divider(height: 20, color: borderColor),

                      // Destination
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
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        isDark: isDark,
                      ),
                      Divider(height: 20, color: borderColor),

                      // Timestamp
                      _buildReceiptRow(
                        label: 'Timestamp',
                        widget: Text(
                          formattedTime,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: secondaryText,
                          ),
                        ),
                        isDark: isDark,
                      ),
                      Divider(height: 20, color: borderColor),

                      // Response Status
                      _buildReceiptRow(
                        label: 'Status',
                        widget: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${record.statusCode} OK',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${record.latencyMs} ms',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                        isDark: isDark,
                      ),
                      Divider(height: 20, color: borderColor),

                      // Content summary
                      _buildReceiptRow(
                        label: 'Content',
                        widget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.message,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: primaryText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (record.attachmentName != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.attach_file_rounded, size: 14, color: primaryAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    record.attachmentName!,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      color: secondaryText,
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
                const SizedBox(height: 16),

                // Copy Receipt Action
                Center(
                  child: TextButton.icon(
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
                        SnackBar(
                          content: Text('Receipt copied', style: GoogleFonts.plusJakartaSans()),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF1C1917),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy_rounded, size: 14, color: primaryAccent),
                    label: Text(
                      'Copy Receipt Text',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Actions
                LuxuryButton(
                  text: 'Send Another Message',
                  icon: Icons.send_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 12),

                LuxuryButton(
                  text: 'Back to Profiles',
                  isSecondary: true,
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                ),
                const SizedBox(height: 32),
              ],
            ),
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
          width: 95,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C),
            ),
          ),
        ),
        Expanded(child: widget),
      ],
    );
  }
}
