import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Labyrinth Configuration
class LabyrinthConfig {
  static const int mazeWidth = 21;  // Must be odd for proper maze generation
  static const int mazeHeight = 15; // Must be odd for proper maze generation
  static const double tileSize = 56.0; // Larger tiles for better visibility
  
  // Tile types
  static const int wall = 1;
  static const int path = 0;
  static const int crystal = 2;
  static const int flower = 3;
  static const int portal = 4;
}

/// Dunkis Adventure Labyrinth - Tile-basiertes Labyrinth mit ChatGPT-Assets
class AdventureLabyrinthGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  
  // Game State
  late DunkiCharacter dunki;
  List<MagicCrystal> crystals = [];
  List<MagicFlower> flowers = [];
  late ExitPortal exitPortal;
  late LabyrinthMap labyrinthMap;
  
  int currentLevel = 1;
  int score = 0;
  int collectedCrystals = 0;
  bool gameCompleted = false;
  
  // Camera and world setup
  double cameraZoom = 0.7; // Zoom out more for better fullscreen utilization
  
  // Maze data - 2D array representing the maze
  List<List<int>> mazeData = [];
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Set up camera
    camera.viewfinder.zoom = cameraZoom;
    
    await _initializeLevel();
  }
  
  Future<void> _initializeLevel() async {
    // Clear everything
    removeAll(children);
    crystals.clear();
    flowers.clear();
    
    // Generate maze layout
    _generateMaze();
    
    // Create labyrinth map component
    labyrinthMap = LabyrinthMap(mazeData);
    add(labyrinthMap);
    
    // Find starting position (should be at 1,1)
    final startPos = Vector2(
      LabyrinthConfig.tileSize * 1 + LabyrinthConfig.tileSize / 2,
      LabyrinthConfig.tileSize * 1 + LabyrinthConfig.tileSize / 2
    );
    
    // Create Dunki at starting position
    dunki = DunkiCharacter(startPos);
    add(dunki);
    
    // Place crystals in maze
    await _placeCrystalsInMaze();
    
    // Place flowers in maze  
    await _placeFlowersInMaze();
    
    // Find and place exit portal
    final exitPos = Vector2(
      LabyrinthConfig.tileSize * (LabyrinthConfig.mazeWidth - 2) + LabyrinthConfig.tileSize / 2,
      LabyrinthConfig.tileSize * (LabyrinthConfig.mazeHeight - 2) + LabyrinthConfig.tileSize / 2
    );
    exitPortal = ExitPortal(exitPos);
    add(exitPortal);
    
    // Center camera on the maze
    final mazeWorldSize = Vector2(
      LabyrinthConfig.mazeWidth * LabyrinthConfig.tileSize,
      LabyrinthConfig.mazeHeight * LabyrinthConfig.tileSize
    );
    
    // Focus camera on center of maze
    camera.viewfinder.position = mazeWorldSize / 2;
  }
  
  // Generate a simple maze using randomized depth-first search
  void _generateMaze() {
    // Initialize maze with all walls
    mazeData = List.generate(
      LabyrinthConfig.mazeHeight, 
      (y) => List.generate(LabyrinthConfig.mazeWidth, (x) => LabyrinthConfig.wall)
    );
    
    // Simple maze generation - create paths manually for now
    // This creates a simple but playable maze
    for (int y = 1; y < LabyrinthConfig.mazeHeight - 1; y += 2) {
      for (int x = 1; x < LabyrinthConfig.mazeWidth - 1; x += 2) {
        mazeData[y][x] = LabyrinthConfig.path;
        
        // Create some horizontal and vertical connections
        if (x < LabyrinthConfig.mazeWidth - 3 && math.Random().nextBool()) {
          mazeData[y][x + 1] = LabyrinthConfig.path;
        }
        if (y < LabyrinthConfig.mazeHeight - 3 && math.Random().nextBool()) {
          mazeData[y + 1][x] = LabyrinthConfig.path;
        }
      }
    }
    
    // Ensure start and end positions are clear
    mazeData[1][1] = LabyrinthConfig.path; // Start position
    mazeData[LabyrinthConfig.mazeHeight - 2][LabyrinthConfig.mazeWidth - 2] = LabyrinthConfig.path; // End position
    
    // Create a guaranteed path from start to end
    _ensurePathToExit();
  }
  
  void _ensurePathToExit() {
    // Simple path creation from start to end
    int x = 1, y = 1;
    final endX = LabyrinthConfig.mazeWidth - 2;
    final endY = LabyrinthConfig.mazeHeight - 2;
    
    while (x < endX || y < endY) {
      mazeData[y][x] = LabyrinthConfig.path;
      if (x < endX && (y >= endY || math.Random().nextBool())) {
        x++;
      } else if (y < endY) {
        y++;
      }
    }
  }
  
  Future<void> _placeCrystalsInMaze() async {
    final random = math.Random();
    final pathTiles = <Vector2>[];
    
    // Find all path tiles
    for (int y = 1; y < LabyrinthConfig.mazeHeight - 1; y++) {
      for (int x = 1; x < LabyrinthConfig.mazeWidth - 1; x++) {
        if (mazeData[y][x] == LabyrinthConfig.path) {
          pathTiles.add(Vector2(x.toDouble(), y.toDouble()));
        }
      }
    }
    
    // Place 5-8 crystals randomly
    final numCrystals = 5 + random.nextInt(4);
    for (int i = 0; i < numCrystals && pathTiles.isNotEmpty; i++) {
      final tileIndex = random.nextInt(pathTiles.length);
      final tile = pathTiles[tileIndex];
      pathTiles.removeAt(tileIndex);
      
      final worldPos = Vector2(
        tile.x * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2,
        tile.y * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2
      );
      
      final crystal = MagicCrystal(worldPos, i % 4); // Different crystal types
      crystals.add(crystal);
      add(crystal);
    }
  }
  
  Future<void> _placeFlowersInMaze() async {
    final random = math.Random();
    final pathTiles = <Vector2>[];
    
    // Find all path tiles (avoiding crystal positions)
    for (int y = 1; y < LabyrinthConfig.mazeHeight - 1; y++) {
      for (int x = 1; x < LabyrinthConfig.mazeWidth - 1; x++) {
        if (mazeData[y][x] == LabyrinthConfig.path) {
          final worldPos = Vector2(
            x * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2,
            y * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2
          );
          
          // Check if position is not too close to crystals
          bool tooClose = false;
          for (final crystal in crystals) {
            if ((crystal.position - worldPos).length < LabyrinthConfig.tileSize * 1.5) {
              tooClose = true;
              break;
            }
          }
          
          if (!tooClose) {
            pathTiles.add(Vector2(x.toDouble(), y.toDouble()));
          }
        }
      }
    }
    
    // Place 3-5 flowers randomly
    final numFlowers = 3 + random.nextInt(3);
    for (int i = 0; i < numFlowers && pathTiles.isNotEmpty; i++) {
      final tileIndex = random.nextInt(pathTiles.length);
      final tile = pathTiles[tileIndex];
      pathTiles.removeAt(tileIndex);
      
      final worldPos = Vector2(
        tile.x * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2,
        tile.y * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2
      );
      
      final flower = MagicFlower(worldPos, i % 6); // Different flower colors
      flowers.add(flower);
      add(flower);
    }
  }
  
  void collectCrystal(MagicCrystal crystal) {
    crystal.removeFromParent();
    crystals.remove(crystal);
    collectedCrystals++;
    score += 100;
    
    // Check if all crystals collected
    if (crystals.isEmpty) {
      exitPortal.activate();
    }
  }
  
  void activateFlower(MagicFlower flower) {
    if (!flower.isActivated) {
      flower.activate();
      score += 50;
    }
  }
  
  void reachExit() {
    if (exitPortal.isActive) {
      gameCompleted = true;
      score += 500;
      
      // Simple restart after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        _initializeLevel();
      });
    }
  }
  
  // Method to control dunki movement from outside
  void moveDunki(MoveDirection direction) {
    if (isLoaded && hasChildren) {
      dunki.moveInDirection(direction);
    }
  }
  
  void stopDunki() {
    if (isLoaded && hasChildren) {
      dunki.stop();
    }
  }

  // New methods for continuous movement
  void requestMovement(MoveDirection direction) {
    if (isLoaded && hasChildren) {
      dunki.requestContinuousMovement(direction);
    }
  }
  
  void stopMovement() {
    if (isLoaded && hasChildren) {
      dunki.stopContinuousMovement();
    }
  }
}

