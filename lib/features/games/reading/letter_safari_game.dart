import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/voice_service.dart';

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
  
  // Magische Garten-Szenen
  final List<String> _backgroundScenes = [
    '🌸🦋🌺🌿🌳🌻🐛🌹🍄🌱',
    '🌲🦌🌰🍂🦔🌾🦉🌿🍃🌸',
    '🌊🐠🌺🦋🌸🌿💎✨🌈🦄',
    '🌙⭐🦋🌸🌿🔮💫🌟✨🦄'
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
    final letters = ['B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];
    return letters[math.Random().nextInt(letters.length)];
  }
  
  void _startGame() {
    _voiceService.speak('Willkommen zur Buchstaben-Safari! Finde alle ${_currentLetter}s in dem magischen Garten! Tippe sie an!');
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
      
      _voiceService.speak('Super! Du hast ein ${_currentLetter} gefunden!');
      
      // Überprüfe ob Spiel beendet
      if (_foundLetters.length >= 3) {
        _completeGame();
      }
    } else {
      // Falscher Buchstabe
      _voiceService.speak('Das ist ein ${letterPos.letter}. Suche nach ${_currentLetter}!');
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
    final currentProgress = 0.2; // Basis-Fortschritt für Reading
    final gameProgress = stars / 3.0 * 0.1; // Bis zu 10% für dieses Spiel
    // _progressService.updateAreaProgress(LearningArea.reading, currentProgress + gameProgress);
    // TODO: Progress tracking implementieren
    
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
    final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
    final currentIndex = letters.indexOf(_currentLetter);
    return letters[(currentIndex + 1) % letters.length];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Magischer animierter Hintergrund
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(Colors.purple.shade200, Colors.pink.shade200, 
                          math.sin(_backgroundAnimation.value * math.pi * 2) * 0.5 + 0.5)!,
                      Color.lerp(Colors.blue.shade200, Colors.green.shade200,
                          math.cos(_backgroundAnimation.value * math.pi * 2) * 0.5 + 0.5)!,
                    ],
                  ),
                ),
                child: _buildBackgroundElements(),
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
            child: Text(
              'Finde: $_currentLetter',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
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
    
    return GestureDetector(
      onTap: () => _onLetterTapped(index),
      child: Transform.rotate(
        angle: pos.rotation,
        child: Transform.scale(
          scale: pos.scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isFound 
                ? Colors.green.withOpacity(0.8)
                : pos.isTarget 
                  ? Colors.yellow.withOpacity(0.8)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: pos.isTarget ? Colors.orange : Colors.grey,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                pos.letter,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isFound ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBackgroundElements() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Schwebende Hintergrund-Emojis
            ...List.generate(20, (index) {
              final emoji = _backgroundScenes[0][index % _backgroundScenes[0].length];
              final offset = _backgroundAnimation.value * 2 * math.pi + index;
              
              return Positioned(
                left: 50 + (index % 5) * 80 + math.sin(offset) * 30,
                top: 100 + (index ~/ 5) * 120 + math.cos(offset * 0.7) * 20,
                child: Opacity(
                  opacity: 0.3 + math.sin(offset) * 0.2,
                  child: Transform.scale(
                    scale: 0.8 + math.cos(offset * 1.3) * 0.3,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
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