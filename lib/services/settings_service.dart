import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  late SharedPreferences _prefs;

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveDarkMode(bool value) async {
    await _prefs.setBool('darkMode', value);
  }

  Future<void> saveFontSize(FontSize size) async {
    await _prefs.setString('fontSize', size.toString());
  }

  Future<void> saveNotifications(bool value) async {
    await _prefs.setBool('notifications', value);
  }

  Future<void> saveViewPreference(ViewPreference preference) async {
    await _prefs.setString('viewPreference', preference.toString());
  }

  bool getDarkMode() {
    return _prefs.getBool('darkMode') ?? false;
  }

  FontSize getFontSize() {
    final sizeStr = _prefs.getString('fontSize') ?? 'FontSize.medium';
    if (sizeStr.contains('small')) return FontSize.small;
    if (sizeStr.contains('large')) return FontSize.large;
    return FontSize.medium;
  }

  bool getNotifications() {
    return _prefs.getBool('notifications') ?? true;
  }

  ViewPreference getViewPreference() {
    final prefStr = _prefs.getString('viewPreference') ?? 'ViewPreference.list';
    if (prefStr.contains('grid')) return ViewPreference.grid;
    return ViewPreference.list;
  }

  SettingsModel getSettings() {
    return SettingsModel(
      darkMode: getDarkMode(),
      fontSize: getFontSize(),
      notificationsEnabled: getNotifications(),
      viewPreference: getViewPreference(),
    );
  }
}