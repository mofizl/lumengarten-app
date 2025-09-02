import 'package:go_router/go_router.dart';
import '../../features/splash/touch_to_start_page.dart';
import '../../features/landing/landing_page.dart';
import '../../features/garden/garden_page.dart';
import '../../features/games/games_page.dart';
import '../../features/games/game_area_page.dart';
import '../../features/games/reading/safari_adventure_game.dart';
import '../../features/games/writing/letter_tracing_game.dart';
import '../../features/games/logic/logic_games_page.dart';
import '../../features/games/logic/pattern_memory_game.dart';
import '../../features/games/logic/dunkis_labyrinth.dart';
import '../../features/games/logic/real_dunkis_labyrinth.dart';
import '../../features/games/logic/adventure_dunkis_labyrinth.dart';
import '../../features/games/math/number_counting_zoo.dart';
import '../../features/progress/progress_page.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.touchToStartRoute,
    routes: [
      GoRoute(
        path: AppConstants.touchToStartRoute,
        name: 'touch-to-start',
        builder: (context, state) => const TouchToStartPage(),
      ),
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
            builder: (context, state) => const SafariAdventureGame(),
          ),
          GoRoute(
            path: '/writing',
            name: 'writing-games', 
            builder: (context, state) => const LetterTracingGame(),
          ),
          GoRoute(
            path: '/logic',
            name: 'logic-games',
            builder: (context, state) => const LogicGamesPage(),
            routes: [
              GoRoute(
                path: '/pattern',
                name: 'pattern-memory',
                builder: (context, state) => const PatternMemoryGame(),
              ),
              GoRoute(
                path: '/labyrinth',
                name: 'dunkis-labyrinth',
                builder: (context, state) => const AdventureDunkisLabyrinth(),
              ),
            ],
          ),
          GoRoute(
            path: '/math',
            name: 'math-games',
            builder: (context, state) => const NumberCountingZoo(),
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