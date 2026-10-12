import 'dart:convert';

class WebhookTarget {
  final String id;
  final String title;
  final String url;
  final String platform; // 'discord', 'slack', 'telegram', 'generic'
  final bool isFavorite;
  final int orderIndex;
  final DateTime createdAt;

  WebhookTarget({
    required this.id,
    required this.title,
    required this.url,
    this.platform = 'generic',
    this.isFavorite = false,
    this.orderIndex = 0,
    required this.createdAt,
  });

  String get maskedUrl {
    if (url.length <= 15) return '••••••••••••';
    final start = url.substring(0, url.indexOf('://') + 3);
    final domain = url.substring(start.length, url.indexOf('/', start.length).clamp(0, url.length));
    return '$start$domain/...••••';
  }

  static String detectPlatform(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('discord.com/api/webhooks') || lower.contains('discordapp.com/api/webhooks')) {
      return 'discord';
    } else if (lower.contains('slack.com') || lower.contains('hooks.slack.com')) {
      return 'slack';
    } else if (lower.contains('telegram.org') || lower.contains('api.telegram.org')) {
      return 'telegram';
    }
    return 'generic';
  }

  WebhookTarget copyWith({
    String? id,
    String? title,
    String? url,
    String? platform,
    bool? isFavorite,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return WebhookTarget(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      platform: platform ?? this.platform,
      isFavorite: isFavorite ?? this.isFavorite,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'platform': platform,
      'isFavorite': isFavorite,
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WebhookTarget.fromMap(Map<String, dynamic> map) {
    return WebhookTarget(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Webhook Destination',
      url: map['url'] ?? '',
      platform: map['platform'] ?? 'generic',
      isFavorite: map['isFavorite'] ?? false,
      orderIndex: map['orderIndex'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory WebhookTarget.fromJson(String source) => WebhookTarget.fromMap(json.decode(source));
}