/// Labyrinth Map Component - Renders the tile-based maze
class LabyrinthMap extends Component with HasGameRef<AdventureLabyrinthGame> {
  final List<List<int>> mazeData;
  late Sprite wallSprite;
  late Sprite pathSprite;
  bool spritesLoaded = false;
  
  LabyrinthMap(this.mazeData);
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    try {
      // Try to load individual hedge wall sprite
      wallSprite = await Sprite.load('games/labyrinth/tiles/individual/hedge_spring_straight.png');
      // For path, we'll use a simple ground texture 
      pathSprite = await Sprite.load('games/labyrinth/backgrounds/individual/bg_grass_mound.png');
      spritesLoaded = true;
    } catch (e) {
      // Fallback to simple colored rectangles
      spritesLoaded = false;
    }
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    for (int y = 0; y < LabyrinthConfig.mazeHeight; y++) {
      for (int x = 0; x < LabyrinthConfig.mazeWidth; x++) {
        final tileX = x * LabyrinthConfig.tileSize;
        final tileY = y * LabyrinthConfig.tileSize;
        
        if (mazeData[y][x] == LabyrinthConfig.wall) {
          if (spritesLoaded) {
            // Render wall sprite
            wallSprite.render(
              canvas,
              size: Vector2.all(LabyrinthConfig.tileSize),
              position: Vector2(tileX, tileY),
            );
          } else {
            // Fallback: green rectangle for walls
            final paint = Paint()..color = const Color(0xFF2E7D32);
            canvas.drawRect(
              Rect.fromLTWH(tileX, tileY, LabyrinthConfig.tileSize, LabyrinthConfig.tileSize),
              paint,
            );
          }
        } else {
          // Path tile - light green background
          final paint = Paint()..color = const Color(0xFF81C784);
          canvas.drawRect(
            Rect.fromLTWH(tileX, tileY, LabyrinthConfig.tileSize, LabyrinthConfig.tileSize),
            paint,
          );
        }
      }
    }
  }
}

