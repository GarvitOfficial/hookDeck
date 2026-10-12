import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';
import '../models/webhook_target.dart';
import '../models/dispatch_record.dart';
import '../services/storage_service.dart';
import '../services/webhook_service.dart';
import '../theme/app_theme.dart';
import '../widgets/luxury_glass_card.dart';
import '../widgets/luxury_button.dart';
import '../widgets/glowing_avatar.dart';
import '../widgets/destination_chip.dart';
import 'send_success_screen.dart';
import 'add_webhook_sheet.dart';

class SendScreen extends StatefulWidget {
  final StorageService storageService;
  final Profile? initialProfile;
  final WebhookTarget? initialWebhook;

  const SendScreen({
    super.key,
    required this.storageService,
    this.initialProfile,
    this.initialWebhook,
  });

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  late Profile? _selectedProfile;
  late WebhookTarget? _selectedWebhook;
  final TextEditingController _messageController = TextEditingController();

  // Attachments are optional and null by default
  String? _attachedFileName;
  Uint8List? _attachedFileBytes;
  int? _attachedFileSize;
  bool _silentDelivery = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _selectedProfile = widget.initialProfile ?? widget.storageService.primaryProfile;
    _selectedWebhook = widget.initialWebhook ??
        (widget.storageService.webhooks.where((w) => w.isFavorite).firstOrNull ??
            widget.storageService.webhooks.firstOrNull);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _insertFormatting(String prefix, String suffix) {
    HapticFeedback.selectionClick();
    final text = _messageController.text;
    final selection = _messageController.selection;
    if (!selection.isValid) {
      _messageController.text = '$text$prefix$suffix';
      return;
    }
    final selectedText = text.substring(selection.start, selection.end);
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );
    _messageController.text = newText;
    _messageController.selection = TextSelection.collapsed(
      offset: selection.start + prefix.length + selectedText.length,
    );
  }

  void _showSenderPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown;
    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final profiles = widget.storageService.profiles;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141311) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Switch Sender Identity',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 12),
              ...profiles.map((p) {
                final isSelected = p.id == _selectedProfile?.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: GlowingAvatar(
                    avatarValue: p.avatarValue,
                    customImageUrl: p.customImageUrl,
                    initials: p.initials,
                    size: 38,
                    showGlow: false,
                  ),
                  title: Text(
                    p.displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: primaryText,
                    ),
                  ),
                  subtitle: Text(
                    p.handle,
                    style: GoogleFonts.jetBrainsMono(
                      color: secondaryText,
                      fontSize: 11,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: primaryAccent, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _selectedProfile = p);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showDestinationPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown;
    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final webhooks = widget.storageService.webhooks;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141311) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Destination',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_rounded, color: primaryAccent),
                    onPressed: () async {
                      Navigator.pop(context);
                      final newHook = await showModalBottomSheet<WebhookTarget>(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (_) => AddWebhookSheet(
                          storageService: widget.storageService,
                        ),
                      );
                      if (newHook != null) {
                        setState(() => _selectedWebhook = newHook);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (webhooks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No destinations configured.\nTap "+" to add a webhook.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: secondaryText),
                    ),
                  ),
                )
              else
                ...webhooks.map((w) {
                  final isSelected = w.id == _selectedWebhook?.id;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: DestinationChip(platform: w.platform, showLiveDot: true),
                    title: Text(
                      w.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: primaryText,
                      ),
                    ),
                    subtitle: Text(
                      w.maskedUrl,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: secondaryText,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: primaryAccent, size: 20)
                        : (w.isFavorite ? Icon(Icons.star_rounded, color: primaryAccent, size: 18) : null),
                    onTap: () {
                      setState(() => _selectedWebhook = w);
                      Navigator.pop(context);
                    },
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // Real device file picker complying with Google Play Console policies
  Future<void> _pickRealAttachment() async {
    HapticFeedback.lightImpact();
    try {
      final files = await FilePicker.pickFiles(type: FileType.any);

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final size = await file.length() ?? bytes.length;

        setState(() {
          _attachedFileName = file.name;
          _attachedFileBytes = bytes;
          _attachedFileSize = size;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: $e', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: const Color(0xFF1C1917),
          ),
        );
      }
    }
  }

  Future<void> _handleSend() async {
    if (_selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or create a sender profile first!'),
          backgroundColor: Color(0xFF1C1917),
        ),
      );
      return;
    }

    if (_selectedWebhook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect a destination webhook first!'),
          backgroundColor: Color(0xFF1C1917),
        ),
      );
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty && _attachedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a message or attach a file.'),
          backgroundColor: Color(0xFF1C1917),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    final result = await WebhookService.send(
      profile: _selectedProfile!,
      target: _selectedWebhook!,
      message: message,
      attachmentName: _attachedFileName,
      attachmentBytes: _attachedFileBytes,
      silent: _silentDelivery,
    );

    setState(() => _isSending = false);

    if (result.isSuccess) {
      final record = DispatchRecord(
        id: const Uuid().v4(),
        profileId: _selectedProfile!.id,
        profileName: _selectedProfile!.displayName,
        profileHandle: _selectedProfile!.handle,
        profileAvatar: _selectedProfile!.avatarValue,
        targetId: _selectedWebhook!.id,
        targetTitle: _selectedWebhook!.title,
        targetPlatform: _selectedWebhook!.platform,
        message: message,
        attachmentName: _attachedFileName != null
            ? (_attachedFileSize != null
                ? '$_attachedFileName (${(_attachedFileSize! / 1024).toStringAsFixed(1)} KB)'
                : _attachedFileName)
            : null,
        isSuccess: true,
        statusCode: result.statusCode,
        latencyMs: result.latencyMs,
        timestamp: DateTime.now(),
      );

      await widget.storageService.addDispatch(record);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SendSuccessScreen(record: record),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Delivery error: ${result.errorMessage ?? 'Status ${result.statusCode}'}",
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFF1C1917),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppTheme.bronzeGold,
              onPressed: _handleSend,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final primaryAccent = isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown;
    final borderColor = isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC);

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
              'Dispatch Message',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedProfile != null)
            GestureDetector(
              onTap: _showSenderPicker,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1A17) : const Color(0xFFF3ECE4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlowingAvatar(
                      avatarValue: _selectedProfile!.avatarValue,
                      customImageUrl: _selectedProfile!.customImageUrl,
                      initials: _selectedProfile!.initials,
                      size: 22,
                      showGlow: false,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedProfile!.displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: secondaryText),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              children: [
                // 1. Destination Selector Card
                LuxuryGlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  onTap: _showDestinationPicker,
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
                          size: 18,
                          color: primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DESTINATION',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: primaryAccent,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (_selectedWebhook != null) ...[
                                  DestinationChip(
                                    platform: _selectedWebhook!.platform,
                                    showLiveDot: true,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    _selectedWebhook != null
                                        ? _selectedWebhook!.title
                                        : 'Tap to select destination',
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
                          ],
                        ),
                      ),
                      Text(
                        'Change',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Formatting Toolbar & Message Composer
                LuxuryGlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Formatting toolbar
                      Row(
                        children: [
                          _buildFormatButton('B', () => _insertFormatting('**', '**')),
                          _buildFormatButton('I', () => _insertFormatting('*', '*')),
                          _buildFormatButton('`Code`', () => _insertFormatting('`', '`')),
                          _buildFormatButton('Link', () => _insertFormatting('[Link](', ')')),
                          const Spacer(),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _messageController,
                            builder: (context, val, _) {
                              return Text(
                                '${val.text.length} / 2000',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: secondaryText,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 1, color: borderColor),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _messageController,
                        maxLines: 5,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: primaryText,
                          height: 1.45,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: secondaryText.withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Attach File Section (Clean, Real Picker, No Hardcoded Presets)
                LuxuryGlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ATTACHMENT (OPTIONAL)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: primaryAccent,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Discord & Slack native',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_attachedFileName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C1A17) : const Color(0xFFF3ECE4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file_outlined,
                                size: 20,
                                color: primaryAccent,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _attachedFileName!,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryText,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_attachedFileSize != null)
                                      Text(
                                        _attachedFileSize! > 1024 * 1024
                                            ? '${(_attachedFileSize! / (1024 * 1024)).toStringAsFixed(2)} MB'
                                            : '${(_attachedFileSize! / 1024).toStringAsFixed(1)} KB',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: secondaryText,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() {
                                  _attachedFileName = null;
                                  _attachedFileBytes = null;
                                  _attachedFileSize = null;
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(Icons.close_rounded, size: 18, color: secondaryText),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: _pickRealAttachment,
                          icon: Icon(Icons.attach_file_rounded, size: 16, color: primaryAccent),
                          label: Text(
                            'Attach File, Photo, or Log',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: primaryAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Silent delivery switch
                LuxuryGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      Icon(
                        _silentDelivery ? Icons.notifications_off_outlined : Icons.notifications_active_outlined,
                        size: 18,
                        color: secondaryText,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Silent Delivery',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryText,
                              ),
                            ),
                            Text(
                              'Suppress recipient alert sounds',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _silentDelivery,
                        activeThumbColor: primaryAccent,
                        onChanged: (val) => setState(() => _silentDelivery = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 5. Send Webhook Button
                LuxuryButton(
                  text: 'Dispatch Webhook',
                  icon: Icons.send_rounded,
                  isLoading: _isSending,
                  onPressed: _handleSend,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormatButton(String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final borderColor = isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: secondaryText,
          ),
        ),
      ),
    );
  }
}
