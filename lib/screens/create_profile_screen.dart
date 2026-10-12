import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../widgets/luxury_glass_card.dart';
import '../widgets/luxury_button.dart';
import '../widgets/glowing_avatar.dart';
import '../widgets/live_preview_card.dart';

class CreateProfileScreen extends StatefulWidget {
  final StorageService storageService;
  final Profile? existingProfile;

  const CreateProfileScreen({
    super.key,
    required this.storageService,
    this.existingProfile,
  });

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _handleController;
  late String _selectedAvatar;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _presets = [
    {'id': 'robot', 'name': '🤖 Bot'},
    {'id': 'bolt', 'name': '⚡ Alert'},
    {'id': 'terminal', 'name': '💻 Tech'},
    {'id': 'flame', 'name': '🔥 Sentry'},
    {'id': 'rocket', 'name': '🚀 CI/CD'},
    {'id': 'shield', 'name': '🛡️ Security'},
    {'id': 'user', 'name': '👤 Personal'},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProfile;
    _nameController = TextEditingController(text: p?.displayName ?? '');
    _handleController = TextEditingController(text: p?.handle ?? '');
    _selectedAvatar = p?.avatarValue ?? 'robot';

    _nameController.addListener(() {
      setState(() {});
    });
    _handleController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    super.dispose();
  }

  void _onPresetSelected(String avatarId) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedAvatar = avatarId;
    });
  }

  void _showAvatarPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF13182C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose Sender Avatar',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select an identity badge for this profile',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _presets.map((preset) {
                  final id = preset['id'] as String;
                  final isSelected = id == _selectedAvatar;
                  return GestureDetector(
                    onTap: () {
                      _onPresetSelected(id);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                            : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlowingAvatar(
                            avatarValue: id,
                            size: 48,
                            showGlow: isSelected,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            preset['name'] as String,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final name = _nameController.text.trim();
    var handle = _handleController.text.trim();
    if (!handle.startsWith('@')) {
      handle = '@$handle';
    }

    final now = DateTime.now();
    final profile = widget.existingProfile != null
        ? widget.existingProfile!.copyWith(
            displayName: name,
            handle: handle,
            avatarValue: _selectedAvatar,
          )
        : Profile(
            id: const Uuid().v4(),
            displayName: name,
            handle: handle,
            avatarValue: _selectedAvatar,
            isPrimary: widget.storageService.profiles.isEmpty,
            createdAt: now,
          );

    await widget.storageService.saveProfile(profile);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingProfile != null
                ? 'Profile updated successfully ✓'
                : 'Profile "${profile.displayName}" created ✓',
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingProfile != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'Create Profile'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Photo / Avatar Uploader with Camera Badge
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GlowingAvatar(
                        avatarValue: _selectedAvatar,
                        size: 96,
                        showGlow: true,
                        onTap: _showAvatarPicker,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showAvatarPicker,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                              border: Border.all(
                                color: isDark ? const Color(0xFF090C15) : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _showAvatarPicker,
                  child: Text(
                    'Tap to change avatar icon',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Preset selector pills row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _presets.map((preset) {
                      final id = preset['id'] as String;
                      final isSelected = id == _selectedAvatar;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(preset['name'] as String),
                          selected: isSelected,
                          onSelected: (_) => _onPresetSelected(id),
                          selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                          labelStyle: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF8B5CF6)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                LuxuryGlassCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Name
                      Text(
                        'Sender Display Name',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Deploy Bot, Sarah Connor, Alpha Alerts',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0A0D18).withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.03),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF8B5CF6),
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a sender display name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Handle / ID
                      Text(
                        'ID / Handle',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _handleController,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          color: const Color(0xFF8B5CF6),
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. @deploy_bot or sarah.dev',
                          hintStyle: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0A0D18).withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.03),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF8B5CF6),
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an identity handle';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The sender identity that webhooks will show in Discord, Slack, etc.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Live Preview Card
                LivePreviewCard(
                  displayName: _nameController.text,
                  handle: _handleController.text,
                  avatarValue: _selectedAvatar,
                ),
                const SizedBox(height: 28),

                // Save Profile Button
                LuxuryButton(
                  text: isEditing ? 'Save Changes' : 'Save Profile',
                  icon: Icons.check_circle_rounded,
                  isLoading: _isSaving,
                  onPressed: _saveProfile,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
