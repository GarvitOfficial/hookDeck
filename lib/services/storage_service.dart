import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';
import '../models/webhook_target.dart';
import '../models/dispatch_record.dart';

class StorageService extends ChangeNotifier {
  static const String _profilesKey = 'hookdeck_profiles_v1';
  static const String _webhooksKey = 'hookdeck_webhooks_v1';
  static const String _historyKey = 'hookdeck_history_v1';

  final _uuid = const Uuid();

  List<Profile> _profiles = [];
  List<WebhookTarget> _webhooks = [];
  List<DispatchRecord> _history = [];
  bool _isInitialized = false;

  List<Profile> get profiles => List.unmodifiable(_profiles);
  List<WebhookTarget> get webhooks => List.unmodifiable(_webhooks);
  List<DispatchRecord> get history => List.unmodifiable(_history);
  bool get isInitialized => _isInitialized;

  Profile? get primaryProfile {
    if (_profiles.isEmpty) return null;
    return _profiles.firstWhere((p) => p.isPrimary, orElse: () => _profiles.first);
  }

  StorageService() {
    init();
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final profilesJson = prefs.getStringList(_profilesKey);
    if (profilesJson != null && profilesJson.isNotEmpty) {
      _profiles = profilesJson.map((e) => Profile.fromJson(e)).toList();
    } else {
      // If first launch, we start clean or allow seeding!
      _profiles = [];
    }

    final webhooksJson = prefs.getStringList(_webhooksKey);
    if (webhooksJson != null && webhooksJson.isNotEmpty) {
      _webhooks = webhooksJson.map((e) => WebhookTarget.fromJson(e)).toList();
    } else {
      _webhooks = [];
    }

    final historyJson = prefs.getStringList(_historyKey);
    if (historyJson != null && historyJson.isNotEmpty) {
      _history = historyJson.map((e) => DispatchRecord.fromJson(e)).toList();
    } else {
      _history = [];
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Seed demo data for the rich luxury presentation
  Future<void> seedDemoData() async {
    final now = DateTime.now();
    _profiles = [
      Profile(
        id: _uuid.v4(),
        displayName: 'Garvit (Incident Ops)',
        handle: '@GarvitOfficial',
        avatarValue: 'brown',
        customImageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        isPrimary: true,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Profile(
        id: _uuid.v4(),
        displayName: 'Release Dispatcher',
        handle: '@release_ops',
        avatarValue: 'espresso',
        isPrimary: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Profile(
        id: _uuid.v4(),
        displayName: 'Security Audit Sentinel',
        handle: '@sentinel_ops',
        avatarValue: 'champagne',
        isPrimary: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    _webhooks = [
      WebhookTarget(
        id: _uuid.v4(),
        title: 'Team Announcements',
        url: 'https://discord.com/api/webhooks/109884729103847291/DemoTokenKeyAbc123',
        platform: 'discord',
        isFavorite: true,
        orderIndex: 0,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      WebhookTarget(
        id: _uuid.v4(),
        title: 'Production Incidents',
        url: 'https://hooks.slack.com/services/T00123/B00456/DemoSlackHookSecret999',
        platform: 'slack',
        isFavorite: true,
        orderIndex: 1,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      WebhookTarget(
        id: _uuid.v4(),
        title: 'Staging Alerts',
        url: 'https://webhook.site/4a298bf0-8901-4478-8311-demoEndpoint34',
        platform: 'generic',
        isFavorite: false,
        orderIndex: 2,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    _history = [
      DispatchRecord(
        id: _uuid.v4(),
        profileId: _profiles[0].id,
        profileName: 'Garvit (Incident Ops)',
        profileHandle: '@GarvitOfficial',
        profileAvatar: 'brown',
        targetId: _webhooks[0].id,
        targetTitle: 'Team Announcements',
        targetPlatform: 'discord',
        message: 'Deployment v2.4.1 completed across all regions • 0 alerts.',
        attachmentName: null,
        isSuccess: true,
        statusCode: 204,
        latencyMs: 128,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      DispatchRecord(
        id: _uuid.v4(),
        profileId: _profiles[1].id,
        profileName: 'Release Dispatcher',
        profileHandle: '@release_ops',
        profileAvatar: 'espresso',
        targetId: _webhooks[1].id,
        targetTitle: 'Production Incidents',
        targetPlatform: 'slack',
        message: 'Attached release_manifest.json for signoff.',
        attachmentName: 'release_manifest.json (24 KB)',
        isSuccess: true,
        statusCode: 200,
        latencyMs: 164,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    ];

    await _persistAll();
    notifyListeners();
  }

  // Clear all data to simulate fresh empty state
  Future<void> clearAll() async {
    _profiles = [];
    _webhooks = [];
    _history = [];
    await _persistAll();
    notifyListeners();
  }

  // ---------------- PROFILES ----------------
  Future<void> saveProfile(Profile profile) async {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      _profiles[index] = profile;
    } else {
      // If it's the first profile, set as primary
      if (_profiles.isEmpty) {
        profile = profile.copyWith(isPrimary: true);
      }
      _profiles.add(profile);
    }
    await _persistProfiles();
    notifyListeners();
  }

  Future<void> deleteProfile(String id) async {
    _profiles.removeWhere((p) => p.id == id);
    if (_profiles.isNotEmpty && !_profiles.any((p) => p.isPrimary)) {
      _profiles[0] = _profiles[0].copyWith(isPrimary: true);
    }
    await _persistProfiles();
    notifyListeners();
  }

  Future<void> setPrimaryProfile(String id) async {
    _profiles = _profiles.map((p) {
      return p.copyWith(isPrimary: p.id == id);
    }).toList();
    await _persistProfiles();
    notifyListeners();
  }

  // ---------------- WEBHOOKS ----------------
  Future<void> saveWebhook(WebhookTarget target) async {
    final index = _webhooks.indexWhere((w) => w.id == target.id);
    if (index >= 0) {
      _webhooks[index] = target;
    } else {
      _webhooks.add(target.copyWith(orderIndex: _webhooks.length));
    }
    await _persistWebhooks();
    notifyListeners();
  }

  Future<void> deleteWebhook(String id) async {
    _webhooks.removeWhere((w) => w.id == id);
    await _persistWebhooks();
    notifyListeners();
  }

  Future<void> toggleFavoriteWebhook(String id) async {
    final index = _webhooks.indexWhere((w) => w.id == id);
    if (index >= 0) {
      _webhooks[index] = _webhooks[index].copyWith(
        isFavorite: !_webhooks[index].isFavorite,
      );
      await _persistWebhooks();
      notifyListeners();
    }
  }

  Future<void> reorderWebhooks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _webhooks.removeAt(oldIndex);
    _webhooks.insert(newIndex, item);
    for (int i = 0; i < _webhooks.length; i++) {
      _webhooks[i] = _webhooks[i].copyWith(orderIndex: i);
    }
    await _persistWebhooks();
    notifyListeners();
  }

  // ---------------- HISTORY ----------------
  Future<void> addDispatch(DispatchRecord record) async {
    _history.insert(0, record);
    await _persistHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _persistHistory();
    notifyListeners();
  }

  // ---------------- PERSISTENCE HELPERS ----------------
  Future<void> _persistProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_profilesKey, _profiles.map((p) => p.toJson()).toList());
  }

  Future<void> _persistWebhooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_webhooksKey, _webhooks.map((w) => w.toJson()).toList());
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _history.map((h) => h.toJson()).toList());
  }

  Future<void> _persistAll() async {
    await _persistProfiles();
    await _persistWebhooks();
    await _persistHistory();
  }
}
