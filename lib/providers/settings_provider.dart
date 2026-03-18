import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  late SettingsModel _settings;
  bool _initialized = false;
  late SharedPreferences _prefs;  // ✅ NEW: For search history
  List<String> _searchHistory = [];  // ✅ NEW: Search history list

  SettingsModel get settings {
    if (!_initialized) {
      _settings = _settingsService.getSettings();
      _initialized = true;
    }
    return _settings;
  }

  List<String> get searchHistory => _searchHistory;  // ✅ NEW: Getter

  Future<void> init() async {
    await _settingsService.init();
    _settings = _settingsService.getSettings();
    _initialized = true;
    
    // ✅ NEW: Initialize search history
    _prefs = await SharedPreferences.getInstance();
    _searchHistory = _prefs.getStringList('searchHistory') ?? [];
    
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

  // ✅ NEW: Add search to history
  Future<void> addSearchHistory(String query) async {
    if (query.trim().isEmpty) return;

    query = query.trim();

    // Remove if already exists (so it appears at top)
    _searchHistory.removeWhere((s) => s.toLowerCase() == query.toLowerCase());

    // Add to front
    _searchHistory.insert(0, query);

    // Keep only last 10 searches
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }

    // Save to preferences
    await _prefs.setStringList('searchHistory', _searchHistory);
    notifyListeners();
  }

  // ✅ NEW: Clear search history
  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    await _prefs.remove('searchHistory');
    notifyListeners();
  }

  // ✅ NEW: Remove single search from history
  Future<void> removeFromSearchHistory(String query) async {
    _searchHistory.removeWhere((s) => s == query);
    await _prefs.setStringList('searchHistory', _searchHistory);
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