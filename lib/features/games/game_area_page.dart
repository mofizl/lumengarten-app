import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/voice_service.dart';
import 'reading/letter_safari_game.dart';

class GameAreaPage extends StatefulWidget {
  final String area;
  
  const GameAreaPage({super.key, required this.area});

  @override
  State<GameAreaPage> createState() => _GameAreaPageState();
}

class _GameAreaPageState extends State<GameAreaPage> {
  final VoiceService _voiceService = VoiceService();
  
  @override
  void initState() {
    super.initState();
    _welcomeToArea();
  }
  
  void _welcomeToArea() {
    final areaConfig = _getAreaConfig();
    Future.delayed(const Duration(milliseconds: 800), () {
      _voiceService.speak('Willkommen zu ${areaConfig['title']}! Wähle ein Spiel und sammle Sterne!');
    });
  }
  
  Map<String, dynamic> _getAreaConfig() {
    final Map<String, Map<String, dynamic>> areaConfig = {
      'reading': {
        'title': 'Lese-Abenteuer 📚',
        'emoji': '📖',
        'color': AppTheme.lightPurple,
        'games': [
          {'name': 'Buchstaben-Safari', 'id': 'letter_safari', 'implemented': true, 'description': 'Finde versteckte Buchstaben!'},
          {'name': 'Wort-Puzzle', 'id': 'word_puzzle', 'implemented': false, 'description': 'Verbinde Bilder mit Wörtern!'},
          {'name': 'Silben-Roboter', 'id': 'syllable_robot', 'implemented': false, 'description': 'Teile Wörter in Silben!'},
        ],
      },
      'writing': {
        'title': 'Schreib-Werkstatt ✏️',
        'emoji': '✍️',
        'color': AppTheme.starYellow,
        'games': [
          {'name': 'Finger-Nachfahren', 'id': 'finger_tracing', 'implemented': false, 'description': 'Fahre Buchstaben nach!'},
          {'name': 'Punkt zu Punkt', 'id': 'dot_to_dot', 'implemented': false, 'description': 'Verbinde die Punkte!'},
          {'name': 'Wort-Baukasten', 'id': 'word_builder', 'implemented': false, 'description': 'Baue Wörter aus Buchstaben!'},
        ],
      },
      'logic': {
        'title': 'Logik-Labor 🧪',
        'emoji': '🧠',
        'color': AppTheme.magicGreen,
        'games': [
          {'name': 'Muster-Memory', 'id': 'pattern_memory', 'implemented': false, 'description': 'Setze Muster fort!'},
          {'name': 'Sortier-Spiel', 'id': 'sorting_game', 'implemented': false, 'description': 'Sortiere nach Eigenschaften!'},
          {'name': 'Puzzle-Palast', 'id': 'puzzle_palace', 'implemented': false, 'description': 'Löse knifflige Puzzles!'},
        ],
      },
      'math': {
        'title': 'Zahlen-Zoo 🦁',
        'emoji': '🔢',
        'color': AppTheme.primaryBlue,
        'games': [
          {'name': 'Zähl-Safari', 'id': 'counting_safari', 'implemented': false, 'description': 'Zähle Tiere und Objekte!'},
          {'name': 'Zahlen-Memory', 'id': 'number_memory', 'implemented': false, 'description': 'Verbinde Zahlen mit Mengen!'},
          {'name': 'Rechen-Park', 'id': 'math_park', 'implemented': false, 'description': 'Erste Plus und Minus!'},
        ],
      },
    };
    
    return areaConfig[widget.area]!;
  }
  
  void _startGame(Map<String, dynamic> game) {
    if (game['implemented'] == true) {
      if (game['id'] == 'letter_safari') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LetterSafariGame(),
          ),
        );
      }
    } else {
      _showComingSoonDialog(game);
    }
  }
  
  void _showComingSoonDialog(Map<String, dynamic> game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🚀', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                game['name'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎮', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Dieses Spiel wird bald verfügbar sein!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              game['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getAreaConfig();
    final games = config['games'] as List<Map<String, dynamic>>;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(config['title']),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.gardenRoute),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (config['color'] as Color).withOpacity(0.3),
              AppTheme.white,
            ],
          ),
        ),
        child: Padding(
          padding: AppStyles.pagePadding,
          child: Column(
            children: [
              // Bereich-Header
              Container(
                width: double.infinity,
                padding: AppStyles.cardPadding,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: AppStyles.cardRadius,
                  boxShadow: AppStyles.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      config['emoji'],
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Wähle ein Spiel und sammle Sterne!',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Spiele-Liste
              Expanded(
                child: ListView.separated(
                  itemCount: games.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return _buildGameCard(
                      context,
                      game: game,
                      isLocked: !game['implemented'] && index > 0, // Erstes Spiel oder implementierte Spiele sind freigeschaltet
                      stars: game['implemented'] ? 1 : 0, // Implementierte Spiele haben einen Stern
                      color: config['color'] as Color,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGameCard(
    BuildContext context, {
    required Map<String, dynamic> game,
    required bool isLocked,
    required int stars,
    required Color color,
  }) {
    final bool isImplemented = game['implemented'] == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? AppTheme.lightGray : AppTheme.white,
        borderRadius: AppStyles.cardRadius,
        boxShadow: AppStyles.cardShadow,
        border: Border.all(
          color: isImplemented ? color : (isLocked ? AppTheme.moonSilver : Colors.orange),
          width: isImplemented ? 3 : 2,
        ),
      ),
      child: Row(
        children: [
          // Spiel-Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isLocked ? AppTheme.moonSilver : (isImplemented ? color.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isImplemented 
              ? Icon(
                  Icons.games,
                  size: 30,
                  color: color,
                )
              : isLocked
                ? Icon(
                    Icons.lock,
                    size: 30,
                    color: AppTheme.darkGray,
                  )
                : Icon(
                    Icons.construction,
                    size: 30,
                    color: Colors.orange,
                  ),
          ),
          
          const SizedBox(width: 16),
          
          // Spiel-Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game['name'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isLocked ? AppTheme.darkGray : (isImplemented ? color : Colors.orange.shade700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game['description'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(3, (index) {
                    return Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: index < stars ? AppTheme.starYellow : AppTheme.lightGray,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
          ),
          
          // Spielen Button
          if (!isLocked)
            ElevatedButton(
              onPressed: () => _startGame(game),
              style: ElevatedButton.styleFrom(
                backgroundColor: isImplemented ? color : Colors.orange,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(isImplemented ? 'Spielen' : 'Bald'),
            ),
        ],
      ),
    );
  }
}