/// Simple Background - Just colors (kept for compatibility)
class SimpleBackground extends RectangleComponent {
  SimpleBackground(Vector2 screenSize) {
    size = screenSize;
    position = Vector2.zero();
  }
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Beautiful gradient background
    paint = Paint()..color = const Color(0xFF87CEEB); // Sky blue
  }
  
  @override
  void render(Canvas canvas) {
    // Draw gradient background
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF87CEEB), // Sky blue
        const Color(0xFF98FB98), // Pale green
      ],
    );
    
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }
}

/// Dunki Character - Tile-based movement with ChatGPT sprites
class DunkiCharacter extends SpriteComponent with HasGameRef<AdventureLabyrinthGame> {
  Vector2 targetPosition = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200.0;
  bool isMoving = false;
  
  // Continuous movement
  MoveDirection? currentDirection;
  double movementCooldown = 0.0;
  final double moveInterval = 0.2; // Move to next tile every 200ms
  
  // Sprite management
  late Sprite happySprite;
  late Sprite walkingSprite1;
  late Sprite walkingSprite2;
  late Sprite celebratingSprite;
  bool spritesLoaded = false;
  
  // Animation
  double animationTimer = 0.0;
  bool useWalkingSprite1 = true;
  
  DunkiCharacter(Vector2 startPosition) : super(size: Vector2(48, 48)) {
    position = startPosition;
    targetPosition = startPosition;
    anchor = Anchor.center;
  }
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    try {
      // Load Dunki sprites
      happySprite = await Sprite.load('games/labyrinth/dunki/dunki_happy.png');
      walkingSprite1 = await Sprite.load('games/labyrinth/dunki/dunki_walking_1.png');
      walkingSprite2 = await Sprite.load('games/labyrinth/dunki/dunki_walking_2.png');
      celebratingSprite = await Sprite.load('games/labyrinth/dunki/dunki_celebrating.png');
      
      sprite = happySprite;
      spritesLoaded = true;
    } catch (e) {
      // Fallback to colored circle
      final paint = Paint()..color = Colors.orange;
      sprite = null;
      spritesLoaded = false;
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Handle continuous movement
    if (currentDirection != null && !isMoving) {
      movementCooldown -= dt;
      if (movementCooldown <= 0) {
        _tryMoveInDirection(currentDirection!);
        movementCooldown = moveInterval;
      }
    }
    
    if (isMoving) {
      // Move towards target position
      final direction = (targetPosition - position).normalized();
      velocity = direction * moveSpeed;
      position += velocity * dt;
      
      // Walking animation
      animationTimer += dt;
      if (animationTimer >= 0.25) { // Switch every 250ms for smoother animation
        useWalkingSprite1 = !useWalkingSprite1;
        animationTimer = 0.0;
        
        if (spritesLoaded) {
          sprite = useWalkingSprite1 ? walkingSprite1 : walkingSprite2;
        }
      }
      
      // Check if we've reached the target
      if ((targetPosition - position).length < 2.0) {
        position = targetPosition;
        isMoving = false;
        velocity = Vector2.zero();
        
        // Only stop animation if no direction is pressed
        if (currentDirection == null && spritesLoaded) {
          sprite = happySprite;
        }
      }
    } else if (currentDirection == null && spritesLoaded) {
      // Not moving and no direction pressed - show happy sprite
      sprite = happySprite;
    }
    
    // Check collisions
    _checkCollisions();
  }
  
