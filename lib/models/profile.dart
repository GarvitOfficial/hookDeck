import 'dart:convert';

class Profile {
  final String id;
  final String displayName;
  final String handle;
  final String avatarValue; // custom image URL OR preset key OR initials
  final String? customImageUrl; // user uploaded or pasted image URL
  final String? accentColorHex; // luxury custom accent
  final bool isPrimary;
  final String? defaultWebhookId;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.displayName,
    required this.handle,
    required this.avatarValue,
    this.customImageUrl,
    this.accentColorHex,
    this.isPrimary = false,
    this.defaultWebhookId,
    required this.createdAt,
  });

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (displayName.isNotEmpty) {
      return displayName.substring(0, displayName.length.clamp(1, 2)).toUpperCase();
    }
    return 'HD';
  }

  Profile copyWith({
    String? id,
    String? displayName,
    String? handle,
    String? avatarValue,
    String? customImageUrl,
    String? accentColorHex,
    bool? isPrimary,
    String? defaultWebhookId,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      avatarValue: avatarValue ?? this.avatarValue,
      customImageUrl: customImageUrl ?? this.customImageUrl,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      isPrimary: isPrimary ?? this.isPrimary,
      defaultWebhookId: defaultWebhookId ?? this.defaultWebhookId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'handle': handle,
      'avatarValue': avatarValue,
      'customImageUrl': customImageUrl,
      'accentColorHex': accentColorHex,
      'isPrimary': isPrimary,
      'defaultWebhookId': defaultWebhookId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      displayName: map['displayName'] ?? 'Sender',
      handle: map['handle'] ?? '@sender',
      avatarValue: map['avatarValue'] ?? 'monogram',
      customImageUrl: map['customImageUrl'],
      accentColorHex: map['accentColorHex'],
      isPrimary: map['isPrimary'] ?? false,
      defaultWebhookId: map['defaultWebhookId'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory Profile.fromJson(String source) => Profile.fromMap(json.decode(source));
}
