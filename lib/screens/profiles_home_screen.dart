import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
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
          color: isDark ? const Color(0xFF0A0D18).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
          elevation: 0,
          height: 66,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF8B5CF6)),
              label: 'Profiles',
            ),
            NavigationDestination(
              icon: Icon(Icons.webhook_rounded),
              selectedIcon: Icon(Icons.webhook_rounded, color: Color(0xFF8B5CF6)),
              label: 'Webhooks',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: Color(0xFF8B5CF6)),
              label: 'History',
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                ),
              ),
              child: const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'HookDeck',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Luxury Light / Dark Mode Toggle
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              themeProvider.toggleTheme();
            },
          ),

          // Options popup (reset to empty state or seed demo)
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune_rounded),
            onSelected: (val) async {
              if (val == 'seed') {
                await storageService.seedDemoData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Luxury demo profiles and webhooks loaded ✓'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              } else if (val == 'clear') {
                await storageService.clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Returned to fresh empty state ✓'),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'seed',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFFA855F7)),
                    SizedBox(width: 8),
                    Text('Load Luxury Demo Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Reset to Empty State'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: profiles.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _openCreateProfile(context),
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  'New Profile',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
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
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading & Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sender Profiles',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '${profiles.length} Active Identities',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // "Ready to Dispatch" Banner Card
                    LuxuryGlassCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 20,
                      hasGlow: true,
                      glowColor: const Color(0xFF06B6D4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                              ),
                            ),
                            child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '⚡ 2-Tap Fast Send Active',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tap any profile to dispatch instant messages or files.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profiles List
                    ...profiles.map((profile) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: LuxuryGlassCard(
                          padding: const EdgeInsets.all(18),
                          borderRadius: 24,
                          hasGlow: profile.isPrimary,
                          glowColor: const Color(0xFF8B5CF6),
                          onTap: () {
                            // Tapping card opens Profile Detail Screen
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
                                    size: 50,
                                    showGlow: profile.isPrimary,
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
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (profile.isPrimary) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: const Color(0xFF8B5CF6)),
                                                ),
                                                child: Text(
                                                  'PRIMARY',
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    color: const Color(0xFF8B5CF6),
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          profile.handle,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF8B5CF6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right_rounded),
                                    onPressed: () {
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
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF06B6D4)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Ready to dispatch',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 11,
                                          color: const Color(0xFF06B6D4),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Quick 1-tap Send Button Pill
                                  GestureDetector(
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
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                                        ),
                                        borderRadius: BorderRadius.circular(999),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.send_rounded, size: 13, color: Colors.white),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Tap to Send →',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
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
                    const SizedBox(height: 80), // Clearance for FAB
                  ],
                ),
              ),
      ),
    );
  }
}
