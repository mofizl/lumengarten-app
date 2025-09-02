import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Dunkis Echtes Labyrinth - Ein Flame-basiertes Logikspiel
class FlameMazeGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  
  // Game State
  late MazeWorld maze;
  late DunkiPlayer dunki;
  List<MazeCrystal> crystals = [];
  List<MazeFlower> flowers = [];
  late MazePortal exitPortal;
  
  int currentLevel = 1;
  int score = 0;
  int collectedCrystals = 0;
  bool gameCompleted = false;
  
  // Level Configuration
  final List<MazeConfig> levelConfigs = [
    MazeConfig(size: 5, crystals: 3, flowers: 2), // Level 1
    MazeConfig(size: 7, crystals: 5, flowers: 3), // Level 2
    MazeConfig(size: 9, crystals: 7, flowers: 4), // Level 3
    MazeConfig(size: 11, crystals: 10, flowers: 5), // Level 4
  ];
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize game world
    await _initializeLevel();
  }
  
  Future<void> _initializeLevel() async {
    // Clear existing components
    removeAll(children.whereType<MazeWorld>());
    removeAll(children.whereType<DunkiPlayer>());
    removeAll(children.whereType<MazeCrystal>());
    removeAll(children.whereType<MazeFlower>());
    removeAll(children.whereType<MazePortal>());
    
    final config = levelConfigs[currentLevel - 1];
    
    // Create maze world
    maze = MazeWorld(config.size);
    add(maze);
    
    // Create Dunki player at start position
    dunki = DunkiPlayer(Vector2(1, 1));
    add(dunki);
    
    // Clear and regenerate collectibles
    crystals.clear();
    flowers.clear();
    
    final random = math.Random();
    final mazeSize = config.size;
    
    // Place crystals
    for (int i = 0; i < config.crystals; i++) {
      Vector2 pos;
      do {
        pos = Vector2(
          (random.nextInt(mazeSize - 2) + 1).toDouble(),
          (random.nextInt(mazeSize - 2) + 1).toDouble(),
        );
      } while (maze.isWall(pos) || pos == Vector2(1, 1) || pos == Vector2(mazeSize - 2, mazeSize - 2));
      
      final crystal = MazeCrystal(pos, CrystalType.values[random.nextInt(CrystalType.values.length)]);
      crystals.add(crystal);
      add(crystal);
    }
    
    // Place flowers
    for (int i = 0; i < config.flowers; i++) {
      Vector2 pos;
      do {
        pos = Vector2(
          (random.nextInt(mazeSize - 2) + 1).toDouble(),
          (random.nextInt(mazeSize - 2) + 1).toDouble(),
        );
      } while (maze.isWall(pos) || pos == Vector2(1, 1) || pos == Vector2(mazeSize - 2, mazeSize - 2) ||
               crystals.any((c) => c.gridPosition == pos));
      
      final flower = MazeFlower(pos, FlowerType.values[random.nextInt(FlowerType.values.length)]);
      flowers.add(flower);
      add(flower);
    }
    
    // Create exit portal
    exitPortal = MazePortal(Vector2((mazeSize - 2).toDouble(), (mazeSize - 2).toDouble()));
    add(exitPortal);
  }
  
  void collectCrystal(MazeCrystal crystal) {
    crystal.removeFromParent();
    crystals.remove(crystal);
    collectedCrystals++;
    score += 100;
    
    // Check if all crystals collected
    if (crystals.isEmpty) {
      exitPortal.activate();
    }
  }
  
  void activateFlower(MazeFlower flower) {
    if (!flower.isActivated) {
      flower.activate();
      score += 50;
      
      // Flower effects could be added here
      // e.g., reveal hidden paths, teleport, etc.
    }
  }
  
  void reachExit() {
    if (exitPortal.isActive) {
      gameCompleted = true;
      score += 500;
      
      // Level completion logic
      if (currentLevel < levelConfigs.length) {
        // Next level
        Future.delayed(const Duration(seconds: 2), () {
          nextLevel();
        });
      }
    }
  }
  
  void nextLevel() {
    currentLevel++;
    collectedCrystals = 0;
    gameCompleted = false;
    _initializeLevel();
  }
}

/// Maze World Component - Handles the maze layout and rendering
class MazeWorld extends Component {
  final int size;
  late List<List<MazeTileType>> grid;
  
  MazeWorld(this.size) {
    _generateMaze();
  }
  
  void _generateMaze() {
    grid = List.generate(size, (i) => List.generate(size, (j) => MazeTileType.wall));
    
    // Simple maze generation - create paths
    for (int row = 1; row < size - 1; row++) {
      for (int col = 1; col < size - 1; col++) {
        if ((row + col) % 3 != 0 || (row == 1 && col == 1) || (row == size - 2 && col == size - 2)) {
          grid[row][col] = MazeTileType.path;
        }
      }
    }
    
    // Ensure path from start to end
    _ensurePath(Vector2(1, 1), Vector2(size - 2, size - 2));
  }
  
  void _ensurePath(Vector2 start, Vector2 end) {
    // Simple path ensuring - create direct path if needed
    int startRow = start.y.toInt();
    int startCol = start.x.toInt();
    int endRow = end.y.toInt();
    int endCol = end.x.toInt();
    
    // Horizontal path
    int minCol = math.min(startCol, endCol);
    int maxCol = math.max(startCol, endCol);
    for (int col = minCol; col <= maxCol; col++) {
      grid[startRow][col] = MazeTileType.path;
    }
    
    // Vertical path
    int minRow = math.min(startRow, endRow);
    int maxRow = math.max(startRow, endRow);
    for (int row = minRow; row <= maxRow; row++) {
      grid[row][endCol] = MazeTileType.path;
    }
  }
  
