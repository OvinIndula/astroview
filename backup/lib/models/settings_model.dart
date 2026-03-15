enum FontSize { small, medium, large }

enum ViewPreference { list, grid }

class SettingsModel {
  final bool darkMode;
  final FontSize fontSize;
  final bool notificationsEnabled;
  final ViewPreference viewPreference;

  SettingsModel({
    this.darkMode = false,
    this.fontSize = FontSize.medium,
    this.notificationsEnabled = true,
    this.viewPreference = ViewPreference.list,
  });

  SettingsModel copyWith({
    bool? darkMode,
    FontSize? fontSize,
    bool? notificationsEnabled,
    ViewPreference? viewPreference,
  }) {
    return SettingsModel(
      darkMode: darkMode ?? this.darkMode,
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      viewPreference: viewPreference ?? this.viewPreference,
    );
  }
}