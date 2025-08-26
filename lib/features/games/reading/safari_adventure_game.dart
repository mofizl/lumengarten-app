import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/voice_service.dart';
// import '../../../core/theme/app_theme.dart'; // Unused import

class SafariAdventureGame extends StatefulWidget {
  const SafariAdventureGame({super.key});

  @override
  State<SafariAdventureGame> createState() => _SafariAdventureGameState();
}

class _SafariAdventureGameState extends State<SafariAdventureGame>
    with TickerProviderStateMixin {
  
  // Animation Controllers
  late AnimationController _jeepController;
  late AnimationController _animalController;
  late AnimationController _backgroundController;
  late AnimationController _celebrationController;
  
  // Animations
  late Animation<double> _jeepPosition;
  late Animation<double> _animalBounce;
  late Animation<double> _backgroundFloat;
  late Animation<double> _celebrationScale;
  
  final VoiceService _voiceService = VoiceService();
  
  // Game State
  String _targetLetter = 'A';
  List<SafariAnimal> _visibleAnimals = [];
  Set<int> _foundAnimals = {};
  int _score = 0;
  int _level = 1;
  bool _gameCompleted = false;
  bool _showCelebration = false;

  // Safari Animals with positions and behaviors
  final Map<String, AnimalData> _allAnimals = {
    'A': AnimalData('Affe', '🐒', Colors.brown, 'Der Affe schwingt von Ast zu Ast!'),
    'B': AnimalData('Bär', '🐻', Colors.brown.shade800, 'Der Bär ist stark und freundlich!'),
    'C': AnimalData('Chamäleon', '🦎', Colors.green, 'Das Chamäleon wechselt die Farbe!'),
    'D': AnimalData('Delfin', '🐬', Colors.blue, 'Der Delfin springt aus dem Wasser!'),
    'E': AnimalData('Elefant', '🐘', Colors.grey, 'Der Elefant hat einen langen Rüssel!'),
    'F': AnimalData('Flamingo', '🦩', Colors.pink, 'Der Flamingo steht auf einem Bein!'),
    'G': AnimalData('Giraffe', '🦒', Colors.orange, 'Die Giraffe ist sehr groß!'),
    'H': AnimalData('Hase', '🐰', Colors.white, 'Der Hase hüpft schnell umher!'),
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateAnimals();
    _startGame();
  }

  void _initializeAnimations() {
    // Safari Jeep Animation
    _jeepController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _jeepPosition = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: _jeepController, curve: Curves.linear),
    );

    // Animal Bounce Animation
    _animalController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animalBounce = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _animalController, curve: Curves.easeInOut),
    );

    // Background Float
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _backgroundFloat = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    // Celebration Animation
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _celebrationScale = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut),
    );
  }

  void _generateAnimals() {
    _visibleAnimals.clear();
    final random = math.Random();
    final availableAnimals = _allAnimals.entries.toList();
    
    // 3 Target animals + 3 decoy animals
    for (int i = 0; i < 6; i++) {
      bool isTarget = i < 3;
      String letter;
      
      if (isTarget) {
        letter = _targetLetter;
      } else {
        letter = availableAnimals[random.nextInt(availableAnimals.length)].key;
        while (letter == _targetLetter) {
          letter = availableAnimals[random.nextInt(availableAnimals.length)].key;
        }
      }
      
      _visibleAnimals.add(SafariAnimal(
        letter: letter,
        animal: _allAnimals[letter]!,
        x: 0.1 + random.nextDouble() * 0.8,
        y: 0.3 + random.nextDouble() * 0.5,
        isTarget: isTarget,
        isHidden: random.nextBool(),
        scale: 0.8 + random.nextDouble() * 0.4,
        rotation: -0.1 + random.nextDouble() * 0.2,
      ));
    }
  }

  void _startGame() {
    final animalData = _allAnimals[_targetLetter];
    _voiceService.speak(
      'Willkommen zum Safari-Abenteuer! Hilf unserem Safari-Guide dabei, alle ${animalData?.name}s zu finden! Sie verstecken sich im Dschungel!'
    );
  }

  void _onAnimalTapped(int index) {
    if (_foundAnimals.contains(index) || _gameCompleted) return;
    
    final animal = _visibleAnimals[index];
    
    if (animal.isTarget) {
      // Correct animal found!
      setState(() {
        _foundAnimals.add(index);
        _score += 150;
        _showCelebration = true;
      });
      
      _celebrationController.reset();
      _celebrationController.forward();
      
      _voiceService.speak('Fantastisch! Du hast einen ${animal.animal.name} gefunden! ${animal.animal.description}');
      
      // Hide celebration after animation
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showCelebration = false;
          });
        }
      });
      
      // Check if game completed
      if (_foundAnimals.length >= 3) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          _completeLevel();
        });
      }
    } else {
      // Wrong animal
      _voiceService.speak(
        'Das ist ein ${animal.animal.name}! Suche nach ${_allAnimals[_targetLetter]?.name}s für den Buchstaben $_targetLetter!'
      );
      setState(() {
        _score = math.max(0, _score - 25);
      });
    }
  }

  void _completeLevel() {
    setState(() {
      _gameCompleted = true;
    });
    
    int stars = _score >= 400 ? 3 : _score >= 250 ? 2 : 1;
    
    _voiceService.speak(
      'Hervorragend! Du hast alle ${_allAnimals[_targetLetter]?.name}s gefunden! Das Safari-Abenteuer war ein Erfolg!'
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      _showCompletionDialog(stars);
    });
  }

  void _showCompletionDialog(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.orange.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              'Safari-Mission\nerfolgreich!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Icon(
                Icons.star,
                color: i < stars ? Colors.amber : Colors.grey.shade300,
                size: 45,
              )),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.shade400, width: 2),
              ),
              child: Text(
                'Punkte: $_score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.replay),
                  label: const Text('Nochmal'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Back to garden
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.home),
                  label: const Text('Zurück'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _foundAnimals.clear();
      _score = 0;
      _gameCompleted = false;
      _showCelebration = false;
      _targetLetter = _getNextLetter();
      _level++;
    });
    _generateAnimals();
    _startGame();
  }

  String _getNextLetter() {
    final letters = _allAnimals.keys.toList();
    final currentIndex = letters.indexOf(_targetLetter);
    return letters[(currentIndex + 1) % letters.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Safari Background
          _buildSafariBackground(),
          
          // Game Area
          SafeArea(
            child: Column(
              children: [
                _buildGameHeader(),
                Expanded(
                  child: Stack(
                    children: [
                      // Safari Animals
                      ..._buildAnimalWidgets(),
                      
                      // Safari Jeep
                      _buildSafariJeep(),
                      
                      // Celebration Effect
                      if (_showCelebration)
                        _buildCelebrationEffect(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Back Button
          SafeArea(
            child: Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                heroTag: "back_button",
                backgroundColor: Colors.orange.shade100,
                onPressed: () => Navigator.of(context).pop(),
                child: Icon(Icons.arrow_back, color: Colors.orange.shade800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafariBackground() {
    return AnimatedBuilder(
      animation: _backgroundFloat,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightBlue.shade200,  // Sky
                Colors.orange.shade100,     // Horizon
                Colors.green.shade400,      // Grass
                Colors.green.shade600,      // Deep grass
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Sun
              Positioned(
                top: 40,
                right: 60,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade300,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.shade200,
                        blurRadius: 30,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Floating Elements
              ..._buildFloatingElements(),
              
              // Mountains in background
              Positioned(
                bottom: 200,
                left: -50,
                right: -50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMountain(Colors.purple.shade300, 120),
                    _buildMountain(Colors.purple.shade200, 90),
                    _buildMountain(Colors.purple.shade400, 110),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMountain(Color color, double height) {
    return Container(
      width: 150,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(75),
          topRight: Radius.circular(75),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return List.generate(15, (index) {
      final elements = ['🌴', '🌿', '🦋', '🌺', '☁️'];
      final element = elements[index % elements.length];
      final offset = _backgroundFloat.value * 2 * math.pi + index;
      
      return Positioned(
        left: 40 + (index % 5) * 80 + math.sin(offset) * 20,
        top: 80 + (index ~/ 5) * 120 + math.cos(offset * 0.7) * 15,
        child: Transform.scale(
          scale: 0.7 + math.sin(offset * 1.3) * 0.2,
          child: Opacity(
            opacity: 0.6 + math.cos(offset) * 0.2,
            child: Text(element, style: const TextStyle(fontSize: 24)),
          ),
        ),
      );
    });
  }

  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, color: Colors.orange.shade600, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Finde: $_targetLetter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _allAnimals[_targetLetter]?.emoji ?? '',
                  style: const TextStyle(fontSize: 28),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnimalWidgets() {
    return _visibleAnimals.asMap().entries.map((entry) {
      int index = entry.key;
      SafariAnimal animal = entry.value;
      bool isFound = _foundAnimals.contains(index);
      
      return AnimatedPositioned(
        duration: Duration(milliseconds: isFound ? 500 : 0),
        left: MediaQuery.of(context).size.width * animal.x - 60,
        top: MediaQuery.of(context).size.height * 0.6 * animal.y,
        child: AnimatedBuilder(
          animation: _animalBounce,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_animalBounce.value * (index % 3 + 1) * 0.5),
              child: _buildAnimalCard(animal, index, isFound),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildAnimalCard(SafariAnimal animal, int index, bool isFound) {
    return GestureDetector(
      onTap: () => _onAnimalTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..scale(animal.scale + (isFound ? 0.2 : 0.0))
          ..rotateZ(animal.rotation + (isFound ? 0.1 : 0.0)),
        child: Container(
          width: 120,
          height: 140,
          decoration: BoxDecoration(
            color: isFound 
              ? Colors.green.shade200
              : animal.isHidden
                ? Colors.brown.shade300.withOpacity(0.8)
                : animal.animal.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isFound 
                ? Colors.green.shade600
                : animal.isTarget 
                  ? Colors.orange.shade600
                  : Colors.brown.shade600,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animal Emoji
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    animal.isHidden && !isFound ? '🌿' : animal.animal.emoji,
                    style: TextStyle(
                      fontSize: isFound ? 45 : 40,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Letter Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isFound ? Colors.green : Colors.orange,
                    width: 2,
                  ),
                ),
                child: Text(
                  animal.letter,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isFound ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
              ),
              
              // Animal Name (when found)
              if (isFound)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    animal.animal.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafariJeep() {
    return AnimatedBuilder(
      animation: _jeepPosition,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * _jeepPosition.value - 30,
          bottom: 20,
          child: Transform.scale(
            scale: 0.8,
            child: const Text('🚙💨', style: TextStyle(fontSize: 40)),
          ),
        );
      },
    );
  }

  Widget _buildCelebrationEffect() {
    return AnimatedBuilder(
      animation: _celebrationScale,
      builder: (context, child) {
        return Center(
          child: Transform.scale(
            scale: _celebrationScale.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200,
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Text(
                '🎉',
                style: TextStyle(fontSize: 60),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _jeepController.dispose();
    _animalController.dispose();
    _backgroundController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }
}

// Data Classes
class AnimalData {
  final String name;
  final String emoji;
  final Color color;
  final String description;
  
  AnimalData(this.name, this.emoji, this.color, this.description);
}

class SafariAnimal {
  final String letter;
  final AnimalData animal;
  final double x, y;
  final bool isTarget;
  final bool isHidden;
  final double scale;
  final double rotation;
  
  SafariAnimal({
    required this.letter,
    required this.animal,
    required this.x,
    required this.y,
    required this.isTarget,
    required this.isHidden,
    required this.scale,
    required this.rotation,
  });
}