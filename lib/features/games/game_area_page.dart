import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class GameAreaPage extends StatelessWidget {
  final String area;
  
  const GameAreaPage({super.key, required this.area});

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> areaConfig = {
      'reading': {
        'title': 'Lese-Abenteuer 📚',
        'emoji': '📖',
        'color': AppTheme.lightPurple,
        'games': ['Buchstaben-Safari', 'Wort-Puzzle', 'Silben-Roboter'],
      },
      'writing': {
        'title': 'Schreib-Werkstatt ✏️',
        'emoji': '✍️',
        'color': AppTheme.starYellow,
        'games': ['Finger-Tracing', 'Punkt-zu-Punkt', 'Wort-Baukasten'],
      },
      'logic': {
        'title': 'Logik-Labor 🧪',
        'emoji': '🧠',
        'color': AppTheme.magicGreen,
        'games': ['Muster-Memory', 'Sortier-Spiel', 'Puzzle-Palast'],
      },
      'math': {
        'title': 'Zahlen-Zoo 🦁',
        'emoji': '🔢',
        'color': AppTheme.primaryBlue,
        'games': ['Zähl-Safari', 'Zahlen-Memory', 'Plus-Minus-Park'],
      },
    };
    
    final config = areaConfig[area]!;
    final games = config['games'] as List<String>;
    
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
                    return _buildGameCard(
                      context,
                      title: games[index],
                      isLocked: index > 0, // Erstes Spiel freigeschaltet
                      stars: index == 0 ? 1 : 0, // Erstes Spiel hat einen Stern
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
    required String title,
    required bool isLocked,
    required int stars,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? AppTheme.lightGray : AppTheme.white,
        borderRadius: AppStyles.cardRadius,
        boxShadow: AppStyles.cardShadow,
        border: Border.all(
          color: isLocked ? AppTheme.moonSilver : color,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Spiel-Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isLocked ? AppTheme.moonSilver : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLocked ? Icons.lock : Icons.games,
              size: 30,
              color: isLocked ? AppTheme.darkGray : color,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Spiel-Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isLocked ? AppTheme.darkGray : color,
                    fontWeight: FontWeight.bold,
                  ),
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
              onPressed: () {
                // TODO: Start specific game
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Starte $title...'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Spielen'),
            ),
        ],
      ),
    );
  }
}