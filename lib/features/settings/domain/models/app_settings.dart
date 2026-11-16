import 'package:flutter/foundation.dart';

@immutable
class AppSettings {

  const AppSettings({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.priceDropAlerts = false,
    this.orderUpdates = true,
    this.chatMessages = true,
    this.notificationSounds = true,
    this.vibration = true,
    this.darkMode = true,
    this.autoDistanceUnit = true,
    this.selectedLanguage = 'English',
    this.selectedLanguageFlag = '🇺🇸',
    this.cacheSizeMb = 23.4,
  });
  // Notification States
  final bool pushNotifications;
  final bool emailNotifications;
  final bool priceDropAlerts;
  final bool orderUpdates;
  final bool chatMessages;

  // Sound & Haptics States
  final bool notificationSounds;
  final bool vibration;

  // Appearance States
  final bool darkMode;
  final bool autoDistanceUnit;
  final String selectedLanguage;
  final String selectedLanguageFlag;

  // Cache State
  final double cacheSizeMb;

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      priceDropAlerts: json['priceDropAlerts'] as bool? ?? false,
      orderUpdates: json['orderUpdates'] as bool? ?? true,
      chatMessages: json['chatMessages'] as bool? ?? true,
      notificationSounds: json['notificationSounds'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? true,
      autoDistanceUnit: json['autoDistanceUnit'] as bool? ?? true,
      selectedLanguage: json['selectedLanguage'] as String? ?? 'English',
      selectedLanguageFlag: json['selectedLanguageFlag'] as String? ?? '🇺🇸',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'priceDropAlerts': priceDropAlerts,
      'orderUpdates': orderUpdates,
      'chatMessages': chatMessages,
      'notificationSounds': notificationSounds,
      'vibration': vibration,
      'darkMode': darkMode,
      'autoDistanceUnit': autoDistanceUnit,
      'selectedLanguage': selectedLanguage,
      'selectedLanguageFlag': selectedLanguageFlag,
    };
  }

  AppSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? priceDropAlerts,
    bool? orderUpdates,
    bool? chatMessages,
    bool? notificationSounds,
    bool? vibration,
    bool? darkMode,
    bool? autoDistanceUnit,
    String? selectedLanguage,
    String? selectedLanguageFlag,
    double? cacheSizeMb,
  }) {
    return AppSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      priceDropAlerts: priceDropAlerts ?? this.priceDropAlerts,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      chatMessages: chatMessages ?? this.chatMessages,
      notificationSounds: notificationSounds ?? this.notificationSounds,
      vibration: vibration ?? this.vibration,
      darkMode: darkMode ?? this.darkMode,
      autoDistanceUnit: autoDistanceUnit ?? this.autoDistanceUnit,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedLanguageFlag: selectedLanguageFlag ?? this.selectedLanguageFlag,
      cacheSizeMb: cacheSizeMb ?? this.cacheSizeMb,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          pushNotifications == other.pushNotifications &&
          emailNotifications == other.emailNotifications &&
          priceDropAlerts == other.priceDropAlerts &&
          orderUpdates == other.orderUpdates &&
          chatMessages == other.chatMessages &&
          notificationSounds == other.notificationSounds &&
          vibration == other.vibration &&
          darkMode == other.darkMode &&
          autoDistanceUnit == other.autoDistanceUnit &&
          selectedLanguage == other.selectedLanguage &&
          selectedLanguageFlag == other.selectedLanguageFlag &&
          cacheSizeMb == other.cacheSizeMb;

  @override
  int get hashCode =>
      pushNotifications.hashCode ^
      emailNotifications.hashCode ^
      priceDropAlerts.hashCode ^
      orderUpdates.hashCode ^
      chatMessages.hashCode ^
      notificationSounds.hashCode ^
      vibration.hashCode ^
      darkMode.hashCode ^
      autoDistanceUnit.hashCode ^
      selectedLanguage.hashCode ^
      selectedLanguageFlag.hashCode ^
      cacheSizeMb.hashCode;
}