  void moveInDirection(MoveDirection direction) {
    if (isMoving) return; // Already moving, ignore input
    
    // Calculate current tile position - use floor to get the tile we're in
    final currentTileX = (position.x / LabyrinthConfig.tileSize).floor();
    final currentTileY = (position.y / LabyrinthConfig.tileSize).floor();
    
    // Calculate target tile position
    int targetTileX = currentTileX;
    int targetTileY = currentTileY;
    
    switch (direction) {
      case MoveDirection.up:
        targetTileY--;
        break;
      case MoveDirection.down:
        targetTileY++;
        break;
      case MoveDirection.left:
        targetTileX--;
        break;
      case MoveDirection.right:
        targetTileX++;
        break;
    }
    
    // Check if target position is valid (within bounds and not a wall)
    if (_canMoveTo(targetTileX, targetTileY)) {
      targetPosition = Vector2(
        targetTileX * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2,
        targetTileY * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2
      );
      isMoving = true;
      
      if (spritesLoaded) {
        sprite = walkingSprite1; // Start with first walking sprite
        animationTimer = 0.0;
        useWalkingSprite1 = true;
      }
    }
  }
  
  bool _canMoveTo(int tileX, int tileY) {
    // Check bounds
    if (tileX < 0 || tileX >= LabyrinthConfig.mazeWidth ||
        tileY < 0 || tileY >= LabyrinthConfig.mazeHeight) {
      return false;
    }
    
    // Check if it's a wall - only allow movement on path tiles
    return gameRef.mazeData[tileY][tileX] == LabyrinthConfig.path;
  }
  
