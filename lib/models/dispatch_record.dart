import 'dart:convert';

class DispatchRecord {
  final String id;
  final String profileId;
  final String profileName;
  final String profileHandle;
  final String profileAvatar;
  final String targetId;
  final String targetTitle;
  final String targetPlatform;
  final String message;
  final String? attachmentName;
  final bool isSuccess;
  final int statusCode;
  final int latencyMs;
  final String? errorDetail;
  final DateTime timestamp;

  DispatchRecord({
    required this.id,
    required this.profileId,
    required this.profileName,
    required this.profileHandle,
    required this.profileAvatar,
    required this.targetId,
    required this.targetTitle,
    required this.targetPlatform,
    required this.message,
    this.attachmentName,
    required this.isSuccess,
    required this.statusCode,
    required this.latencyMs,
    this.errorDetail,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'profileName': profileName,
      'profileHandle': profileHandle,
      'profileAvatar': profileAvatar,
      'targetId': targetId,
      'targetTitle': targetTitle,
      'targetPlatform': targetPlatform,
      'message': message,
      'attachmentName': attachmentName,
      'isSuccess': isSuccess,
      'statusCode': statusCode,
      'latencyMs': latencyMs,
      'errorDetail': errorDetail,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DispatchRecord.fromMap(Map<String, dynamic> map) {
    return DispatchRecord(
      id: map['id'] ?? '',
      profileId: map['profileId'] ?? '',
      profileName: map['profileName'] ?? 'Sender',
      profileHandle: map['profileHandle'] ?? '@sender',
      profileAvatar: map['profileAvatar'] ?? 'robot',
      targetId: map['targetId'] ?? '',
      targetTitle: map['targetTitle'] ?? 'Destination',
      targetPlatform: map['targetPlatform'] ?? 'generic',
      message: map['message'] ?? '',
      attachmentName: map['attachmentName'],
      isSuccess: map['isSuccess'] ?? false,
      statusCode: map['statusCode'] ?? 200,
      latencyMs: map['latencyMs'] ?? 0,
      errorDetail: map['errorDetail'],
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory DispatchRecord.fromJson(String source) => DispatchRecord.fromMap(json.decode(source));
}
