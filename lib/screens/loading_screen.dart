import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/apod_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String _loadingMessage = 'Initializing AstroView...';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Initialize settings first
      final settingsProvider = context.read<SettingsProvider>();
      await settingsProvider.init();
      _updateMessage('Settings loaded...');

      final apodProvider = context.read<ApodProvider>();
      final favoritesProvider = context.read<FavoritesProvider>();

      // Load data in parallel
      _updateMessage('Fetching today\'s image...');
      await apodProvider.fetchTodayApod();

      _updateMessage('Loading recent photos... (this may take a moment)');
      await apodProvider.fetchRecentPhotos(days: 60);

      _updateMessage('Loading your favorites...');
      await favoritesProvider.loadFavorites();

      _updateMessage('Ready!');
      
      if (mounted) {
        await Future.delayed(Duration(seconds: 1));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      print('❌ Error during loading: $e');
      if (mounted) {
        await Future.delayed(Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    }
  }

  void _updateMessage(String message) {
    if (mounted) {
      setState(() => _loadingMessage = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[100],
              ),
              child: Center(
                child: Text(
                  'AstroView',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 20),
            Text(
              _loadingMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Please wait...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}