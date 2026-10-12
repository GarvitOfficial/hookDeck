import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
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
  late TextEditingController _imageUrlController;
  late String _selectedTone;
  bool _isSaving = false;

  final List<Map<String, String>> _luxuryTones = [
    {'id': 'brand', 'name': 'HookDeck Crest', 'hex': '#C59B6D'},
    {'id': 'brown', 'name': 'Saddle Brown', 'hex': '#8C5E38'},
    {'id': 'espresso', 'name': 'Espresso Noir', 'hex': '#262320'},
    {'id': 'champagne', 'name': 'Bronze Gold', 'hex': '#C59B6D'},
    {'id': 'terracotta', 'name': 'Terracotta', 'hex': '#9E4732'},
    {'id': 'olive', 'name': 'Forest Olive', 'hex': '#55604C'},
    {'id': 'slate', 'name': 'Cashmere Slate', 'hex': '#475569'},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProfile;
    _nameController = TextEditingController(text: p?.displayName ?? '');
    _handleController = TextEditingController(text: p?.handle ?? '');
    _imageUrlController = TextEditingController(text: p?.customImageUrl ?? '');
    _selectedTone = p?.avatarValue ?? 'brown';

    _nameController.addListener(() => setState(() {}));
    _handleController.addListener(() => setState(() {}));
    _imageUrlController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _onToneSelected(String toneId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTone = toneId;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final name = _nameController.text.trim();
      var handle = _handleController.text.trim();
      if (!handle.startsWith('@')) {
        handle = '@$handle';
      }

      final customImg = _imageUrlController.text.trim();

      if (widget.existingProfile != null) {
        final updated = widget.existingProfile!.copyWith(
          displayName: name,
          handle: handle,
          avatarValue: _selectedTone,
          customImageUrl: customImg.isEmpty ? null : customImg,
        );
        await widget.storageService.saveProfile(updated);
      } else {
        final newProfile = Profile(
          id: const Uuid().v4(),
          displayName: name,
          handle: handle,
          avatarValue: _selectedTone,
          customImageUrl: customImg.isEmpty ? null : customImg,
          createdAt: DateTime.now(),
        );
        await widget.storageService.saveProfile(newProfile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1C1917),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF2A2824)),
            ),
            content: Text(
              widget.existingProfile != null ? 'Profile updated' : 'Profile created',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFF7F5F2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final borderColor = isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC);
    final inputFill = isDark ? const Color(0xFF141311) : Colors.white;

    final isEditing = widget.existingProfile != null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.png',
                width: 22,
                height: 22,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isEditing ? 'Edit Profile' : 'New Profile',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: primaryText,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Minimalist Avatar Banner
                Center(
                  child: Column(
                    children: [
                      GlowingAvatar(
                        avatarValue: _selectedTone,
                        customImageUrl: _imageUrlController.text.trim().isNotEmpty
                            ? _imageUrlController.text.trim()
                            : null,
                        initials: _nameController.text.trim().isNotEmpty
                            ? _nameController.text.trim().substring(0, _nameController.text.trim().length.clamp(1, 2)).toUpperCase()
                            : 'HD',
                        size: 80,
                        showGlow: false,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _imageUrlController.text.trim().isNotEmpty
                            ? 'Custom Image Loaded'
                            : 'Monogram Identity',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Section
                LuxuryGlassCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IDENTITY DETAILS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Display Name
                      Text(
                        'Display Name',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: primaryText),
                        decoration: InputDecoration(
                          hintText: 'e.g. Release Dispatcher',
                          hintStyle: GoogleFonts.inter(fontSize: 13, color: secondaryText.withValues(alpha: 0.6)),
                          filled: true,
                          fillColor: inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a display name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Handle / ID
                      Text(
                        'ID / Handle',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _handleController,
                        style: GoogleFonts.jetBrainsMono(fontSize: 13, color: primaryText),
                        decoration: InputDecoration(
                          hintText: '@release-bot',
                          hintStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: secondaryText.withValues(alpha: 0.6)),
                          filled: true,
                          fillColor: inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a handle/ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Custom Image URL (Full User Empowerment!)
                      Row(
                        children: [
                          Text(
                            'Custom Profile Image URL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Optional',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _imageUrlController,
                        style: GoogleFonts.inter(fontSize: 13, color: primaryText),
                        decoration: InputDecoration(
                          hintText: 'https://example.com/avatar.png',
                          hintStyle: GoogleFonts.inter(fontSize: 12, color: secondaryText.withValues(alpha: 0.6)),
                          prefixIcon: Icon(
                            Icons.link_rounded,
                            size: 18,
                            color: isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown,
                          ),
                          suffixIcon: _imageUrlController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () => _imageUrlController.clear(),
                                )
                              : null,
                          filled: true,
                          fillColor: inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Palette Tone / Monogram Style
                      Text(
                        'Identity Tone & Accent',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: _luxuryTones.map((tone) {
                          final isSelected = _selectedTone == tone['id'];
                          final color = GlowingAvatar.getLuxuryBg(tone['id']!);

                          return InkWell(
                            onTap: () => _onToneSelected(tone['id']!),
                            borderRadius: BorderRadius.circular(30),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown)
                                      : borderColor,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                color: isSelected
                                    ? (isDark ? const Color(0xFF1E1C19) : const Color(0xFFF3ECE4))
                                    : Colors.transparent,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tone['name']!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? primaryText : secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Live Preview Card
                LivePreviewCard(
                  displayName: _nameController.text,
                  handle: _handleController.text,
                  avatarValue: _selectedTone,
                  customImageUrl: _imageUrlController.text.trim().isNotEmpty
                      ? _imageUrlController.text.trim()
                      : null,
                ),
                const SizedBox(height: 28),

                // Save Button
                LuxuryButton(
                  text: isEditing ? 'Save Changes' : 'Save Profile',
                  icon: Icons.check_rounded,
                  isLoading: _isSaving,
                  onPressed: _saveProfile,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