  void stop() {
    // In tile-based movement, we don't stop mid-tile
    // Movement stops naturally when reaching target
  }

  // Continuous movement methods
  void requestContinuousMovement(MoveDirection direction) {
    currentDirection = direction;
    // If not currently moving, start immediately
    if (!isMoving) {
      _tryMoveInDirection(direction);
      movementCooldown = moveInterval;
    }
  }
  
  void stopContinuousMovement() {
    currentDirection = null;
  }
  
  void _tryMoveInDirection(MoveDirection direction) {
    // Calculate current tile position - use floor to get the tile we're in
    final currentTileX = (position.x / LabyrinthConfig.tileSize).floor();
    final currentTileY = (position.y / LabyrinthConfig.tileSize).floor();
    
    // Calculate target tile position
    int targetTileX = currentTileX;
    int targetTileY = currentTileY;
    
    switch (direction) {
      case MoveDirection.up:
        targetTileY--;
        break;
      case MoveDirection.down:
        targetTileY++;
        break;
      case MoveDirection.left:
        targetTileX--;
        break;
      case MoveDirection.right:
        targetTileX++;
        break;
    }
    
    // Check if target position is valid (within bounds and not a wall)
    if (_canMoveTo(targetTileX, targetTileY)) {
      targetPosition = Vector2(
        targetTileX * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2,
        targetTileY * LabyrinthConfig.tileSize + LabyrinthConfig.tileSize / 2
      );
      isMoving = true;
      
      if (spritesLoaded) {
        sprite = walkingSprite1; // Start with first walking sprite
        animationTimer = 0.0;
        useWalkingSprite1 = true;
      }
    }
  }
  
  void _checkCollisions() {
    // Check crystal collection
    for (final crystal in gameRef.crystals.toList()) {
      if ((crystal.position - position).length < 50) {
        gameRef.collectCrystal(crystal);
        break;
      }
    }
    
    // Check flower activation
    for (final flower in gameRef.flowers) {
      if ((flower.position - position).length < 50) {
        gameRef.activateFlower(flower);
        break;
      }
    }
    
    // Check exit portal
    if ((gameRef.exitPortal.position - position).length < 60) {
      gameRef.reachExit();
    }
  }
}

/// Magic Crystal with ChatGPT sprites
class MagicCrystal extends SpriteComponent with HasGameRef<AdventureLabyrinthGame> {
  double glitterTimer = 0.0;
  final int crystalType; // 0=amethyst, 1=emerald, 2=sapphire, 3=amber
  bool collected = false;
  
  MagicCrystal(Vector2 position, this.crystalType) : super(size: Vector2(40, 40)) {
    this.position = position;
    anchor = Anchor.center;
  }
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Select sprite based on crystal type
    try {
      String spritePath;
      switch (crystalType) {
        case 0:
          spritePath = 'games/labyrinth/crystals/individual/crystal_amethyst_sphere_glowing.png';
          break;
        case 1:
          spritePath = 'games/labyrinth/crystals/individual/crystal_emerald_cube_glowing.png';
          break;
        case 2:
          spritePath = 'games/labyrinth/crystals/individual/crystal_sapphire_sphere_glowing.png';
          break;
        case 3:
          spritePath = 'games/labyrinth/crystals/individual/crystal_amber_pyramid_glowing.png';
          break;
        default:
          spritePath = 'games/labyrinth/crystals/individual/crystal_amethyst_sphere_glowing.png';
      }
      
      sprite = await Sprite.load(spritePath);
    } catch (e) {
      // Fallback to colored circle
      sprite = null;
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!collected) {
      // Gentle pulsing animation
      glitterTimer += dt;
      final pulseFactor = math.sin(glitterTimer * 3) * 0.1 + 1.0;
      scale = Vector2.all(pulseFactor);
    }
  }
  
  @override
  void render(Canvas canvas) {
    if (sprite == null && !collected) {
      // Fallback rendering
      final paint = Paint()..color = _getCrystalColor().withOpacity(0.8);
      canvas.drawCircle(Offset.zero, 12, paint);
    }
    super.render(canvas);
  }
  
  Color _getCrystalColor() {
    switch (crystalType) {
      case 0: return Colors.purple;
      case 1: return Colors.green;
      case 2: return Colors.blue;
      case 3: return Colors.amber;
      default: return Colors.purple;
    }
  }
}

