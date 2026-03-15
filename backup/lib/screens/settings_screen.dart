import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../providers/settings_provider.dart';
import 'about_us_screen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            return ListView(
              children: [
                _buildSectionTitle(context, 'Appearance'),
                SwitchListTile(
                  title: Text('Dark Mode'),
                  value: settingsProvider.settings.darkMode,
                  onChanged: (value) {
                    settingsProvider.setDarkMode(value);
                  },
                ),
                ListTile(
                  title: Text('Font Size'),
                  subtitle: Text(_fontSizeName(settingsProvider.settings.fontSize)),
                  trailing: DropdownButton<FontSize>(
                    value: settingsProvider.settings.fontSize,
                    onChanged: (size) {
                      if (size != null) {
                        settingsProvider.setFontSize(size);
                      }
                    },
                    items: [
                      DropdownMenuItem(value: FontSize.small, child: Text('Small')),
                      DropdownMenuItem(value: FontSize.medium, child: Text('Default')),
                      DropdownMenuItem(value: FontSize.large, child: Text('Large')),
                    ],
                  ),
                ),
                Divider(),
                _buildSectionTitle(context, 'Notifications'),
                SwitchListTile(
                  title: Text('App Notifications'),
                  value: settingsProvider.settings.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.setNotifications(value);
                  },
                ),
                Divider(),
                _buildSectionTitle(context, 'View Preferences'),
                ListTile(
                  title: Text('List View'),
                  subtitle: Text(_viewPreferenceName(settingsProvider.settings.viewPreference)),
                  trailing: DropdownButton<ViewPreference>(
                    value: settingsProvider.settings.viewPreference,
                    onChanged: (pref) {
                      if (pref != null) {
                        settingsProvider.setViewPreference(pref);
                      }
                    },
                    items: [
                      DropdownMenuItem(value: ViewPreference.list, child: Text('List')),
                      DropdownMenuItem(value: ViewPreference.grid, child: Text('Grid')),
                    ],
                  ),
                ),
                Divider(),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AboutUsScreen()),
                      );
                    },
                    child: Text('About Us'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _fontSizeName(FontSize size) {
    switch (size) {
      case FontSize.small:
        return 'Small';
      case FontSize.medium:
        return 'Default';
      case FontSize.large:
        return 'Large';
    }
  }

  String _viewPreferenceName(ViewPreference pref) {
    switch (pref) {
      case ViewPreference.list:
        return 'List';
      case ViewPreference.grid:
        return 'Grid';
    }
  }
}