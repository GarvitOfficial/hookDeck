import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/webhook_target.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/destination_chip.dart';
import 'add_webhook_sheet.dart';
import 'send_screen.dart';

class WebhooksListScreen extends StatefulWidget {
  final StorageService storageService;

  const WebhooksListScreen({
    super.key,
    required this.storageService,
  });

  @override
  State<WebhooksListScreen> createState() => _WebhooksListScreenState();
}

class _WebhooksListScreenState extends State<WebhooksListScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', '★ Starred', 'Discord', 'Slack', 'Custom'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddWebhookSheet([WebhookTarget? existing]) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddWebhookSheet(
        storageService: widget.storageService,
        existingWebhook: existing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? const Color(0xFFF7F5F2) : const Color(0xFF1C1917);
    final secondaryText = isDark ? const Color(0xFFA8A29E) : const Color(0xFF78716C);
    final primaryAccent = isDark ? AppTheme.bronzeGold : AppTheme.luxuryBrown;
    final borderColor = isDark ? const Color(0xFF2A2824) : const Color(0xFFE8E4DC);
    final inputFill = isDark ? const Color(0xFF141311) : Colors.white;

    final allWebhooks = widget.storageService.webhooks;
    final query = _searchController.text.trim().toLowerCase();

    final filteredWebhooks = allWebhooks.where((w) {
      if (query.isNotEmpty) {
        if (!w.title.toLowerCase().contains(query) && !w.url.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_selectedFilter == '★ Starred') {
        return w.isFavorite;
      } else if (_selectedFilter == 'Discord') {
        return w.platform == 'discord';
      } else if (_selectedFilter == 'Slack') {
        return w.platform == 'slack';
      } else if (_selectedFilter == 'Custom') {
        return w.platform == 'generic';
      }
      return true;
    }).toList();

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
              'Destinations',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: primaryText,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add Webhook',
            icon: Icon(Icons.add_rounded, color: primaryAccent, size: 22),
            onPressed: () => _openAddWebhookSheet(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                // Search Bar & Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.inter(fontSize: 13, color: primaryText),
                        decoration: InputDecoration(
                          hintText: 'Search destinations by name or URL...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: secondaryText.withValues(alpha: 0.6),
                          ),
                          prefixIcon: Icon(Icons.search_rounded, size: 18, color: secondaryText),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: inputFill,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                            borderSide: BorderSide(color: primaryAccent, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.map((filter) {
                            final isSelected = filter == _selectedFilter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedFilter = filter);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? primaryAccent : borderColor,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    color: isSelected
                                        ? primaryAccent.withValues(alpha: 0.12)
                                        : Colors.transparent,
                                  ),
                                  child: Text(
                                    filter,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? primaryText : secondaryText,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Webhook List
                Expanded(
                  child: filteredWebhooks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.link_off_rounded,
                                size: 36,
                                color: secondaryText.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                allWebhooks.isEmpty
                                    ? 'No webhooks connected yet.'
                                    : 'No matching webhooks found.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => _openAddWebhookSheet(),
                                child: Text(
                                  '+ Add Webhook Destination',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: primaryAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: filteredWebhooks.length + 1,
                          itemBuilder: (context, index) {
                            if (index == filteredWebhooks.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 32),
                                child: InkWell(
                                  onTap: () => _openAddWebhookSheet(),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_rounded, size: 16, color: primaryAccent),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Connect New Webhook',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: primaryAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            final webhook = filteredWebhooks[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: LuxuryGlassCard(
                                padding: const EdgeInsets.all(14),
                                borderRadius: 16,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SendScreen(
                                        storageService: widget.storageService,
                                        initialWebhook: webhook,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    DestinationChip(
                                      platform: webhook.platform,
                                      showLiveDot: true,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            webhook.title,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: primaryText,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            webhook.maskedUrl,
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 11,
                                              color: secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        webhook.isFavorite
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        color: webhook.isFavorite
                                            ? primaryAccent
                                            : secondaryText.withValues(alpha: 0.4),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        widget.storageService.toggleFavoriteWebhook(webhook.id);
                                      },
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        size: 18,
                                        color: secondaryText,
                                      ),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _openAddWebhookSheet(webhook);
                                        } else if (val == 'copy') {
                                          Clipboard.setData(ClipboardData(text: webhook.url));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Copied URL', style: GoogleFonts.plusJakartaSans()),
                                              backgroundColor: const Color(0xFF1C1917),
                                            ),
                                          );
                                        } else if (val == 'delete') {
                                          widget.storageService.deleteWebhook(webhook.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit Webhook'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'copy',
                                          child: Text('Copy URL'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete', style: TextStyle(color: AppTheme.subtleError)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
