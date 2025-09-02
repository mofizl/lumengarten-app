import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_theme.dart';

class DunkisLabyrinth extends StatefulWidget {
  const DunkisLabyrinth({super.key});

  @override
  State<DunkisLabyrinth> createState() => _DunkisLabyrinthState();
}

class _DunkisLabyrinthState extends State<DunkisLabyrinth>
    with TickerProviderStateMixin {
  
  late AnimationController _dunkiController;
  late AnimationController _magicController;
  late AnimationController _seasonController;
  late Animation<double> _dunkiFloat;
  late Animation<double> _magicSparkle;
  late Animation<double> _seasonTransition;
  
  final VoiceService _voiceService = VoiceService();
  
  // Game State
  int _level = 1;
  int _score = 0;
  bool _gameCompleted = false;
  Season _currentSeason = Season.spring;
  
  // Maze State
  List<List<MazeTile>> _maze = [];
  DunkiPosition _dunkiPos = DunkiPosition(1, 1);
  DunkiPosition _exitPos = DunkiPosition(5, 5);
  List<MagicFlower> _flowers = [];
  List<MagicCrystal> _crystals = [];
  Set<int> _activatedFlowers = {};
  bool _showingMagic = false;
  
  // Maze dimensions
  final int _mazeSize = 7;
  
  @override
  void initState() {
    super.initState();
    
    _voiceService.initialize();
    
    _dunkiController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _magicController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _seasonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _dunkiFloat = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dunkiController, curve: Curves.easeInOut),
    );
    
    _magicSparkle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _magicController, curve: Curves.easeInOut),
    );
    
    _seasonTransition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _seasonController, curve: Curves.easeInOut),
    );
    
    _dunkiController.repeat(reverse: true);
    _generateMaze();
    _voiceService.speak('Willkommen in Dunkis magischem Labyrinth! Hilf Dunki durch das lebende Hecken-Labyrinth!');
  }

  void _generateMaze() {
    // Generate a simple but magical maze
    _maze = List.generate(_mazeSize, (row) =>
      List.generate(_mazeSize, (col) {
        if (row == 0 || row == _mazeSize - 1 || col == 0 || col == _mazeSize - 1) {
          return MazeTile.wall; // Border walls
        }
        // Create paths with some walls
        if ((row + col) % 3 == 0 && !(row == 1 && col == 1) && !(row == 5 && col == 5)) {
          return MazeTile.wall;
        }
        return MazeTile.path;
      })
    );
    
    // Ensure path from start to end
    _maze[1][1] = MazeTile.path; // Start
    _maze[5][5] = MazeTile.path; // End
    _maze[2][1] = MazeTile.path; // Path from start
    _maze[5][4] = MazeTile.path; // Path to end
    
    // Add magical flowers
    _flowers = [
      MagicFlower(0, DunkiPosition(2, 3), FlowerColor.red),
      MagicFlower(1, DunkiPosition(3, 2), FlowerColor.blue),
      MagicFlower(2, DunkiPosition(4, 4), FlowerColor.yellow),
    ];
    
    // Add crystals for bonus points
    _crystals = [
      MagicCrystal(DunkiPosition(1, 3), CrystalType.amethyst),
      MagicCrystal(DunkiPosition(3, 5), CrystalType.emerald),
    ];
    
    _activatedFlowers.clear();
  }

  void _moveDunki(Direction direction) {
    DunkiPosition newPos = _dunkiPos;
    
    switch (direction) {
      case Direction.up:
        newPos = DunkiPosition(_dunkiPos.row - 1, _dunkiPos.col);
        break;
      case Direction.down:
        newPos = DunkiPosition(_dunkiPos.row + 1, _dunkiPos.col);
        break;
      case Direction.left:
        newPos = DunkiPosition(_dunkiPos.row, _dunkiPos.col - 1);
        break;
      case Direction.right:
        newPos = DunkiPosition(_dunkiPos.row, _dunkiPos.col + 1);
        break;
    }
    
    // Check bounds and walls
    if (newPos.row >= 0 && newPos.row < _mazeSize &&
        newPos.col >= 0 && newPos.col < _mazeSize &&
        _maze[newPos.row][newPos.col] != MazeTile.wall) {
      
      setState(() {
        _dunkiPos = newPos;
      });
      
      _checkInteractions();
    }
  }

  void _checkInteractions() {
    // Check for flowers
    for (int i = 0; i < _flowers.length; i++) {
      if (_flowers[i].position.row == _dunkiPos.row &&
          _flowers[i].position.col == _dunkiPos.col &&
          !_activatedFlowers.contains(i)) {
        _activateFlower(i);
        break;
      }
    }
    
    // Check for crystals
    _crystals.removeWhere((crystal) {
      if (crystal.position.row == _dunkiPos.row &&
          crystal.position.col == _dunkiPos.col) {
        _collectCrystal();
        return true;
      }
      return false;
    });
    
    // Check win condition
    if (_dunkiPos.row == _exitPos.row && _dunkiPos.col == _exitPos.col) {
      _checkWinCondition();
    }
  }

  void _activateFlower(int flowerIndex) {
    setState(() {
      _activatedFlowers.add(flowerIndex);
      _showingMagic = true;
    });
    
    _magicController.forward().then((_) {
      _magicController.reset();
      setState(() {
        _showingMagic = false;
      });
    });
    
    FlowerColor color = _flowers[flowerIndex].color;
    String colorName = color.toString().split('.').last;
    _voiceService.speak('Magisch! Du hast die ${colorName}e Blume aktiviert!');
    
    // Flower magic effects
    _applyFlowerMagic(color);
  }

  void _applyFlowerMagic(FlowerColor color) {
    switch (color) {
      case FlowerColor.red:
        // Fire magic - melts ice walls (seasonal effect)
        _voiceService.speak('Feuermagie schmilzt das Eis!');
        break;
      case FlowerColor.blue:
        // Water magic - grows new paths
        _voiceService.speak('Wassermagie lässt neue Wege sprießen!');
        break;
      case FlowerColor.yellow:
        // Sun magic - lights up dark areas
        _voiceService.speak('Sonnenmagie erhellt den Weg!');
        break;
      case FlowerColor.green:
        // Nature magic - opens hedge passages
        _voiceService.speak('Naturmagie öffnet die Hecken!');
        break;
      case FlowerColor.purple:
        // Time magic - reveals solution hints
        _voiceService.speak('Zeitmagie zeigt dir den Weg!');
        break;
      case FlowerColor.orange:
        // Season magic - changes the labyrinth season
        _changeSeason();
        break;
    }
  }

  void _changeSeason() {
    setState(() {
      _currentSeason = Season.values[(_currentSeason.index + 1) % Season.values.length];
    });
    
    _seasonController.forward().then((_) {
      _seasonController.reset();
    });
    
    String seasonName = _currentSeason.toString().split('.').last;
    _voiceService.speak('Die Jahreszeit wechselt zu $seasonName!');
  }

  void _collectCrystal() {
    setState(() {
      _score += 50;
    });
    
    _voiceService.speak('Kristall gesammelt! Magische Energie steigt!');
  }

  void _checkWinCondition() {
    if (_activatedFlowers.length == _flowers.length) {
      _completeLevel();
    } else {
      _voiceService.speak('Aktiviere alle magischen Blumen, bevor du das Ziel erreichst!');
    }
  }

  void _completeLevel() {
    setState(() {
      _gameCompleted = true;
      _score += _level * 100;
    });
    
    _voiceService.speak('Fantastisch! Du hast Dunkis Labyrinth gemeistert!');
  }

  void _resetLevel() {
    setState(() {
      _level++;
      _gameCompleted = false;
      _dunkiPos = DunkiPosition(1, 1);
    });
    
    _generateMaze();
    _voiceService.speak('Nächstes Level! Das Labyrinth wird magischer!');
  }

  @override
  void dispose() {
    _dunkiController.dispose();
    _magicController.dispose();
    _seasonController.dispose();
    _voiceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _getSeasonGradient(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Maze View
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
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
                  child: _gameCompleted ? _buildWinScreen() : _buildMazeView(),
                ),
              ),
              
              // Controls
              if (!_gameCompleted) _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'Dunkis Labyrinth',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.starYellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '⭐ $_score',
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

  Widget _buildMazeView() {
    return AnimatedBuilder(
      animation: _seasonTransition,
      builder: (context, child) {
        return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _mazeSize,
              childAspectRatio: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: _mazeSize * _mazeSize,
            itemBuilder: (context, index) {
              int row = index ~/ _mazeSize;
              int col = index % _mazeSize;
              return _buildMazeTile(row, col);
            },
        );
      },
    );
  }

  Widget _buildMazeTile(int row, int col) {
    MazeTile tileType = _maze[row][col];
    bool isDunki = _dunkiPos.row == row && _dunkiPos.col == col;
    bool isExit = _exitPos.row == row && _exitPos.col == col;
    
    // Check for flowers
    MagicFlower? flower;
    int flowerIndex = -1;
    for (int i = 0; i < _flowers.length; i++) {
      if (_flowers[i].position.row == row && _flowers[i].position.col == col) {
        flower = _flowers[i];
        flowerIndex = i;
        break;
      }
    }
    
    // Check for crystals
    MagicCrystal? crystal;
    for (var c in _crystals) {
      if (c.position.row == row && c.position.col == col) {
        crystal = c;
        break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: _getTileColor(tileType),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getTileBorderColor(tileType),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background decorations
          _buildBackgroundElement(row, col),
          // Base tile
          if (tileType == MazeTile.path)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: RadialGradient(
                  colors: [
                    _getSeasonPathColor(),
                    _getSeasonPathColor().withOpacity(0.8),
                  ],
                ),
              ),
            ),
          
          // Exit portal
          if (isExit)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: RadialGradient(
                  colors: [
                    AppTheme.starYellow.withOpacity(0.8),
                    AppTheme.magicGreen.withOpacity(0.6),
                  ],
                ),
              ),
              child: const Center(
                child: Text('🌟', style: TextStyle(fontSize: 20)),
              ),
            ),
          
          // Crystal
          if (crystal != null)
            Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getCrystalColor(crystal!.type),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getCrystalColor(crystal!.type).withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: const Icon(Icons.diamond, size: 16, color: Colors.white),
              ),
            ),
          
          // Flower
          if (flower != null)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: _activatedFlowers.contains(flowerIndex) ? 35 : 25,
                height: _activatedFlowers.contains(flowerIndex) ? 35 : 25,
                child: Text(
                  _getFlowerEmoji(flower!.color),
                  style: TextStyle(
                    fontSize: _activatedFlowers.contains(flowerIndex) ? 20 : 16,
                  ),
                ),
              ),
            ),
          
          // Dunki
          if (isDunki)
            AnimatedBuilder(
              animation: _dunkiFloat,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -2 * _dunkiFloat.value),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Magic sparkles when showing magic
                        if (_showingMagic)
                          AnimatedBuilder(
                            animation: _magicSparkle,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + 0.5 * _magicSparkle.value,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppTheme.starYellow.withOpacity(0.8),
                                        AppTheme.magicGreen.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        // Dunki character with actual sprite
                        Image.asset(
                          _getDunkiSpritePath(),
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text('🐲', style: TextStyle(fontSize: 24));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Level $_level • Aktiviere alle Blumen!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Direction controls
          Column(
            children: [
              GestureDetector(
                onTap: () => _moveDunki(Direction.up),
                child: _buildControlButton(Icons.keyboard_arrow_up),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _moveDunki(Direction.left),
                    child: _buildControlButton(Icons.keyboard_arrow_left),
                  ),
                  const SizedBox(width: 60),
                  GestureDetector(
                    onTap: () => _moveDunki(Direction.right),
                    child: _buildControlButton(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _moveDunki(Direction.down),
                child: _buildControlButton(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      margin: const EdgeInsets.all(5),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.magicGreen.withOpacity(0.8),
            AppTheme.magicGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildWinScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text(
            'Level $_level geschafft!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.magicGreen,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Score: $_score Punkte',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _resetLevel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.magicGreen,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Nächstes Level',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getSeasonGradient() {
    switch (_currentSeason) {
      case Season.spring:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightGreen.shade200,
            Colors.green.shade300,
            Colors.lightGreen.shade100,
          ],
        );
      case Season.summer:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.yellow.shade200,
            Colors.green.shade400,
            Colors.lightGreen.shade200,
          ],
        );
      case Season.autumn:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange.shade200,
            Colors.red.shade200,
            Colors.brown.shade200,
          ],
        );
      case Season.winter:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue.shade100,
            Colors.blue.shade200,
            Colors.white,
          ],
        );
    }
  }

  Color _getTileColor(MazeTile tileType) {
    switch (tileType) {
      case MazeTile.wall:
        return _getSeasonWallColor();
      case MazeTile.path:
        return _getSeasonPathColor();
    }
  }

  Color _getTileBorderColor(MazeTile tileType) {
    switch (tileType) {
      case MazeTile.wall:
        return Colors.green.shade800;
      case MazeTile.path:
        return Colors.green.shade300;
    }
  }

  Color _getSeasonWallColor() {
    switch (_currentSeason) {
      case Season.spring:
        return Colors.green.shade600;
      case Season.summer:
        return Colors.green.shade700;
      case Season.autumn:
        return Colors.brown.shade600;
      case Season.winter:
        return Colors.blueGrey.shade600;
    }
  }

  Color _getSeasonPathColor() {
    switch (_currentSeason) {
      case Season.spring:
        return Colors.lightGreen.shade100;
      case Season.summer:
        return Colors.green.shade100;
      case Season.autumn:
        return Colors.orange.shade100;
      case Season.winter:
        return Colors.lightBlue.shade50;
    }
  }

  Color _getCrystalColor(CrystalType type) {
    switch (type) {
      case CrystalType.amethyst:
        return Colors.purple;
      case CrystalType.emerald:
        return Colors.green;
      case CrystalType.sapphire:
        return Colors.blue;
      case CrystalType.amber:
        return Colors.amber;
    }
  }

  String _getDunkiSpritePath() {
    // Use different sprites based on game state
    if (_showingMagic) {
      return 'assets/images/games/labyrinth/dunki/dunki_magic_casting.png';
    } else if (_gameCompleted) {
      return 'assets/images/games/labyrinth/dunki/dunki_celebrating.png';
    } else if (_activatedFlowers.length == _flowers.length) {
      return 'assets/images/games/labyrinth/dunki/dunki_exited.png';
    } else {
      return 'assets/images/games/labyrinth/dunki/dunki_happy.png';
    }
  }

  String _getFlowerEmoji(FlowerColor color) {
    switch (color) {
      case FlowerColor.red:
        return '🌹';
      case FlowerColor.blue:
        return '🌸';
      case FlowerColor.yellow:
        return '🌻';
      case FlowerColor.green:
        return '🌿';
      case FlowerColor.purple:
        return '💜';
      case FlowerColor.orange:
        return '🌺';
    }
  }
  
  String _getFlowerSpritePath(FlowerColor color, bool isActivated) {
    String colorName;
    switch (color) {
      case FlowerColor.red:
        colorName = 'red';
        break;
      case FlowerColor.orange:
        colorName = 'orange';
        break;
      case FlowerColor.yellow:
        colorName = 'yellow';
        break;
      case FlowerColor.green:
        colorName = 'green';
        break;
      case FlowerColor.blue:
        colorName = 'blue';
        break;
      case FlowerColor.purple:
        colorName = 'purple';
        break;
    }
    
    String state = isActivated ? 'bloomed' : 'closed';
    return 'assets/images/games/labyrinth/flowers/flowers_spritesheet.png';
  }
  
  String _getCrystalSpritePath(CrystalType type, bool isGlowing) {
    return 'assets/images/games/labyrinth/crystals/crystals_spritesheet.png';
  }
  
  String _getHedgeSpritePath() {
    return 'assets/images/games/labyrinth/tiles/hedge_style_sprite_sheet.png';
  }
  
  String _getBackgroundSpritePath() {
    return 'assets/images/games/labyrinth/garten hintergrund_spritesheet.png';
  }
  
  Widget _buildBackgroundElement(int row, int col) {
    // Add decorative background elements based on position
    if (row == 0 && col == 0) {
      // Magic tree in top-left corner
      return Positioned(
        left: -20,
        top: -20,
        child: Image.asset(
          _getBackgroundSpritePath(),
          width: 60,
          height: 60,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        ),
      );
    } else if (row == _mazeSize - 1 && col == _mazeSize - 1) {
      // Rainbow at exit
      return Positioned(
        right: -20,
        bottom: -20,
        child: Image.asset(
          _getBackgroundSpritePath(),
          width: 50,
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        ),
      );
    } else if ((row + col) % 4 == 0 && _maze[row][col] == MazeTile.path) {
      // Occasional decorative elements on paths
      return Positioned(
        child: Image.asset(
          _getBackgroundSpritePath(),
          width: 30,
          height: 30,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        ),
      );
    }
    return const SizedBox();
  }
}

// Data Classes
enum MazeTile { wall, path }
enum Direction { up, down, left, right }
enum Season { spring, summer, autumn, winter }
enum FlowerColor { red, blue, yellow, green, purple, orange }
enum CrystalType { amethyst, emerald, sapphire, amber }

class DunkiPosition {
  final int row;
  final int col;

  DunkiPosition(this.row, this.col);
}

class MagicFlower {
  final int id;
  final DunkiPosition position;
  final FlowerColor color;

  MagicFlower(this.id, this.position, this.color);
}

class MagicCrystal {
  final DunkiPosition position;
  final CrystalType type;

  MagicCrystal(this.position, this.type);
}