import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
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
    final history = storageService.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch History'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Clear History',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear History?'),
                    content: const Text('All delivery logs and receipts will be cleared.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        child: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 48,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No dispatch records yet.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Every webhook message you send will be logged here.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LuxuryGlassCard(
                      padding: const EdgeInsets.all(16),
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
                                size: 28,
                                showGlow: false,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${record.profileName} → ${record.targetTitle}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                          const SizedBox(height: 10),
                          Text(
                            record.message,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
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
                                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: record.isSuccess
                                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                      : const Color(0xFFEF4444).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${record.statusCode} • ${record.latencyMs}ms',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: record.isSuccess
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
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
    );
  }
}
