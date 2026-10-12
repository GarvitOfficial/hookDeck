import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/profile.dart';
import '../models/webhook_target.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
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
    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final primaryAccent = isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown;
    final borderColor = isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC);

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
        title: Text(
          'Identity Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, size: 20),
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
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            onSelected: (value) async {
              if (value == 'primary') {
                await storageService.setPrimaryProfile(profile.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Set as primary sender', style: GoogleFonts.plusJakartaSans()),
                      backgroundColor: const Color(0xFF1C1917),
                    ),
                  );
                }
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? const Color(0xFF171614) : Colors.white,
                    title: Text('Delete Profile?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                    content: Text(
                      'Are you sure you want to delete ${profile.displayName}?',
                      style: GoogleFonts.inter(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: secondaryText)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.subtleError),
                        child: Text('Delete', style: GoogleFonts.plusJakartaSans(color: AppTheme.subtleError, fontWeight: FontWeight.w600)),
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
                PopupMenuItem(
                  value: 'primary',
                  child: Row(
                    children: [
                      Icon(Icons.star_outline_rounded, size: 18, color: primaryAccent),
                      const SizedBox(width: 8),
                      const Text('Make Primary'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.subtleError),
                    const SizedBox(width: 8),
                    Text('Delete Profile', style: TextStyle(color: AppTheme.subtleError)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Clean Minimalist Profile Header
                Center(
                  child: GlowingAvatar(
                    avatarValue: profile.avatarValue,
                    customImageUrl: profile.customImageUrl,
                    initials: profile.initials,
                    size: 92,
                    showGlow: false,
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Center(
                  child: Text(
                    profile.displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                      letterSpacing: -0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),

                // Handle Pill with Copy
                Center(
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: profile.handle));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied ${profile.handle}', style: GoogleFonts.plusJakartaSans()),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF1C1917),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF171614) : const Color(0xFFF3ECE4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.handle,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: primaryAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.copy_rounded,
                            size: 12,
                            color: secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Status Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (profile.isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'DEFAULT SENDER',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: primaryAccent,
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
                const SizedBox(height: 24),

                // Dispatch Action Button
                LuxuryButton(
                  text: 'Dispatch Message or Media',
                  icon: Icons.send_rounded,
                  height: 54,
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
                const SizedBox(height: 24),

                // Destination Target Card
                LuxuryGlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.webhook_rounded,
                          size: 20,
                          color: primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Linked Destination',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: secondaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeWebhook != null
                                  ? activeWebhook.title
                                  : 'No destination connected',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
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
                        style: TextButton.styleFrom(
                          foregroundColor: primaryAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: Text(
                          activeWebhook != null ? 'Switch' : 'Add',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (profileHistory.isNotEmpty)
                      Text(
                        '${profileHistory.length} sent',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: secondaryText,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (profileHistory.isEmpty)
                  LuxuryGlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 16,
                    child: Center(
                      child: Text(
                        'No dispatches recorded yet with this profile.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: secondaryText,
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
                        borderRadius: 14,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: AppTheme.successGreen,
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
                                      fontWeight: FontWeight.w400,
                                      color: primaryText,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '→ ${item.targetTitle}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: primaryAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${item.latencyMs}ms',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          color: secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Sent',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.successGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