  bool isWall(Vector2 position) {
    int row = position.y.toInt();
    int col = position.x.toInt();
    
    if (row < 0 || row >= size || col < 0 || col >= size) {
      return true;
    }
    
    return grid[row][col] == MazeTileType.wall;
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    const double tileSize = 64.0;
    
    for (int row = 0; row < size; row++) {
      for (int col = 0; col < size; col++) {
        final rect = Rect.fromLTWH(
          col * tileSize,
          row * tileSize,
          tileSize,
          tileSize,
        );
        
        Paint paint = Paint();
        if (grid[row][col] == MazeTileType.wall) {
          paint.color = const Color(0xFF4A7C3C); // Green hedge color
        } else {
          paint.color = const Color(0xFFE8F5E8); // Light path color
        }
        
        canvas.drawRect(rect, paint);
        
        // Draw border
        paint.color = const Color(0xFF2D5C1F);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.0;
        canvas.drawRect(rect, paint);
      }
    }
  }
}

/// Dunki Player Component
class DunkiPlayer extends SpriteComponent with HasGameRef<FlameMazeGame> {
  Vector2 gridPosition;
  
  DunkiPlayer(this.gridPosition) : super(size: Vector2(60, 60));
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Load Dunki sprite
    sprite = await Sprite.load('games/labyrinth/dunki/dunki_happy.png');
    position = Vector2(gridPosition.x * 64 + 2, gridPosition.y * 64 + 2);
  }
  
  void moveInDirection(MoveDirection direction) {
    Vector2 newPos = Vector2(gridPosition.x, gridPosition.y);
    
    switch (direction) {
      case MoveDirection.up:
        newPos.y -= 1;
        break;
      case MoveDirection.down:
        newPos.y += 1;
        break;
      case MoveDirection.left:
        newPos.x -= 1;
        break;
      case MoveDirection.right:
        newPos.x += 1;
        break;
    }
    
    if (!gameRef.maze.isWall(newPos)) {
      gridPosition = newPos;
      position = Vector2(gridPosition.x * 64 + 2, gridPosition.y * 64 + 2);
      
      _checkCollisions();
    }
  }
  
  void _checkCollisions() {
    // Check crystal collection
    for (final crystal in gameRef.crystals) {
      if (crystal.gridPosition == gridPosition) {
        gameRef.collectCrystal(crystal);
        break;
      }
    }
    
    // Check flower activation
    for (final flower in gameRef.flowers) {
      if (flower.gridPosition == gridPosition) {
        gameRef.activateFlower(flower);
        break;
      }
    }
    
    // Check exit portal
    if (gameRef.exitPortal.gridPosition == gridPosition) {
      gameRef.reachExit();
    }
  }
}

/// Crystal Component
class MazeCrystal extends SpriteComponent {
  final Vector2 gridPosition;
  final CrystalType type;
  
  MazeCrystal(this.gridPosition, this.type) : super(size: Vector2(40, 40));
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    final typeStr = type.toString().split('.').last;
    sprite = await Sprite.load('games/labyrinth/crystals/individual/crystal_amethyst_pyramid_glowing.png');
    position = Vector2(gridPosition.x * 64 + 12, gridPosition.y * 64 + 12);
  }
}

/// Flower Component
class MazeFlower extends SpriteComponent {
  final Vector2 gridPosition;
  final FlowerType type;
  bool isActivated = false;
  
  MazeFlower(this.gridPosition, this.type) : super(size: Vector2(50, 50));
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    await _updateSprite();
    position = Vector2(gridPosition.x * 64 + 7, gridPosition.y * 64 + 7);
  }
  
  void activate() {
    isActivated = true;
    _updateSprite();
  }
  
  Future<void> _updateSprite() async {
    final typeStr = type.toString().split('.').last;
    final state = isActivated ? 'bloomed' : 'closed';
    sprite = await Sprite.load('games/labyrinth/flowers/individual/flower_${typeStr}_$state.png');
  }
}

/// Portal Component
class MazePortal extends SpriteComponent {
  final Vector2 gridPosition;
  bool isActive = false;
  
  MazePortal(this.gridPosition) : super(size: Vector2(60, 60));
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    await _updateSprite();
    position = Vector2(gridPosition.x * 64 + 2, gridPosition.y * 64 + 2);
  }
  
  void activate() {
    isActive = true;
    _updateSprite();
  }
  
  Future<void> _updateSprite() async {
    if (isActive) {
      sprite = await Sprite.load('games/labyrinth/portals/individual/portal_spring.png');
    } else {
      // Inactive portal - could be different sprite or dimmed
      sprite = await Sprite.load('games/labyrinth/portals/individual/portal_winter.png');
    }
  }
}

// Enums and Data Classes
enum MazeTileType { wall, path }
enum MoveDirection { up, down, left, right }
enum CrystalType { amethyst, emerald, sapphire, amber }
enum FlowerType { red, orange, green, yellow, blue, purple }

class MazeConfig {
  final int size;
  final int crystals;
  final int flowers;
  
  MazeConfig({required this.size, required this.crystals, required this.flowers});
}