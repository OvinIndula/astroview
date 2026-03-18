import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../providers/settings_provider.dart';
import 'about_us_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  subtitle: Text('Toggle between light and dark themes'),
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
                  subtitle: Text('Receive alerts for new images'),
                  value: settingsProvider.settings.notificationsEnabled,
                  onChanged: (value) {
                    settingsProvider.setNotifications(value);
                  },
                ),
                Divider(),
                _buildSectionTitle(context, 'View Preferences'),
                ListTile(
                  title: Text('Default View'),
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
                // ✅ HEURISTIC #8: Help & Documentation
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AboutUsScreen()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8),
                            Text('About Us'),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _showHelpDialog(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.help_outline),
                            SizedBox(width: 8),
                            Text('Help & FAQ'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Version ${_getAppVersion()}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 16),
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

  String _getAppVersion() {
    return '1.0.2';
  }

  // ✅ HEURISTIC #8: Help & Documentation
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📚 Help & FAQ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFAQItem(
                'What is APOD?',
                'Astronomy Picture of the Day is a NASA service that features a different image from space each day.',
              ),
              _buildFAQItem(
                'How do I save favorites?',
                'Tap the ❤️ icon on any image to add it to your favorites.',
              ),
              _buildFAQItem(
                'Why aren\'t all photos loading?',
                'Photos are loaded in batches for faster performance. Tap "Load More" to see additional images.',
              ),
              _buildFAQItem(
                'Can I use this offline?',
                'Favorites are cached locally, but new photos require an internet connection.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}