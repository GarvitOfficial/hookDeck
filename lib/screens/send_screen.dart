import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';
import '../models/webhook_target.dart';
import '../models/dispatch_record.dart';
import '../services/storage_service.dart';
import '../services/webhook_service.dart';
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
  final TextEditingController _messageController = TextEditingController(
    text: '🚨 Heads up! The v2.4 hotfix has been deployed to production. Monitoring metrics now.',
  );

  String? _attachedFileName = 'hotfix_metrics.png (1.2 MB)';
  bool _silentDelivery = false;
  bool _isSending = false;

  final List<String> _sampleAttachments = [
    'hotfix_metrics.png (1.2 MB)',
    'database_dump.sql (42 MB)',
    'error_log.json (48 KB)',
    'release_notes_v2.pdf (4.8 MB)',
  ];

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
    HapticFeedback.lightImpact();
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
    final profiles = widget.storageService.profiles;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF13182C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Switch Sender Identity',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              ...profiles.map((p) {
                final isSelected = p.id == _selectedProfile?.id;
                return ListTile(
                  leading: GlowingAvatar(
                    avatarValue: p.avatarValue,
                    size: 38,
                    showGlow: isSelected,
                  ),
                  title: Text(
                    p.displayName,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    p.handle,
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF8B5CF6),
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
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
    final webhooks = widget.storageService.webhooks;

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
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Choose Destination Webhook',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Color(0xFF8B5CF6)),
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
              const SizedBox(height: 14),
              if (webhooks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No destinations configured yet.\nTap "+" above to add a webhook!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                )
              else
                ...webhooks.map((w) {
                  final isSelected = w.id == _selectedWebhook?.id;
                  return ListTile(
                    leading: DestinationChip(platform: w.platform, showLiveDot: true),
                    title: Text(
                      w.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      w.maskedUrl,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
                        : (w.isFavorite ? const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18) : null),
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

  void _showAttachmentPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF13182C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attach File or Report',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              ..._sampleAttachments.map((filename) {
                return ListTile(
                  leading: const Icon(Icons.attach_file_rounded, color: Color(0xFF06B6D4)),
                  title: Text(
                    filename,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  onTap: () {
                    setState(() => _attachedFileName = filename);
                    Navigator.pop(context);
                    HapticFeedback.lightImpact();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSend() async {
    if (_selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or create a sender profile first!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_selectedWebhook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please connect a destination webhook first!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty && _attachedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a message or attach a file.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    HapticFeedback.heavyImpact();

    final result = await WebhookService.send(
      profile: _selectedProfile!,
      target: _selectedWebhook!,
      message: message,
      attachmentName: _attachedFileName,
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
        attachmentName: _attachedFileName,
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
              "Couldn't send: ${result.errorMessage ?? 'Status ${result.statusCode}'}. Tap to retry.",
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Dispatch'),
        actions: [
          if (_selectedProfile != null)
            GestureDetector(
              onTap: _showSenderPicker,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    GlowingAvatar(
                      avatarValue: _selectedProfile!.avatarValue,
                      size: 22,
                      showGlow: false,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedProfile!.displayName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down_rounded, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Destination Selector Card
              LuxuryGlassCard(
                padding: const EdgeInsets.all(16),
                onTap: _showDestinationPicker,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_to_mobile_rounded,
                        size: 20,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SENDING TO',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF06B6D4),
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
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  _selectedWebhook != null
                                      ? _selectedWebhook!.title
                                      : 'Tap to select destination',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Change →',
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
              const SizedBox(height: 18),

              // 2. Formatting Toolbar & Message Input Box
              LuxuryGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Micro-formatting toolbar
                    Row(
                      children: [
                        _buildFormatButton('B', () => _insertFormatting('**', '**')),
                        _buildFormatButton('I', () => _insertFormatting('*', '*')),
                        _buildFormatButton('`Code`', () => _insertFormatting('`', '`')),
                        _buildFormatButton('Link', () => _insertFormatting('[Link](', ')')),
                        _buildFormatButton('🔥', () => _insertFormatting('🔥', '')),
                        _buildFormatButton('🚀', () => _insertFormatting('🚀', '')),
                        const Spacer(),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _messageController,
                          builder: (context, val, _) {
                            return Text(
                              '${val.text.length} / 2000',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    TextField(
                      controller: _messageController,
                      maxLines: 6,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        height: 1.45,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write your message... Markdown and links supported.',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. Attach File Section
              LuxuryGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ATTACH FILE',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF06B6D4),
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Images, logs, PDFs up to 25MB',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_attachedFileName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insert_drive_file_rounded,
                              size: 18,
                              color: Color(0xFF06B6D4),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _attachedFileName!,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              onPressed: () {
                                setState(() => _attachedFileName = null);
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _showAttachmentPicker,
                        icon: const Icon(Icons.attach_file_rounded, size: 18),
                        label: const Text('Attach File / Log Sample'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF06B6D4),
                          side: const BorderSide(color: Color(0xFF06B6D4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. Silent delivery switch
              LuxuryGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      _silentDelivery ? Icons.notifications_off_rounded : Icons.notifications_active_rounded,
                      size: 20,
                      color: _silentDelivery ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Silent Delivery',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Sends without ringing or notification sound',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _silentDelivery,
                      activeThumbColor: const Color(0xFF8B5CF6),
                      onChanged: (val) {
                        setState(() => _silentDelivery = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 5. Prominent "Send Webhook (1 Tap)" Button
              LuxuryButton(
                text: 'Send Webhook (1 Tap)',
                icon: Icons.rocket_launch_rounded,
                isLoading: _isSending,
                onPressed: _handleSend,
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Delivers instantly across all connected webhook listeners.',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatButton(String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
