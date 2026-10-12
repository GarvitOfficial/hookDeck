import 'dart:convert';

class Profile {
  final String id;
  final String displayName;
  final String handle;
  final String avatarValue; // e.g. 'robot', 'bolt', 'flame', 'terminal', 'user', 'shield', or image URL
  final bool isPrimary;
  final String? defaultWebhookId;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.displayName,
    required this.handle,
    required this.avatarValue,
    this.isPrimary = false,
    this.defaultWebhookId,
    required this.createdAt,
  });

  Profile copyWith({
    String? id,
    String? displayName,
    String? handle,
    String? avatarValue,
    bool? isPrimary,
    String? defaultWebhookId,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      avatarValue: avatarValue ?? this.avatarValue,
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
      avatarValue: map['avatarValue'] ?? 'robot',
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
