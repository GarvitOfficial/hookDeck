import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/profile.dart';
import '../models/webhook_target.dart';
import '../services/storage_service.dart';
import '../widgets/luxury_glass_card.dart';
import '../widgets/luxury_button.dart';
import '../widgets/glowing_avatar.dart';
import '../widgets/destination_chip.dart';
import 'create_profile_screen.dart';
import 'send_screen.dart';
import 'add_webhook_sheet.dart';

class ProfileDetailScreen extends StatelessWidget {
  final Profile profile;
  final StorageService storageService;

  const ProfileDetailScreen({
    super.key,
    required this.profile,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find default webhook or first available
    WebhookTarget? activeWebhook;
    if (profile.defaultWebhookId != null) {
      activeWebhook = storageService.webhooks
          .where((w) => w.id == profile.defaultWebhookId)
          .firstOrNull;
    }
    activeWebhook ??= storageService.webhooks.where((w) => w.isFavorite).firstOrNull ??
        storageService.webhooks.firstOrNull;

    // Filter recent dispatches for this profile
    final profileHistory = storageService.history
        .where((h) => h.profileId == profile.id || h.profileName == profile.displayName)
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateProfileScreen(
                    storageService: storageService,
                    existingProfile: profile,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              if (value == 'primary') {
                await storageService.setPrimaryProfile(profile.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Set as primary profile ✓'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Profile?'),
                    content: Text('Are you sure you want to delete ${profile.displayName}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await storageService.deleteProfile(profile.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              }
            },
            itemBuilder: (context) => [
              if (!profile.isPrimary)
                const PopupMenuItem(
                  value: 'primary',
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                      SizedBox(width: 8),
                      Text('Make Primary'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Profile', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Large Avatar Header (100px)
              Center(
                child: GlowingAvatar(
                  avatarValue: profile.avatarValue,
                  size: 100,
                  showGlow: true,
                  badge: const BotVerifiedBadge(),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                profile.displayName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),

              // Handle with Copy Pill
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: profile.handle));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied ${profile.handle} to clipboard ✓'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.handle,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Badges row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (profile.isPrimary)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF8B5CF6), width: 1.2),
                      ),
                      child: Text(
                        'PRIMARY SENDER',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF8B5CF6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (activeWebhook != null) ...[
                    const SizedBox(width: 8),
                    DestinationChip(
                      platform: activeWebhook.platform,
                      showLiveDot: true,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 28),

              // Giant Prominent "Send" Button (64px)
              LuxuryButton(
                text: 'Send Message or File',
                icon: Icons.rocket_launch_rounded,
                height: 64,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SendScreen(
                        storageService: storageService,
                        initialProfile: profile,
                        initialWebhook: activeWebhook,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                '⚡ Tap to compose • 1 tap away from instant delivery',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(height: 24),

              // Destination Target Card
              LuxuryGlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.webhook_rounded,
                        size: 22,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Destination',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activeWebhook != null
                                ? activeWebhook.title
                                : 'No destination connected',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => AddWebhookSheet(
                            storageService: storageService,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        side: const BorderSide(color: Color(0xFF8B5CF6)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text(
                        activeWebhook != null ? 'Switch' : 'Add Webhook',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Activity Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (profileHistory.isNotEmpty)
                    Text(
                      '${profileHistory.length} dispatched',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF06B6D4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (profileHistory.isEmpty)
                LuxuryGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No messages sent with this profile yet.\nTap "Send Message or File" to fire your first dispatch!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ),
                )
              else
                ...profileHistory.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LuxuryGlassCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.message,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '→ ${item.targetTitle}',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 11,
                                        color: const Color(0xFF8B5CF6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.latencyMs}ms',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        color: const Color(0xFF06B6D4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Delivered ✓',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
