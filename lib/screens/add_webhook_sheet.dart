import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/webhook_target.dart';
import '../services/storage_service.dart';
import '../services/webhook_service.dart';
import '../widgets/luxury_button.dart';
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

  final List<String> _platforms = ['discord', 'slack', 'telegram', 'generic'];

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
            ? '✓ Test ping succeeded (${result.latencyMs}ms)'
            : '✕ Could not reach endpoint (${result.errorMessage ?? "Code ${result.statusCode}"})';
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
          content: Text('Connected webhook "${target.title}" ✓'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10131E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: isDark
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, -4),
          ),
        ],
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
              // Drag pill handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sheet Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_link_rounded,
                      size: 20,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existingWebhook != null ? 'Edit Webhook' : 'Add New Webhook',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Connect Discord, Slack, or generic HTTP destination',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Platform Type Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PLATFORM TYPE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF06B6D4),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Auto-detects URL format',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF06B6D4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _platforms.map((platform) {
                    final isSelected = platform == _selectedPlatform;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: DestinationChip(
                        platform: platform,
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedPlatform = platform);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Webhook Name / Title
              Text(
                'Webhook Name / Channel Title',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Team Announcements, Prod Alerts',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0A0D18).withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name for this webhook';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              Text(
                'Give it a friendly name so you can find it easily.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 18),

              // Webhook URL Field with Paste Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Webhook URL',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'HTTPS TLS 1.3',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _urlController,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'https://discord.com/api/webhooks/...',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(Icons.link_rounded, size: 20),
                  suffixIcon: TextButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.paste_rounded, size: 14),
                    label: const Text('Paste'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      textStyle: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0A0D18).withValues(alpha: 0.6)
                      : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a webhook URL';
                  }
                  if (!val.trim().startsWith('http://') && !val.trim().startsWith('https://')) {
                    return 'URL must start with http:// or https://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Favorite toggle & Test Ping
              Row(
                children: [
                  Icon(
                    _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: _isFavorite ? const Color(0xFFF59E0B) : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mark as Favorite',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Pins to quick destination list',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isFavorite,
                    activeThumbColor: const Color(0xFF8B5CF6),
                    onChanged: (val) {
                      setState(() => _isFavorite = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Test Ping Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connection Diagnostic',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          if (_testStatusMessage != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _testStatusMessage!,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                color: _testSuccess == true
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _isTesting ? null : _runTestPing,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.bolt_rounded, size: 16),
                      label: Text(_isTesting ? 'Pinging...' : 'Test Ping'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF06B6D4),
                        textStyle: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              LuxuryButton(
                text: 'Save & Connect Webhook',
                icon: Icons.check_circle_outline_rounded,
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
