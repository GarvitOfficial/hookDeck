import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/luxury_glass_card.dart';
import '../widgets/destination_chip.dart';
import '../widgets/glowing_avatar.dart';
import 'send_success_screen.dart';

class HistoryScreen extends StatelessWidget {
  final StorageService storageService;

  const HistoryScreen({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final history = storageService.history;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dispatch History',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: primaryText,
          ),
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Clear History',
              icon: Icon(Icons.delete_outline_rounded, size: 20, color: secondaryText),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF171614) : Colors.white,
                    title: Text('Clear History?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                    content: Text(
                      'All delivery records will be erased.',
                      style: GoogleFonts.inter(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel', style: TextStyle(color: secondaryText)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.subtleError),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await storageService.clearHistory();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 36,
                          color: secondaryText.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No dispatches logged yet.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Messages and files dispatched via webhook will appear here.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final record = history[index];
                      final formattedDate =
                          DateFormat('MMM dd, yyyy • HH:mm').format(record.timestamp);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: LuxuryGlassCard(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 16,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SendSuccessScreen(record: record),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GlowingAvatar(
                                    avatarValue: record.profileAvatar,
                                    size: 26,
                                    showGlow: false,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${record.profileName} → ${record.targetTitle}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: primaryText,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  DestinationChip(
                                    platform: record.targetPlatform,
                                    showLiveDot: record.isSuccess,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                record.message,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: primaryText.withValues(alpha: 0.85),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      color: secondaryText,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: record.isSuccess
                                          ? AppTheme.successGreen.withValues(alpha: 0.1)
                                          : AppTheme.subtleError.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${record.statusCode} • ${record.latencyMs}ms',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: record.isSuccess
                                            ? AppTheme.successGreen
                                            : AppTheme.subtleError,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
