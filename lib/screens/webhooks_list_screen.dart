import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/webhook_target.dart';
import '../services/storage_service.dart';
import '../widgets/luxury_glass_card.dart';
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

  final List<String> _filters = ['All', '★ Favorites', 'Discord', 'Slack', 'Custom API'];

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
    final allWebhooks = widget.storageService.webhooks;
    final query = _searchController.text.trim().toLowerCase();

    final filteredWebhooks = allWebhooks.where((w) {
      if (query.isNotEmpty) {
        if (!w.title.toLowerCase().contains(query) && !w.url.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_selectedFilter == '★ Favorites') {
        return w.isFavorite;
      } else if (_selectedFilter == 'Discord') {
        return w.platform == 'discord';
      } else if (_selectedFilter == 'Slack') {
        return w.platform == 'slack';
      } else if (_selectedFilter == 'Custom API') {
        return w.platform == 'generic';
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Webhooks'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                '${allWebhooks.length} Connected',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add Webhook',
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF8B5CF6)),
            onPressed: () => _openAddWebhookSheet(),
          ),
        ],
      ),
      body: SafeArea(
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
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search destinations by name or URL...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF13182C).withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF8B5CF6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Horizontal Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = filter == _selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) {
                              HapticFeedback.lightImpact();
                              setState(() => _selectedFilter = filter);
                            },
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
                ],
              ),
            ),

            // Webhook List Content
            Expanded(
              child: filteredWebhooks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.link_off_rounded,
                            size: 48,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            allWebhooks.isEmpty
                                ? 'No webhooks connected yet.'
                                : 'No matching webhooks found.',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: () => _openAddWebhookSheet(),
                            icon: const Icon(Icons.add_link_rounded),
                            label: const Text('Add Webhook Now'),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredWebhooks.length + 1,
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < filteredWebhooks.length && newIndex <= filteredWebhooks.length) {
                          widget.storageService.reorderWebhooks(oldIndex, newIndex);
                        }
                      },
                      itemBuilder: (context, index) {
                        // Trailing "+ Add New Webhook" dashed card
                        if (index == filteredWebhooks.length) {
                          return Container(
                            key: const ValueKey('add_new_card_prompt'),
                            margin: const EdgeInsets.only(top: 8, bottom: 24),
                            child: InkWell(
                              onTap: () => _openAddWebhookSheet(),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                                    style: BorderStyle.solid,
                                  ),
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.03)
                                      : Colors.black.withValues(alpha: 0.02),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 18,
                                      color: Color(0xFF8B5CF6),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '+ Add New Webhook Endpoint',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final webhook = filteredWebhooks[index];

                        return Dismissible(
                          key: ValueKey(webhook.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (_) {
                            widget.storageService.deleteWebhook(webhook.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted "${webhook.title}"'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: LuxuryGlassCard(
                              padding: const EdgeInsets.all(16),
                              onTap: () {
                                // Tapping opens the Send screen directly with this webhook pre-selected!
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
                                  // Drag handle (Reorderable)
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.drag_indicator_rounded,
                                        size: 20,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                      ),
                                    ),
                                  ),

                                  // Destination Chip / Platform badge
                                  DestinationChip(
                                    platform: webhook.platform,
                                    showLiveDot: true,
                                  ),
                                  const SizedBox(width: 12),

                                  // Title & Masked URL
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          webhook.title,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          webhook.maskedUrl,
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Favorite Star
                                  IconButton(
                                    icon: Icon(
                                      webhook.isFavorite
                                          ? Icons.star_rounded
                                          : Icons.star_outline_rounded,
                                      color: webhook.isFavorite
                                          ? const Color(0xFFF59E0B)
                                          : (isDark ? Colors.white30 : Colors.black26),
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      widget.storageService.toggleFavoriteWebhook(webhook.id);
                                    },
                                  ),

                                  // 3 dots menu
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      size: 18,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _openAddWebhookSheet(webhook);
                                      } else if (val == 'copy') {
                                        Clipboard.setData(ClipboardData(text: webhook.url));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Copied webhook URL to clipboard ✓'),
                                            behavior: SnackBarBehavior.floating,
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
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
