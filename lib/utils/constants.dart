class AppConstants {
  static const String appName = 'AstroView';
  static const String appVersion = '1.0.2'; // Updated version
  static const String appDescription = 'Explore NASA\'s Astronomy Pictures of the Day';
  static const String nasaApiUrl = 'https://api.nasa.gov';
  static const String nasaApiKey = 'vPNpZu338bWCecteqaI3jPGAvPden2hZyGrd752o';
  
  // ✅ UI Constants for consistency (Heuristic #4)
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double cardElevation = 4.0;
  static const double cardBorderRadius = 16.0;
  
  // NEW: Error messages (Heuristic #9)
  static const String errorNoInternet = '📡 No internet connection. Please check your WiFi.';
  static const String errorTimeout = '⏱️ Connection timeout. Please try again.';
  static const String errorServer = '🔧 Server error. Please try again later.';
  static const String errorGeneric = '❌ Something went wrong. Please try again.';
}