import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import 'adventure_labyrinth_game.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_theme.dart';

/// Adventure Dunkis Labyrinth - Schönes, atmosphärisches Spiel
class AdventureDunkisLabyrinth extends StatefulWidget {
  const AdventureDunkisLabyrinth({super.key});

  @override
  State<AdventureDunkisLabyrinth> createState() => _AdventureDunkisLabyrinthState();
}

class _AdventureDunkisLabyrinthState extends State<AdventureDunkisLabyrinth> {
  late AdventureLabyrinthGame game;
  final VoiceService _voiceService = VoiceService();
  final Set<LogicalKeyboardKey> _pressedKeys = <LogicalKeyboardKey>{};

  @override
  void initState() {
    super.initState();
    game = AdventureLabyrinthGame();
    _voiceService.initialize();
    _voiceService.speak('Willkommen in Dunkis magischem Garten! Erkunde die wunderschöne Welt und sammle alle glitzernden Kristalle!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          children: [
            // Game Canvas - True Fullscreen
            Positioned.fill(
              child: GameWidget<AdventureLabyrinthGame>.controlled(
                gameFactory: () => game,
              ),
            ),
            // Back Button Overlay (top left)
            Positioned(
              top: 40,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 26, color: Colors.white),
                  onPressed: () => context.go('/games/logic'),
                ),
              ),
            ),
            // Score Overlay (top right)
            Positioned(
              top: 40,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.starYellow.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  '⭐ ${game.score}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // Game Info Overlay (top center-left)
            _buildGameOverlay(),
            // Simple Controls Hint (bottom center)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    '🎮 Pfeiltasten/WASD • 💎 Sammle Kristalle • 🌟 Finde das Portal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final isKeyDown = event is KeyDownEvent;
    final isKeyUp = event is KeyUpEvent;
    
    if (isKeyDown) {
      _pressedKeys.add(event.logicalKey);
    } else if (isKeyUp) {
      _pressedKeys.remove(event.logicalKey);
    }
    
    // Update movement based on currently pressed keys
    _updateMovement();
    
    return KeyEventResult.handled;
  }
  
  void _updateMovement() {
    if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp) || 
        _pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      game.requestMovement(MoveDirection.up);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown) || 
               _pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      game.requestMovement(MoveDirection.down);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.arrowLeft) || 
               _pressedKeys.contains(LogicalKeyboardKey.keyA)) {
      game.requestMovement(MoveDirection.left);
    } else if (_pressedKeys.contains(LogicalKeyboardKey.arrowRight) || 
               _pressedKeys.contains(LogicalKeyboardKey.keyD)) {
      game.requestMovement(MoveDirection.right);
    } else {
      game.stopMovement();
    }
  }


  Widget _buildGameOverlay() {
    return Positioned(
      top: 100,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.magicGreen.withOpacity(0.5), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.starYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.diamond, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'Kristalle: ${game.collectedCrystals}/3',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.magicGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flag, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  'Level ${game.currentLevel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    game.pauseEngine();
    super.dispose();
  }
}