import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/luxury_glass_card.dart';
import '../widgets/glowing_avatar.dart';
import 'empty_state_view.dart';
import 'create_profile_screen.dart';
import 'profile_detail_screen.dart';
import 'send_screen.dart';
import 'webhooks_list_screen.dart';
import 'history_screen.dart';

class MainNavigationHolder extends StatefulWidget {
  final StorageService storageService;
  final ThemeProvider themeProvider;

  const MainNavigationHolder({
    super.key,
    required this.storageService,
    required this.themeProvider,
  });

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeProvider.isDarkMode;
    final primaryAccent = isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown;

    final screens = [
      ProfilesHomeScreen(
        storageService: widget.storageService,
        themeProvider: widget.themeProvider,
        onNavigateToSend: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SendScreen(storageService: widget.storageService),
            ),
          );
        },
      ),
      WebhooksListScreen(storageService: widget.storageService),
      HistoryScreen(storageService: widget.storageService),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141311) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: primaryAccent.withValues(alpha: 0.15),
          elevation: 0,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.people_outline_rounded, size: 22),
              selectedIcon: Icon(Icons.people_rounded, size: 22, color: primaryAccent),
              label: 'Profiles',
            ),
            NavigationDestination(
              icon: const Icon(Icons.webhook_rounded, size: 22),
              selectedIcon: Icon(Icons.webhook_rounded, size: 22, color: primaryAccent),
              label: 'Webhooks',
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined, size: 22),
              selectedIcon: Icon(Icons.receipt_long_rounded, size: 22, color: primaryAccent),
              label: 'Audit Log',
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilesHomeScreen extends StatelessWidget {
  final StorageService storageService;
  final ThemeProvider themeProvider;
  final VoidCallback onNavigateToSend;

  const ProfilesHomeScreen({
    super.key,
    required this.storageService,
    required this.themeProvider,
    required this.onNavigateToSend,
  });

  void _openCreateProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateProfileScreen(storageService: storageService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    final profiles = storageService.profiles;

    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final primaryAccent = isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown;
    final cardBorder = isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryAccent,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'HookDeck',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
                color: primaryText,
              ),
            ),
          ],
        ),
        actions: [
          // Theme Switcher (Espresso Noir / Ivory White)
          IconButton(
            tooltip: isDark ? 'Switch to Ivory Light' : 'Switch to Espresso Noir',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: primaryAccent,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              themeProvider.toggleTheme();
            },
          ),

          // Options menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz_rounded, color: primaryText),
            onSelected: (val) async {
              if (val == 'seed') {
                await storageService.seedDemoData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Demo profiles restored',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                      backgroundColor: const Color(0xFF1C1917),
                    ),
                  );
                }
              } else if (val == 'clear') {
                await storageService.clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reset to clean state',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                      backgroundColor: const Color(0xFF1C1917),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'seed',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 16, color: primaryAccent),
                    const SizedBox(width: 10),
                    const Text('Reload Starter Profiles'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all_rounded, size: 16, color: Colors.grey),
                    SizedBox(width: 10),
                    Text('Clear All Data'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: profiles.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _openCreateProfile(context),
              backgroundColor: isDark ? const Color(0xFF262320) : AppTheme.luxuryBrown,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: cardBorder),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'New Profile',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.1,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: profiles.isEmpty
            ? EmptyStateView(
                onCreateProfile: () => _openCreateProfile(context),
                onSeedDemo: () => storageService.seedDemoData(),
              )
            : Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // Header & Counter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sender Identities',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: primaryText,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primaryAccent.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              '${profiles.length} Active',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primaryAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Minimalist Status Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141311) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 16,
                              color: primaryAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tap any profile to dispatch instant messages or files.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Profiles List
                      ...profiles.map((profile) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LuxuryGlassCard(
                            padding: const EdgeInsets.all(16),
                            borderRadius: 18,
                            hasGlow: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileDetailScreen(
                                    profile: profile,
                                    storageService: storageService,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GlowingAvatar(
                                      avatarValue: profile.avatarValue,
                                      customImageUrl: profile.customImageUrl,
                                      initials: profile.initials,
                                      size: 46,
                                      showGlow: false,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  profile.displayName,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: primaryText,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (profile.isPrimary) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: primaryAccent.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
                                                  ),
                                                  child: Text(
                                                    'DEFAULT',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w700,
                                                      color: primaryAccent,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            profile.handle,
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 11,
                                              color: secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 20,
                                      color: secondaryText.withValues(alpha: 0.5),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(height: 1, color: cardBorder),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Ready for delivery',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: secondaryText,
                                      ),
                                    ),

                                    // Refined Dispatch Pill Button
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SendScreen(
                                              storageService: storageService,
                                              initialProfile: profile,
                                            ),
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF262320) : AppTheme.luxuryBrown,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.send_rounded, size: 11, color: Colors.white),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Dispatch →',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
