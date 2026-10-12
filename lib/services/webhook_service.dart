import 'dart:convert';
import 'dart:typed_data';
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
    Uint8List? attachmentBytes,
    bool silent = false,
  }) async {
    final stopwatch = Stopwatch()..start();

    // Check if it's a simulated demo URL
    if (target.url.contains('DemoTokenKey') ||
        target.url.contains('DemoSlackHookSecret') ||
        target.url.contains('demoEndpoint34')) {
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

      // 1. DISCORD WEBHOOK WITH FILE (Real Multipart Upload)
      if (target.platform == 'discord') {
        if (attachmentBytes != null && attachmentBytes.isNotEmpty) {
          final request = http.MultipartRequest('POST', uri);

          final payloadJson = <String, dynamic>{
            'username': profile.displayName,
          };

          if (message.trim().isNotEmpty) {
            payloadJson['content'] = message.trim();
          }

          if (profile.customImageUrl != null && profile.customImageUrl!.trim().isNotEmpty) {
            payloadJson['avatar_url'] = profile.customImageUrl!.trim();
          }

          if (silent) {
            payloadJson['flags'] = 4096; // SUPPRESS_NOTIFICATIONS
          }

          request.fields['payload_json'] = json.encode(payloadJson);
          request.files.add(
            http.MultipartFile.fromBytes(
              'files[0]',
              attachmentBytes,
              filename: attachmentName ?? 'file',
            ),
          );

          final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
          final response = await http.Response.fromStream(streamedResponse);
          stopwatch.stop();

          final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
          return DispatchResult(
            isSuccess: isSuccess,
            statusCode: response.statusCode,
            latencyMs: stopwatch.elapsedMilliseconds,
            errorMessage: isSuccess ? null : 'Discord returned HTTP ${response.statusCode}: ${response.body}',
            responseBody: response.body,
          );
        } else {
          // Discord JSON dispatch
          final payload = <String, dynamic>{
            'content': message,
            'username': profile.displayName,
          };

          if (profile.customImageUrl != null && profile.customImageUrl!.trim().isNotEmpty) {
            payload['avatar_url'] = profile.customImageUrl!.trim();
          }

          if (silent) {
            payload['flags'] = 4096;
          }

          final response = await http
              .post(
                uri,
                headers: {'Content-Type': 'application/json'},
                body: json.encode(payload),
              )
              .timeout(const Duration(seconds: 10));

          stopwatch.stop();
          final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
          return DispatchResult(
            isSuccess: isSuccess,
            statusCode: response.statusCode,
            latencyMs: stopwatch.elapsedMilliseconds,
            errorMessage: isSuccess ? null : 'Discord returned HTTP ${response.statusCode}: ${response.body}',
            responseBody: response.body,
          );
        }
      }

      // 2. SLACK WEBHOOK
      if (target.platform == 'slack') {
        var text = '*${profile.displayName}* (${profile.handle}):\n$message';
        if (attachmentName != null) {
          text += '\n📎 Attached: $attachmentName';
        }

        final payload = <String, dynamic>{
          'text': text,
          'username': profile.displayName,
        };

        if (profile.customImageUrl != null && profile.customImageUrl!.trim().isNotEmpty) {
          payload['icon_url'] = profile.customImageUrl!.trim();
        }

        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 10));

        stopwatch.stop();
        final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
        return DispatchResult(
          isSuccess: isSuccess,
          statusCode: response.statusCode,
          latencyMs: stopwatch.elapsedMilliseconds,
          errorMessage: isSuccess ? null : 'Slack returned HTTP ${response.statusCode}: ${response.body}',
          responseBody: response.body,
        );
      }

      // 3. GENERIC HTTP WEBHOOK
      if (attachmentBytes != null && attachmentBytes.isNotEmpty) {
        final request = http.MultipartRequest('POST', uri);
        request.fields['message'] = message;
        request.fields['profile_id'] = profile.id;
        request.fields['profile_name'] = profile.displayName;
        request.fields['profile_handle'] = profile.handle;
        if (profile.customImageUrl != null) {
          request.fields['profile_avatar'] = profile.customImageUrl!;
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            attachmentBytes,
            filename: attachmentName ?? 'file',
          ),
        );
        final streamed = await request.send().timeout(const Duration(seconds: 15));
        final response = await http.Response.fromStream(streamed);
        stopwatch.stop();
        final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
        return DispatchResult(
          isSuccess: isSuccess,
          statusCode: response.statusCode,
          latencyMs: stopwatch.elapsedMilliseconds,
          errorMessage: isSuccess ? null : 'Endpoint returned HTTP ${response.statusCode}',
          responseBody: response.body,
        );
      } else {
        final payload = {
          'message': message,
          'sender': {
            'id': profile.id,
            'name': profile.displayName,
            'handle': profile.handle,
            'avatar': profile.customImageUrl ?? profile.avatarValue,
          },
          'timestamp': DateTime.now().toIso8601String(),
          'client': 'HookDeck',
        };

        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(payload),
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
      }
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
      avatarValue: 'brown',
      createdAt: DateTime.now(),
    );

    return send(
      profile: testProfile,
      target: target,
      message: '⚡ Webhook connection verified from HookDeck!',
      silent: true,
    );
  }
}