/// Magic Flower with ChatGPT sprites
class MagicFlower extends SpriteComponent with HasGameRef<AdventureLabyrinthGame> {
  bool isActivated = false;
  final int flowerType; // 0=red, 1=orange, 2=yellow, 3=green, 4=blue, 5=purple
  late Sprite closedSprite;
  late Sprite bloomedSprite;
  bool spritesLoaded = false;
  
  MagicFlower(Vector2 position, this.flowerType) : super(size: Vector2(35, 35)) {
    this.position = position;
    anchor = Anchor.center;
  }
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    try {
      // Load both closed and bloomed states
      String colorName;
      switch (flowerType) {
        case 0: colorName = 'red'; break;
        case 1: colorName = 'orange'; break;  
        case 2: colorName = 'yellow'; break;
        case 3: colorName = 'green'; break;
        case 4: colorName = 'blue'; break;
        case 5: colorName = 'purple'; break;
        default: colorName = 'red';
      }
      
      closedSprite = await Sprite.load('games/labyrinth/flowers/individual/flower_${colorName}_closed.png');
      bloomedSprite = await Sprite.load('games/labyrinth/flowers/individual/flower_${colorName}_bloomed.png');
      
      sprite = closedSprite;
      spritesLoaded = true;
    } catch (e) {
      // Fallback to colored circle
      sprite = null;
      spritesLoaded = false;
    }
  }
  
  void activate() {
    if (!isActivated) {
      isActivated = true;
      if (spritesLoaded) {
        sprite = bloomedSprite;
      }
      scale = Vector2.all(1.2); // Make it bigger when activated
    }
  }
  
  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      // Fallback rendering
      final paint = Paint()..color = isActivated ? Colors.yellow : _getFlowerColor();
      canvas.drawCircle(Offset.zero, 10, paint);
    }
    super.render(canvas);
  }
  
  Color _getFlowerColor() {
    switch (flowerType) {
      case 0: return Colors.red;
      case 1: return Colors.orange;
      case 2: return Colors.yellow;
      case 3: return Colors.green;
      case 4: return Colors.blue;
      case 5: return Colors.purple;
      default: return Colors.pink;
    }
  }
}

/// Magic Portal with ChatGPT sprites
class ExitPortal extends SpriteComponent with HasGameRef<AdventureLabyrinthGame> {
  bool isActive = false;
  double glowTimer = 0.0;
  
  ExitPortal(Vector2 position) : super(size: Vector2(50, 50)) {
    this.position = position;
    anchor = Anchor.center;
  }
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    try {
      // Try to load a seasonal portal
      sprite = await Sprite.load('games/labyrinth/portals/individual/portal_spring.png');
    } catch (e) {
      // Fallback to simple circle
      sprite = null;
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    glowTimer += dt;
    if (isActive) {
      // Active portal pulses
      final scaleFactor = math.sin(glowTimer * 4) * 0.1 + 1.0;
      scale = Vector2.all(scaleFactor);
    }
  }
  
  @override
  void render(Canvas canvas) {
    if (sprite == null) {
      // Fallback rendering
      final paint = Paint()..color = isActive 
          ? Colors.green.withOpacity(0.8)
          : Colors.grey.withOpacity(0.5);
      canvas.drawCircle(Offset.zero, 16, paint);
    }
    super.render(canvas);
  }
  
  void activate() {
    isActive = true;
  }
}

// Enums
enum MoveDirection { up, down, left, right }