import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile.dart';
import '../models/webhook_target.dart';

class DispatchResult {
  final bool isSuccess;
  final int statusCode;
  final int latencyMs;
  final String? errorMessage;
  final String responseBody;

  DispatchResult({
    required this.isSuccess,
    required this.statusCode,
    required this.latencyMs,
    this.errorMessage,
    required this.responseBody,
  });
}

class WebhookService {
  static Future<DispatchResult> send({
    required Profile profile,
    required WebhookTarget target,
    required String message,
    String? attachmentName,
    bool silent = false,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Check if it's a simulated demo URL
    if (target.url.contains('DemoTokenKey') ||
        target.url.contains('DemoSlackHookSecret') ||
        target.url.contains('demoEndpoint34')) {
      // Simulate realistic network delay for demo endpoints
      await Future.delayed(const Duration(milliseconds: 142));
      stopwatch.stop();
      return DispatchResult(
        isSuccess: true,
        statusCode: target.platform == 'discord' ? 204 : 200,
        latencyMs: stopwatch.elapsedMilliseconds,
        responseBody: '{"status":"ok","simulated":true}',
      );
    }

    try {
      final uri = Uri.parse(target.url);
      final headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body;

      if (target.platform == 'discord') {
        var content = message;
        if (attachmentName != null) {
          content += '\n📎 Attachment: $attachmentName';
        }
        body = {
          'content': content,
          'username': profile.displayName,
        };
        if (silent) {
          body['flags'] = 4096; // SUPPRESS_NOTIFICATIONS in Discord
        }
      } else if (target.platform == 'slack') {
        var text = '*${profile.displayName} (${profile.handle})*:\n$message';
        if (attachmentName != null) {
          text += '\n📎 Attached: $attachmentName';
        }
        body = {
          'text': text,
          'username': profile.displayName,
        };
      } else {
        // Generic Webhook format
        body = {
          'message': message,
          'sender': {
            'id': profile.id,
            'name': profile.displayName,
            'handle': profile.handle,
            'avatar': profile.avatarValue,
          },
          'attachment': attachmentName,
          'timestamp': DateTime.now().toIso8601String(),
          'client': 'HookDeck-Mobile-OG',
        };
      }

      final response = await http
          .post(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      stopwatch.stop();
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

      return DispatchResult(
        isSuccess: isSuccess,
        statusCode: response.statusCode,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: isSuccess ? null : 'Destination returned HTTP ${response.statusCode}',
        responseBody: response.body,
      );
    } catch (e) {
      stopwatch.stop();
      return DispatchResult(
        isSuccess: false,
        statusCode: 0,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: 'Connection failed: ${e.toString()}',
        responseBody: '',
      );
    }
  }

  static Future<DispatchResult> testPing(WebhookTarget target) async {
    final testProfile = Profile(
      id: 'test',
      displayName: 'HookDeck System Test',
      handle: '@hookdeck_test',
      avatarValue: 'bolt',
      createdAt: DateTime.now(),
    );

    return send(
      profile: testProfile,
      target: target,
      message: '⚡ Webhook connection verified from HookDeck Mobile!',
      silent: true,
    );
  }
}
