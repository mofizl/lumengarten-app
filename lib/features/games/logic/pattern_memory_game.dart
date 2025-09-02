import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_theme.dart';

class PatternMemoryGame extends StatefulWidget {
  const PatternMemoryGame({super.key});

  @override
  State<PatternMemoryGame> createState() => _PatternMemoryGameState();
}

class _PatternMemoryGameState extends State<PatternMemoryGame>
    with TickerProviderStateMixin {
  
  late AnimationController _sequenceController;
  late AnimationController _celebrationController;
  late Animation<double> _sequenceScale;
  late Animation<double> _celebrationRotation;
  
  final VoiceService _voiceService = VoiceService();
  
  List<int> _sequence = [];
  List<int> _userInput = [];
  int _currentStep = 0;
  int _level = 1;
  int _score = 0;
  bool _showingSequence = false;
  bool _acceptingInput = false;
  bool _isGameOver = false;
  
  final List<PatternShape> _shapes = [
    PatternShape(0, '🔴', Colors.red, 'Roter Kreis'),
    PatternShape(1, '🟢', Colors.green, 'Grüner Kreis'),  
    PatternShape(2, '🔵', Colors.blue, 'Blauer Kreis'),
    PatternShape(3, '🟡', Colors.yellow, 'Gelber Kreis'),
    PatternShape(4, '🟣', Colors.purple, 'Lila Kreis'),
    PatternShape(5, '🟠', Colors.orange, 'Orange Kreis'),
  ];
  
  @override
  void initState() {
    super.initState();
    
    _voiceService.initialize();
    
    _sequenceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _sequenceScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _sequenceController, curve: Curves.elasticOut),
    );
    
    _celebrationRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeInOut),
    );
    
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _sequence = [_generateRandomShape()];
      _userInput.clear();
      _currentStep = 0;
      _level = 1;
      _score = 0;
      _isGameOver = false;
    });
    
    _voiceService.speak('Merke dir die Reihenfolge der Farben!');
    
    Future.delayed(const Duration(seconds: 2), () {
      _showSequence();
    });
  }

  int _generateRandomShape() {
    // Verwende nur die ersten 4 Formen für niedrige Level
    int maxShapes = math.min(3 + _level, _shapes.length);
    return math.Random().nextInt(maxShapes);
  }

  void _showSequence() async {
    setState(() {
      _showingSequence = true;
      _acceptingInput = false;
    });
    
    for (int i = 0; i < _sequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        
        _sequenceController.forward().then((_) {
          _sequenceController.reverse();
        });
        
        // Voice-Feedback für jede Form
        _voiceService.speak(_shapes[_sequence[i]].name);
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      setState(() {
        _showingSequence = false;
        _acceptingInput = true;
        _currentStep = 0;
      });
      
      _voiceService.speak('Jetzt bist du dran! Tippe die Reihenfolge!');
    }
  }

  void _onShapeTapped(int shapeIndex) {
    if (!_acceptingInput || _isGameOver) return;
    
    setState(() {
      _userInput.add(shapeIndex);
    });
    
    // Voice-Feedback
    _voiceService.speak(_shapes[shapeIndex].name);
    
    // Prüfe ob der Eingabe-Schritt korrekt ist
    if (_userInput.length <= _sequence.length) {
      int currentIndex = _userInput.length - 1;
      
      if (_userInput[currentIndex] != _sequence[currentIndex]) {
        _gameOverHandler();
        return;
      }
      
      // Sequenz komplett und korrekt
      if (_userInput.length == _sequence.length) {
        _levelComplete();
      }
    }
  }

  void _levelComplete() {
    setState(() {
      _score += _level * 50;
      _level++;
    });
    
    _celebrationController.forward().then((_) {
      _celebrationController.reset();
    });
    
    _voiceService.speak('Super! Level $_level erreicht!');
    
    Future.delayed(const Duration(seconds: 2), () {
      _nextLevel();
    });
  }

  void _nextLevel() {
    // Erweitere die Sequenz
    setState(() {
      _sequence.add(_generateRandomShape());
      _userInput.clear();
      _currentStep = 0;
    });
    
    _voiceService.speak('Level $_level! Die Sequenz wird länger!');
    
    Future.delayed(const Duration(seconds: 1), () {
      _showSequence();
    });
  }

  void _gameOverHandler() {
    setState(() {
      _isGameOver = true;
      _acceptingInput = false;
    });
    
    _voiceService.speak('Oh nein! Versuche es nochmal!');
  }

  void _restart() {
    _startNewGame();
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    _celebrationController.dispose();
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
              AppTheme.lightPurple.withOpacity(0.3),
              AppTheme.primaryBlue.withOpacity(0.2),
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
                      'Muster-Memory',
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
              
              // Level Anzeige
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Level: $_level',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      'Länge: ${_sequence.length}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.magicGreen,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Anzeige
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _showingSequence 
                    ? 'Merke dir die Reihenfolge!' 
                    : _acceptingInput 
                      ? 'Tippe die Reihenfolge!'
                      : _isGameOver
                        ? 'Spiel beendet!'
                        : 'Bereit?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _isGameOver ? Colors.red : AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Sequenz Vorschau (nur während Sequenz-Anzeige)
              if (_showingSequence)
                Container(
                  height: 60,
                  margin: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_sequence.length, (index) {
                      return AnimatedBuilder(
                        animation: _sequenceScale,
                        builder: (context, child) {
                          double scale = (index == _currentStep && _showingSequence) 
                            ? _sequenceScale.value 
                            : 1.0;
                          
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _shapes[_sequence[index]].color.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _shapes[_sequence[index]].color,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _shapes[_sequence[index]].emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              
              // User Input Anzeige
              if (_acceptingInput && _userInput.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: _userInput.map((shapeIndex) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _shapes[shapeIndex].color.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _shapes[shapeIndex].color,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _shapes[shapeIndex].emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              
              Spacer(),
              
              // Spielfeld mit Formen
              Container(
                margin: const EdgeInsets.all(20),
                child: AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _celebrationRotation.value * 0.1,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: math.min(3 + _level, _shapes.length),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _onShapeTapped(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _shapes[index].color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _shapes[index].color,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _shapes[index].color.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _shapes[index].emoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              
              // Restart Button (wenn Game Over)
              if (_isGameOver)
                Container(
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: _restart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.magicGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Nochmal spielen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PatternShape {
  final int id;
  final String emoji;
  final Color color;
  final String name;

  PatternShape(this.id, this.emoji, this.color, this.name);
}