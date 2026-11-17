import 'dart:async';

import 'package:auto_hub_app/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:auto_hub_app/features/settings/domain/models/app_settings.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SettingsRepository {
  @factoryMethod
  SettingsRepository.withDatasource(this._datasource);

  factory SettingsRepository() => getIt<SettingsRepository>();
  static SettingsRepository get instance => getIt<SettingsRepository>();

  final SettingsRemoteDatasource _datasource;

  AppSettings _settings = const AppSettings();

  final _settingsController = StreamController<AppSettings>.broadcast();
  Stream<AppSettings> get settingsStream => _settingsController.stream;
  AppSettings get currentSettings => _settings;

  void _updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    _settingsController.add(_settings);
  }

  Future<void> fetchSettings() async {
    try {
      final remote = await _datasource.getSettings();
      _updateSettings(remote);
    } catch (_) {}
  }

  Future<void> updatePushNotifications(bool value) async {
    _updateSettings(_settings.copyWith(pushNotifications: value));
    try {
      await _datasource.updateSettings({'pushNotifications': value});
    } catch (_) {}
  }

  Future<void> updateEmailNotifications(bool value) async {
    _updateSettings(_settings.copyWith(emailNotifications: value));
    try {
      await _datasource.updateSettings({'emailNotifications': value});
    } catch (_) {}
  }

  Future<void> updatePriceDropAlerts(bool value) async {
    _updateSettings(_settings.copyWith(priceDropAlerts: value));
    try {
      await _datasource.updateSettings({'priceDropAlerts': value});
    } catch (_) {}
  }

  Future<void> updateOrderUpdates(bool value) async {
    _updateSettings(_settings.copyWith(orderUpdates: value));
    try {
      await _datasource.updateSettings({'orderUpdates': value});
    } catch (_) {}
  }

  Future<void> updateChatMessages(bool value) async {
    _updateSettings(_settings.copyWith(chatMessages: value));
    try {
      await _datasource.updateSettings({'chatMessages': value});
    } catch (_) {}
  }

  Future<void> updateNotificationSounds(bool value) async {
    _updateSettings(_settings.copyWith(notificationSounds: value));
    try {
      await _datasource.updateSettings({'notificationSounds': value});
    } catch (_) {}
  }

  Future<void> updateVibration(bool value) async {
    _updateSettings(_settings.copyWith(vibration: value));
    try {
      await _datasource.updateSettings({'vibration': value});
    } catch (_) {}
  }

  Future<void> updateDarkMode(bool value) async {
    _updateSettings(_settings.copyWith(darkMode: value));
    try {
      await _datasource.updateSettings({'darkMode': value});
    } catch (_) {}
  }

  Future<void> updateAutoDistanceUnit(bool value) async {
    _updateSettings(_settings.copyWith(autoDistanceUnit: value));
    try {
      await _datasource.updateSettings({'autoDistanceUnit': value});
    } catch (_) {}
  }

  Future<void> updateLanguage(String language, String flag) async {
    _updateSettings(_settings.copyWith(
      selectedLanguage: language,
      selectedLanguageFlag: flag,
    ));
    try {
      await _datasource.updateSettings({'selectedLanguage': language});
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      return await _datasource.getLanguages();
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  Future<void> clearCache() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _updateSettings(_settings.copyWith(cacheSizeMb: 0));
  }

  Future<void> clearSearchHistory() async {
    // Handled locally or via user search history endpoint
  }

  Future<void> requestAccountDeletion() async {
    try {
      await _datasource.requestAccountDeletion(
        reason: 'user_request',
        confirmationText: 'DELETE',
      );
    } catch (_) {}
  }

  void dispose() {
    _settingsController.close();
  }
}
