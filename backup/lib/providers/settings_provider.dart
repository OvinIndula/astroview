import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  late SettingsModel _settings;
  bool _initialized = false;

  SettingsModel get settings {
    if (!_initialized) {
      _settings = _settingsService.getSettings();
      _initialized = true;
    }
    return _settings;
  }

  Future<void> init() async {
    await _settingsService.init();
    _settings = _settingsService.getSettings();
    _initialized = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await _settingsService.saveDarkMode(value);
    _settings = _settings.copyWith(darkMode: value);
    notifyListeners();
  }

  Future<void> setFontSize(FontSize size) async {
    await _settingsService.saveFontSize(size);
    _settings = _settings.copyWith(fontSize: size);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    await _settingsService.saveNotifications(value);
    _settings = _settings.copyWith(notificationsEnabled: value);
    notifyListeners();
  }

  Future<void> setViewPreference(ViewPreference preference) async {
    await _settingsService.saveViewPreference(preference);
    _settings = _settings.copyWith(viewPreference: preference);
    notifyListeners();
  }

  double getFontSizeValue() {
    switch (settings.fontSize) {
      case FontSize.small:
        return 12.0;
      case FontSize.medium:
        return 14.0;
      case FontSize.large:
        return 16.0;
    }
  }

  double getHeadlineFontSize() {
    switch (settings.fontSize) {
      case FontSize.small:
        return 18.0;
      case FontSize.medium:
        return 20.0;
      case FontSize.large:
        return 24.0;
    }
  }
}