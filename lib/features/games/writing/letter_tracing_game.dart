import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_theme.dart';

class LetterTracingGame extends StatefulWidget {
  const LetterTracingGame({super.key});

  @override
  State<LetterTracingGame> createState() => _LetterTracingGameState();
}

class _LetterTracingGameState extends State<LetterTracingGame>
    with TickerProviderStateMixin {
  
  late AnimationController _sparkleController;
  late AnimationController _successController;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _successScale;
  
  final VoiceService _voiceService = VoiceService();
  
  String _currentLetter = 'A';
  List<Offset> _tracedPoints = [];
  List<Offset> _targetPath = [];
  bool _isTracing = false;
  bool _letterCompleted = false;
  int _score = 0;
  int _currentLetterIndex = 0;
  List<ParticleEffect> _particles = [];
  
  final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  
  // Vereinfachte Buchstabenpfade (Punkte für Linien)
  final Map<String, List<Offset>> _letterPaths = {
    'A': [
      Offset(100, 200), Offset(150, 50), Offset(200, 200), // Dreieck
      Offset(125, 125), Offset(175, 125), // Querstrich
    ],
    'B': [
      Offset(100, 50), Offset(100, 200), // Vertikal
      Offset(100, 50), Offset(150, 75), Offset(150, 125), Offset(100, 125), // Oberer Bogen
      Offset(100, 125), Offset(175, 150), Offset(175, 175), Offset(100, 200), // Unterer Bogen
    ],
    'C': [
      Offset(175, 75), Offset(125, 50), Offset(100, 100), // Oberer Bogen
      Offset(100, 150), Offset(125, 200), Offset(175, 175), // Unterer Bogen
    ],
    'O': [
      Offset(150, 50), Offset(100, 100), Offset(100, 150), // Links
      Offset(150, 200), Offset(200, 150), Offset(200, 100), Offset(150, 50), // Kreis schließen
    ],
  };
  
  @override
  void initState() {
    super.initState();
    
    _voiceService.initialize();
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
    
    _successScale = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    
    _initializeLetter();
    _sparkleController.repeat();
  }

  void _initializeLetter() {
    setState(() {
      _currentLetter = _letters[_currentLetterIndex];
      _targetPath = _letterPaths[_currentLetter] ?? _letterPaths['A']!;
      _tracedPoints.clear();
      _letterCompleted = false;
    });
    
    _voiceService.speak('Zeichne den Buchstaben $_currentLetter nach!');
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isTracing = true;
      _tracedPoints.clear();
      _tracedPoints.add(details.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isTracing) {
      setState(() {
        _tracedPoints.add(details.localPosition);
      });
      
      // Prüfe Nähe zur Ziellinie
      _checkTracing(details.localPosition);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isTracing = false;
    });
    
    if (_tracedPoints.length > 10) {
      _evaluateTracing();
    }
  }

  void _checkTracing(Offset currentPoint) {
    // Einfache Distanz-Prüfung zu Zielpunkten
    for (Offset targetPoint in _targetPath) {
      double distance = (currentPoint - targetPoint).distance;
      if (distance < 30) {
        _addParticle(currentPoint);
      }
    }
  }

  void _evaluateTracing() {
    // Bewertung basierend auf Nähe zu Zielpfad
    int correctPoints = 0;
    
    for (Offset tracedPoint in _tracedPoints) {
      for (Offset targetPoint in _targetPath) {
        double distance = (tracedPoint - targetPoint).distance;
        if (distance < 40) {
          correctPoints++;
          break;
        }
      }
    }
    
    double accuracy = correctPoints / _targetPath.length;
    
    if (accuracy > 0.6) {
      _completeLetterSuccess();
    } else {
      _voiceService.speak('Versuche es noch einmal! Du schaffst das!');
    }
  }

  void _completeLetterSuccess() {
    setState(() {
      _letterCompleted = true;
      _score += 100;
    });
    
    _successController.forward().then((_) {
      _successController.reset();
    });
    
    _voiceService.speak('Super! Du hast den Buchstaben $_currentLetter geschafft!');
    
    // Nach 2 Sekunden zum nächsten Buchstaben
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentLetterIndex < _letters.length - 1) {
        setState(() {
          _currentLetterIndex++;
        });
        _initializeLetter();
      } else {
        _voiceService.speak('Fantastisch! Du hast alle Buchstaben gemeistert!');
      }
    });
  }

  void _addParticle(Offset position) {
    setState(() {
      _particles.add(ParticleEffect(
        position: position,
        color: AppTheme.magicGreen,
        createdAt: DateTime.now(),
      ));
    });
    
    // Partikel nach 1 Sekunde entfernen
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _particles.removeWhere((particle) => 
          DateTime.now().difference(particle.createdAt).inSeconds > 1);
      });
    });
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _successController.dispose();
    _voiceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightBlue.withOpacity(0.3),
              AppTheme.magicGreen.withOpacity(0.2),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 30),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Buchstaben nachzeichnen',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
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
              ),
              
              // Aktueller Buchstabe Anzeige
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zeichne nach: ',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    AnimatedBuilder(
                      animation: _successScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _letterCompleted ? _successScale.value : 1.0,
                          child: Text(
                            _currentLetter,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _letterCompleted ? AppTheme.magicGreen : AppTheme.primaryBlue,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Zeichenbereich
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.lightBlue, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: CustomPaint(
                      painter: LetterTracingPainter(
                        targetPath: _targetPath,
                        tracedPoints: _tracedPoints,
                        particles: _particles,
                        sparkleAnimation: _sparkleAnimation,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
              
              // Fortschrittsanzeige
              Container(
                margin: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_letters.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: index <= _currentLetterIndex 
                          ? (index == _currentLetterIndex && _letterCompleted 
                              ? AppTheme.magicGreen 
                              : AppTheme.lightBlue)
                          : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LetterTracingPainter extends CustomPainter {
  final List<Offset> targetPath;
  final List<Offset> tracedPoints;
  final List<ParticleEffect> particles;
  final Animation<double> sparkleAnimation;

  LetterTracingPainter({
    required this.targetPath,
    required this.tracedPoints,
    required this.particles,
    required this.sparkleAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Zielpfad zeichnen (gestrichelt)
    final targetPaint = Paint()
      ..color = AppTheme.lightBlue.withOpacity(0.5)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Gestrichelter Pfad für Ziel
    for (int i = 0; i < targetPath.length - 1; i++) {
      _drawDashedLine(canvas, targetPath[i], targetPath[i + 1], targetPaint);
    }
    
    // Zielpunkte als Kreise
    final dotPaint = Paint()
      ..color = AppTheme.primaryBlue.withOpacity(0.7 + 0.3 * sparkleAnimation.value)
      ..style = PaintingStyle.fill;
      
    for (Offset point in targetPath) {
      canvas.drawCircle(point, 8, dotPaint);
    }

    // Gezeichnete Linie
    if (tracedPoints.length > 1) {
      final tracePaint = Paint()
        ..color = AppTheme.magicGreen
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(tracedPoints.first.dx, tracedPoints.first.dy);
      
      for (int i = 1; i < tracedPoints.length; i++) {
        path.lineTo(tracedPoints[i].dx, tracedPoints[i].dy);
      }
      
      canvas.drawPath(path, tracePaint);
    }

    // Partikel-Effekte
    for (ParticleEffect particle in particles) {
      final particlePaint = Paint()
        ..color = particle.color.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(particle.position, 4, particlePaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 8;
    const dashSpace = 4;
    
    final direction = (end - start);
    final length = direction.distance;
    final unitVector = direction / length;
    
    double distance = 0;
    while (distance < length) {
      final dashEnd = math.min(distance + dashWidth, length);
      canvas.drawLine(
        start + unitVector * distance,
        start + unitVector * dashEnd,
        paint,
      );
      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticleEffect {
  final Offset position;
  final Color color;
  final DateTime createdAt;

  ParticleEffect({
    required this.position,
    required this.color,
    required this.createdAt,
  });
}