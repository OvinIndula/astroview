import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/apod_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'services/settings_service.dart';
import 'screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsService = SettingsService();
  await settingsService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApodProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      builder: (context, _) {
        return Consumer<SettingsProvider>(
          builder: (context, settingsProvider, _) {
            return MaterialApp(
              title: 'AstroView',
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: Brightness.dark,
                ),
              ),
              themeMode: settingsProvider.settings.darkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: LoadingScreen(),
              debugShowCheckedModeBanner: false, // ✅ NEW: Remove debug banner
            );
          },
        );
      },
    );
  }
}