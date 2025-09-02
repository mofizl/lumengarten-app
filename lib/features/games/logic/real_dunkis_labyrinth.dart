import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import 'flame_labyrinth_game.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_theme.dart';

/// Echtes Dunkis Labyrinth - Flame-basiertes Logikspiel
class RealDunkisLabyrinth extends StatefulWidget {
  const RealDunkisLabyrinth({super.key});

  @override
  State<RealDunkisLabyrinth> createState() => _RealDunkisLabyrinthState();
}

class _RealDunkisLabyrinthState extends State<RealDunkisLabyrinth> {
  late FlameMazeGame game;
  final VoiceService _voiceService = VoiceService();

  @override
  void initState() {
    super.initState();
    game = FlameMazeGame();
    _voiceService.initialize();
    _voiceService.speak('Willkommen zu Dunkis echtem Labyrinth-Abenteuer! Sammle alle Kristalle und finde den Ausgang!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.magicGreen,
              AppTheme.crystalBlue,
              AppTheme.primaryBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.magicGreen, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      children: [
                        // Game Canvas
                        Positioned.fill(
                          child: GameWidget<FlameMazeGame>.controlled(
                            gameFactory: () => game,
                          ),
                        ),
                        // Game UI Overlay
                        _buildGameOverlay(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
            onPressed: () => context.go('/games/logic'),
          ),
          Expanded(
            child: Text(
              'Dunkis Labyrinth',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.starYellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '⭐ ${game.score}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverlay() {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.diamond, color: AppTheme.starYellow, size: 20),
            const SizedBox(width: 4),
            Text(
              '${game.collectedCrystals}/${game.crystals.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.flag, color: AppTheme.magicGreen, size: 20),
            const SizedBox(width: 4),
            Text(
              'Level ${game.currentLevel}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Sammle alle Kristalle und erreiche das Portal!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // D-Pad Controls
          Column(
            children: [
              // Up button
              _buildDirectionButton(
                icon: Icons.keyboard_arrow_up,
                onPressed: () => _movePlayer(MoveDirection.up),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left button
                  _buildDirectionButton(
                    icon: Icons.keyboard_arrow_left,
                    onPressed: () => _movePlayer(MoveDirection.left),
                  ),
                  const SizedBox(width: 60),
                  // Right button
                  _buildDirectionButton(
                    icon: Icons.keyboard_arrow_right,
                    onPressed: () => _movePlayer(MoveDirection.right),
                  ),
                ],
              ),
              // Down button
              _buildDirectionButton(
                icon: Icons.keyboard_arrow_down,
                onPressed: () => _movePlayer(MoveDirection.down),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Material(
        color: AppTheme.magicGreen.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  void _movePlayer(MoveDirection direction) {
    game.dunki.moveInDirection(direction);
    
    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    game.pauseEngine();
    super.dispose();
  }
}