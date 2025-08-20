import 'package:go_router/go_router.dart';
import '../../features/landing/landing_page.dart';
import '../../features/garden/garden_page.dart';
import '../../features/games/games_page.dart';
import '../../features/games/game_area_page.dart';
import '../../features/progress/progress_page.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.landingRoute,
    routes: [
      GoRoute(
        path: AppConstants.landingRoute,
        name: 'landing',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: AppConstants.gardenRoute,
        name: 'garden',
        builder: (context, state) => const GardenPage(),
      ),
      GoRoute(
        path: AppConstants.gamesRoute,
        name: 'games',
        builder: (context, state) => const GamesPage(),
        routes: [
          // Lernbereich-spezifische Routen
          GoRoute(
            path: '/reading',
            name: 'reading-games',
            builder: (context, state) => const GameAreaPage(area: 'reading'),
          ),
          GoRoute(
            path: '/writing',
            name: 'writing-games', 
            builder: (context, state) => const GameAreaPage(area: 'writing'),
          ),
          GoRoute(
            path: '/logic',
            name: 'logic-games',
            builder: (context, state) => const GameAreaPage(area: 'logic'),
          ),
          GoRoute(
            path: '/math',
            name: 'math-games',
            builder: (context, state) => const GameAreaPage(area: 'math'),
          ),
        ],
      ),
      GoRoute(
        path: AppConstants.progressRoute,
        name: 'progress',
        builder: (context, state) => const ProgressPage(),
      ),
    ],
  );
}