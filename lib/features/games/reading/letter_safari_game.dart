import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_theme.dart';

class LetterSafariGame extends StatefulWidget {
  const LetterSafariGame({super.key});

  @override
  State<LetterSafariGame> createState() => _LetterSafariGameState();
}

class _LetterSafariGameState extends State<LetterSafariGame>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late Animation<double> _backgroundAnimation;
  
  final VoiceService _voiceService = VoiceService();
  
  String _currentLetter = 'A';
  List<LetterPosition> _letterPositions = [];
  Set<int> _foundLetters = {};
  int _score = 0;
  int _totalLetters = 6;
  bool _gameCompleted = false;
  List<ParticleEffect> _particles = [];
  
  // Safari Tiere für jeden Buchstaben
  final Map<String, SafariAnimal> _safariAnimals = {
    'A': SafariAnimal('Affe', '🐒', Colors.brown.shade400),
    'B': SafariAnimal('Bär', '🐻', Colors.brown.shade600),
    'C': SafariAnimal('Chamäleon', '🦎', Colors.green.shade500),
    'D': SafariAnimal('Delfin', '🐬', Colors.blue.shade400),
    'E': SafariAnimal('Elefant', '🐘', Colors.grey.shade500),
    'F': SafariAnimal('Flamingo', '🦩', Colors.pink.shade400),
    'G': SafariAnimal('Giraffe', '🦒', Colors.orange.shade400),
    'H': SafariAnimal('Hase', '🐰', Colors.grey.shade300),
    'I': SafariAnimal('Igel', '🦔', Colors.brown.shade500),
    'J': SafariAnimal('Jaguar', '🐆', Colors.orange.shade600),
  };

  // Jungle-Hintergrund Elemente
  final List<String> _jungleElements = [
    '🌴', '🌿', '🍃', '🌾', '🌳', '🦋', '🐛', '🌺', '🌸', '🌻'
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateLetterPositions();
    _startGame();
  }
  
  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
  }
  
  void _generateLetterPositions() {
    _letterPositions.clear();
    final random = math.Random();
    
    // Generiere Positionen für Buchstaben (echte und Ablenkungen)
    for (int i = 0; i < _totalLetters; i++) {
      bool isTarget = i < 3; // 3 echte Zielbuchstaben
      _letterPositions.add(LetterPosition(
        letter: isTarget ? _currentLetter : _getRandomLetter(),
        x: 0.1 + random.nextDouble() * 0.8,
        y: 0.2 + random.nextDouble() * 0.6,
        isTarget: isTarget,
        scale: 0.8 + random.nextDouble() * 0.4,
        rotation: -0.2 + random.nextDouble() * 0.4,
      ));
    }
  }
  
  String _getRandomLetter() {
    final letters = _safariAnimals.keys.where((letter) => letter != _currentLetter).toList();
    return letters[math.Random().nextInt(letters.length)];
  }
  
  void _startGame() {
    final animal = _safariAnimals[_currentLetter];
    _voiceService.speak('Willkommen zur Safari! Finde alle ${animal?.name}s für den Buchstaben $_currentLetter! Tippe sie an!');
  }
  
  void _onLetterTapped(int index) {
    if (_foundLetters.contains(index) || _gameCompleted) return;
    
    final letterPos = _letterPositions[index];
    
    if (letterPos.isTarget) {
      // Richtiger Buchstabe gefunden!
      setState(() {
        _foundLetters.add(index);
        _score += 100;
        
        // Partikel-Effekt hinzufügen
        _addParticleEffect(letterPos.x, letterPos.y);
      });
      
      final animal = _safariAnimals[_currentLetter];
      _voiceService.speak('Super! Du hast einen ${animal?.name} gefunden!');
      
      // Überprüfe ob Spiel beendet
      if (_foundLetters.length >= 3) {
        _completeGame();
      }
    } else {
      // Falscher Buchstabe
      final wrongAnimal = _safariAnimals[letterPos.letter];
      final targetAnimal = _safariAnimals[_currentLetter];
      _voiceService.speak('Das ist ein ${wrongAnimal?.name}! Suche nach ${targetAnimal?.name} für $_currentLetter!');
      setState(() {
        _score = math.max(0, _score - 20);
      });
    }
  }
  
  void _addParticleEffect(double x, double y) {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _particles.add(ParticleEffect(
        x: x,
        y: y,
        dx: -0.1 + random.nextDouble() * 0.2,
        dy: -0.2 + random.nextDouble() * 0.1,
        color: Color.fromRGBO(
          100 + random.nextInt(156),
          150 + random.nextInt(106),
          200 + random.nextInt(56),
          1.0,
        ),
        life: 1.0,
      ));
    }
    _particleController.reset();
    _particleController.forward();
  }
  
  void _completeGame() {
    setState(() {
      _gameCompleted = true;
    });
    
    // Berechne Sterne basierend auf Score
    int stars = _score >= 250 ? 3 : _score >= 150 ? 2 : 1;
    
    _voiceService.speak('Fantastisch! Du hast alle ${_currentLetter}s gefunden! Du bekommst $stars Sterne!');
    
    // Speichere Fortschritt - Update Reading Area
    // TODO: Progress tracking implementieren
    // final currentProgress = 0.2; // Basis-Fortschritt für Reading  
    // final gameProgress = stars / 3.0 * 0.1; // Bis zu 10% für dieses Spiel
    // _progressService.updateAreaProgress(LearningArea.reading, currentProgress + gameProgress);
    
    // Zeige Erfolgsscreen nach kurzer Verzögerung
    Future.delayed(const Duration(seconds: 2), () {
      _showSuccessDialog(stars);
    });
  }
  
  void _showSuccessDialog(int stars) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Buchstaben-Safari\nabgeschlossen!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Icon(
                Icons.star,
                color: i < stars ? Colors.amber : Colors.grey.shade300,
                size: 40,
              )),
            ),
            const SizedBox(height: 16),
            Text('Punkte: $_score', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Nochmal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Zurück zum Garten
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Weiter'),
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
      _foundLetters.clear();
      _score = 0;
      _gameCompleted = false;
      _particles.clear();
      _currentLetter = _getNextLetter();
    });
    _generateLetterPositions();
    _startGame();
  }
  
  String _getNextLetter() {
    final letters = _safariAnimals.keys.toList();
    final currentIndex = letters.indexOf(_currentLetter);
    return letters[(currentIndex + 1) % letters.length];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Safari Dschungel Hintergrund
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.lightBlue.shade300, // Himmel
                      Colors.green.shade300,     // Baumkronen
                      Colors.green.shade600,     // Dschungel
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
                child: _buildJungleBackground(),
              );
            },
          ),
          
          // Spielbereich
          SafeArea(
            child: Column(
              children: [
                // Header mit Score und Fortschritt
                _buildGameHeader(),
                
                // Hauptspielbereich
                Expanded(
                  child: Stack(
                    children: [
                      // Buchstaben im Spiel
                      ..._letterPositions.asMap().entries.map((entry) {
                        int index = entry.key;
                        LetterPosition pos = entry.value;
                        
                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          left: MediaQuery.of(context).size.width * pos.x - 30,
                          top: MediaQuery.of(context).size.height * 0.7 * pos.y,
                          child: _buildLetterWidget(pos, index),
                        );
                      }),
                      
                      // Partikel-Effekte
                      if (_particles.isNotEmpty)
                        AnimatedBuilder(
                          animation: _particleController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: ParticlePainter(_particles, _particleController.value),
                              size: Size.infinite,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Zurück-Button
          SafeArea(
            child: Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                heroTag: "back_button",
                backgroundColor: Colors.white.withOpacity(0.9),
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back, color: Colors.purple),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🔍 Finde: $_currentLetter - ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                Text(
                  _safariAnimals[_currentLetter]?.emoji ?? '',
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLetterWidget(LetterPosition pos, int index) {
    bool isFound = _foundLetters.contains(index);
    final animal = _safariAnimals[pos.letter];
    
    return GestureDetector(
      onTap: () => _onLetterTapped(index),
      child: Transform.rotate(
        angle: pos.rotation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..scale(pos.scale + (isFound ? 0.1 : 0.0))
            ..rotateZ(isFound ? 0.1 : 0.0),
          child: Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: isFound 
                ? Colors.green.shade200
                : animal?.color.withOpacity(0.3) ?? Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isFound 
                  ? Colors.green.shade600
                  : pos.isTarget 
                    ? Colors.orange.shade600
                    : Colors.brown.shade400,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tier-Emoji
                Text(
                  animal?.emoji ?? '❓',
                  style: TextStyle(
                    fontSize: isFound ? 32 : 28,
                  ),
                ),
                const SizedBox(height: 4),
                // Buchstabe
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pos.letter,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isFound ? Colors.green.shade800 : Colors.black87,
                    ),
                  ),
                ),
                // Tier-Name
                if (isFound)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      animal?.name ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildJungleBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Sonne
            Positioned(
              top: 30,
              right: 50,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade300,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.shade200,
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            
            // Schwebende Dschungel-Elemente
            ...List.generate(25, (index) {
              final element = _jungleElements[index % _jungleElements.length];
              final offset = _backgroundAnimation.value * 2 * math.pi + index;
              final baseX = 30 + (index % 6) * 70;
              final baseY = 80 + (index ~/ 6) * 100;
              
              return Positioned(
                left: baseX + math.sin(offset) * 15,
                top: baseY + math.cos(offset * 0.8) * 10,
                child: Transform.scale(
                  scale: 0.6 + math.sin(offset * 1.2) * 0.2,
                  child: Transform.rotate(
                    angle: math.sin(offset * 0.5) * 0.1,
                    child: Opacity(
                      opacity: 0.4 + math.cos(offset) * 0.2,
                      child: Text(
                        element,
                        style: const TextStyle(
                          fontSize: 28,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            // Vögel am Himmel
            ...List.generate(3, (index) {
              final birdOffset = _backgroundAnimation.value + index * 2;
              return Positioned(
                left: (birdOffset * 200) % (MediaQuery.of(context).size.width + 100) - 50,
                top: 50 + index * 15,
                child: Text(
                  '🕊️',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}

// Datenklassen
class SafariAnimal {
  final String name;
  final String emoji;
  final Color color;
  
  SafariAnimal(this.name, this.emoji, this.color);
}

class LetterPosition {
  final String letter;
  final double x, y;
  final bool isTarget;
  final double scale;
  final double rotation;
  
  LetterPosition({
    required this.letter,
    required this.x,
    required this.y,
    required this.isTarget,
    required this.scale,
    required this.rotation,
  });
}

class ParticleEffect {
  double x, y;
  final double dx, dy;
  final Color color;
  double life;
  
  ParticleEffect({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.color,
    required this.life,
  });
  
  void update(double dt) {
    x += dx * dt;
    y += dy * dt;
    life -= dt;
  }
}

class ParticlePainter extends CustomPainter {
  final List<ParticleEffect> particles;
  final double animationValue;
  
  ParticlePainter(this.particles, this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (var particle in particles) {
      if (particle.life > 0) {
        paint.color = particle.color.withOpacity(particle.life);
        canvas.drawCircle(
          Offset(
            particle.x * size.width,
            particle.y * size.height,
          ),
          4 * particle.life,
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}