class AppConstants {
  static const String appName = 'Lumengarten';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String landingRoute = '/';
  static const String gardenRoute = '/garden';
  static const String gamesRoute = '/games';
  static const String progressRoute = '/progress';
  
  // Game Areas
  static const String readingGames = 'reading';
  static const String writingGames = 'writing';
  static const String logicGames = 'logic';
  static const String mathGames = 'math';
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Garden constants
  static const int maxStarsPerTask = 3;
  static const int plantsUnlockThreshold = 5;
}