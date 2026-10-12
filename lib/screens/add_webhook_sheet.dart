import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/webhook_target.dart';
import '../services/storage_service.dart';
import '../services/webhook_service.dart';
import '../theme/app_theme.dart';
import '../widgets/tactile_button.dart';
import '../widgets/destination_chip.dart';

class AddWebhookSheet extends StatefulWidget {
  final StorageService storageService;
  final WebhookTarget? existingWebhook;

  const AddWebhookSheet({
    super.key,
    required this.storageService,
    this.existingWebhook,
  });

  @override
  State<AddWebhookSheet> createState() => _AddWebhookSheetState();
}

class _AddWebhookSheetState extends State<AddWebhookSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _urlController;
  late String _selectedPlatform;
  late bool _isFavorite;

  bool _isTesting = false;
  String? _testStatusMessage;
  bool? _testSuccess;

  final List<String> _platforms = ['discord', 'slack', 'generic'];

  @override
  void initState() {
    super.initState();
    final w = widget.existingWebhook;
    _titleController = TextEditingController(text: w?.title ?? '');
    _urlController = TextEditingController(text: w?.url ?? '');
    _selectedPlatform = w?.platform ?? 'discord';
    _isFavorite = w?.isFavorite ?? false;

    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final text = _urlController.text.trim();
    if (text.isNotEmpty) {
      final detected = WebhookTarget.detectPlatform(text);
      if (detected != _selectedPlatform) {
        setState(() {
          _selectedPlatform = detected;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _urlController.text = data.text!.trim();
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _runTestPing() async {
    final url = _urlController.text.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      setState(() {
        _testSuccess = false;
        _testStatusMessage = 'Please enter a valid HTTP/HTTPS URL first';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testStatusMessage = null;
    });

    final tempTarget = WebhookTarget(
      id: 'test',
      title: _titleController.text.trim().isEmpty ? 'Test Destination' : _titleController.text.trim(),
      url: url,
      platform: _selectedPlatform,
      createdAt: DateTime.now(),
    );

    final result = await WebhookService.testPing(tempTarget);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testSuccess = result.isSuccess;
        _testStatusMessage = result.isSuccess
            ? '✓ Verified reachable (${result.latencyMs}ms)'
            : '✕ Endpoint error (${result.errorMessage ?? "Code ${result.statusCode}"})';
      });
    }
  }

  Future<void> _saveWebhook() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();

    final target = widget.existingWebhook != null
        ? widget.existingWebhook!.copyWith(
            title: title,
            url: url,
            platform: _selectedPlatform,
            isFavorite: _isFavorite,
          )
        : WebhookTarget(
            id: const Uuid().v4(),
            title: title,
            url: url,
            platform: _selectedPlatform,
            isFavorite: _isFavorite,
            orderIndex: widget.storageService.webhooks.length,
            createdAt: DateTime.now(),
          );

    await widget.storageService.saveWebhook(target);

    if (mounted) {
      Navigator.pop(context, target);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected "${target.title}"', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFF1C1917),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final primaryAccent = isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown;
    final borderColor = isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC);
    final inputFill = isDark ? const Color(0xFF141311) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171614) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingWebhook != null ? 'Edit Destination' : 'Add Destination',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: primaryText,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Platform selection
              Text(
                'Platform Type',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _platforms.map((platform) {
                  final isSelected = platform == _selectedPlatform;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: DestinationChip(
                      platform: platform,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPlatform = platform);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Name
              Text(
                'Destination Label',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: primaryText),
                decoration: InputDecoration(
                  hintText: 'e.g. Production Alerts',
                  hintStyle: GoogleFonts.inter(fontSize: 12, color: secondaryText.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: inputFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryAccent, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name for this webhook';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Webhook URL
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Webhook URL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  InkWell(
                    onTap: _pasteFromClipboard,
                    child: Text(
                      'Paste from clipboard',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: primaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _urlController,
                maxLines: 2,
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: primaryText),
                decoration: InputDecoration(
                  hintText: 'https://discord.com/api/webhooks/...',
                  hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: secondaryText.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: inputFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryAccent, width: 1.5),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a webhook URL';
                  }
                  if (!val.trim().startsWith('http://') && !val.trim().startsWith('https://')) {
                    return 'Must start with http:// or https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Test Ping Button
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isTesting ? null : _runTestPing,
                    icon: _isTesting
                        ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: primaryAccent),
                          )
                        : Icon(Icons.bolt_rounded, size: 14, color: primaryAccent),
                    label: Text(
                      _isTesting ? 'Testing...' : 'Test Ping',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primaryAccent,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  if (_testStatusMessage != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _testStatusMessage!,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: _testSuccess == true ? AppTheme.successGreen : AppTheme.subtleError,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Star as favorite
              Row(
                children: [
                  Icon(
                    _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 18,
                    color: _isFavorite ? primaryAccent : secondaryText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mark as Primary Destination',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: primaryText,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isFavorite,
                    activeThumbColor: primaryAccent,
                    onChanged: (val) => setState(() => _isFavorite = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Save Action
              LuxuryButton(
                text: widget.existingWebhook != null ? 'Update Webhook' : 'Save Webhook',
                icon: Icons.check_rounded,
                onPressed: _saveWebhook,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
