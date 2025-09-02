import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_theme.dart';

class NumberCountingZoo extends StatefulWidget {
  const NumberCountingZoo({super.key});

  @override
  State<NumberCountingZoo> createState() => _NumberCountingZooState();
}

class _NumberCountingZooState extends State<NumberCountingZoo>
    with TickerProviderStateMixin {
  
  late AnimationController _animalController;
  late AnimationController _successController;
  late AnimationController _floatingController;
  late Animation<double> _animalBounce;
  late Animation<double> _successScale;
  late Animation<double> _floatingAnimation;
  
  final VoiceService _voiceService = VoiceService();
  
  int _targetNumber = 1;
  int _selectedAnswer = 0;
  int _score = 0;
  int _level = 1;
  bool _showingSuccess = false;
  bool _gameCompleted = false;
  
  List<ZooAnimal> _currentAnimals = [];
  List<int> _answerOptions = [];
  
  final List<ZooAnimal> _availableAnimals = [
    ZooAnimal('assets/images/games/animals/monkey.png', 'Affe', Colors.brown),
    ZooAnimal('assets/images/games/animals/lion.png', 'Löwe', Colors.orange),
    ZooAnimal('assets/images/games/animals/elephant.png', 'Elefant', Colors.grey.shade600),
    ZooAnimal('assets/images/games/animals/giraffe.png', 'Giraffe', Colors.yellow.shade700),
  ];
  
  @override
  void initState() {
    super.initState();
    
    _voiceService.initialize();
    
    _animalController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _animalBounce = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animalController, curve: Curves.bounceOut),
    );
    
    _successScale = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    
    _floatingController.repeat(reverse: true);
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    // Level bestimmt maximale Anzahl (1-10)
    int maxNumber = math.min(3 + _level, 10);
    _targetNumber = 1 + math.Random().nextInt(maxNumber);
    
    // Tiere für die aktuelle Frage generieren
    ZooAnimal selectedAnimal = _availableAnimals[
      math.Random().nextInt(_availableAnimals.length)
    ];
    
    _currentAnimals = List.generate(
      _targetNumber, 
      (index) => selectedAnimal.copyWith(id: index),
    );
    
    // Antwortoptionen generieren
    _generateAnswerOptions();
    
    setState(() {
      _selectedAnswer = 0;
      _showingSuccess = false;
    });
    
    // Tiere animiert einblenden
    _animalController.forward();
    
    // Voice-Anweisung
    _voiceService.speak(
      'Zähle die ${selectedAnimal.name}s! Wie viele siehst du?'
    );
  }

  void _generateAnswerOptions() {
    _answerOptions = [_targetNumber];
    
    // Falsche Antworten hinzufügen
    while (_answerOptions.length < 4) {
      int wrongAnswer = 1 + math.Random().nextInt(10);
      if (!_answerOptions.contains(wrongAnswer)) {
        _answerOptions.add(wrongAnswer);
      }
    }
    
    // Mischen
    _answerOptions.shuffle();
  }

  void _onAnswerSelected(int answer) {
    if (_showingSuccess) return;
    
    setState(() {
      _selectedAnswer = answer;
    });
    
    if (answer == _targetNumber) {
      _showSuccess();
    } else {
      _showError(answer);
    }
  }

  void _showSuccess() {
    setState(() {
      _showingSuccess = true;
      _score += _targetNumber * 10;
    });
    
    _successController.forward().then((_) {
      _successController.reset();
    });
    
    _voiceService.speak(
      'Richtig! Es sind $_targetNumber ${_currentAnimals.first.name}s!'
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      _nextLevel();
    });
  }

  void _showError(int wrongAnswer) {
    _voiceService.speak(
      'Das sind $wrongAnswer. Zähle nochmal genau!'
    );
    
    // Tiere nochmal betonen
    Future.delayed(const Duration(seconds: 1), () {
      _highlightAnimals();
    });
  }

  void _highlightAnimals() {
    _animalController.reset();
    _animalController.forward();
  }

  void _nextLevel() {
    if (_targetNumber >= 10) {
      setState(() {
        _gameCompleted = true;
      });
      _voiceService.speak('Fantastisch! Du kannst super zählen!');
      return;
    }
    
    setState(() {
      _level++;
    });
    
    _animalController.reset();
    _generateNewQuestion();
  }

  void _restart() {
    setState(() {
      _level = 1;
      _score = 0;
      _gameCompleted = false;
    });
    
    _animalController.reset();
    _generateNewQuestion();
  }

  @override
  void dispose() {
    _animalController.dispose();
    _successController.dispose();
    _floatingController.dispose();
    _voiceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/games/zoo_background.png'),
            fit: BoxFit.cover,
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
                      'Zahlen-Zoo',
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
              
              // Level & Frage
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
                child: Column(
                  children: [
                    Text(
                      'Level $_level',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _gameCompleted 
                        ? '🎉 Du hast gewonnen! 🎉'
                        : 'Wie viele ${_currentAnimals.isNotEmpty ? '${_currentAnimals.first.name}s' : 'Tiere'} siehst du?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _gameCompleted ? AppTheme.magicGreen : AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Tiere Anzeige
              if (!_gameCompleted)
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.magicGreen, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _animalBounce,
                      builder: (context, child) {
                        return AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: _currentAnimals.length,
                              itemBuilder: (context, index) {
                                final animal = _currentAnimals[index];
                                final delay = index * 0.1;
                                final floatingOffset = 10 * _floatingAnimation.value * 
                                  math.sin((index * 0.5) + (_floatingAnimation.value * 2 * math.pi));
                                
                                return Transform.scale(
                                  scale: _animalBounce.value,
                                  child: Transform.translate(
                                    offset: Offset(0, floatingOffset),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: animal.color.withOpacity(0.3),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: animal.color.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: AnimatedBuilder(
                                          animation: _successController,
                                          builder: (context, child) {
                                            double scale = _showingSuccess ? _successScale.value : 1.0;
                                            return Transform.scale(
                                              scale: scale,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.asset(
                                                  animal.imagePath,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 60,
                                                      height: 60,
                                                      decoration: BoxDecoration(
                                                        color: animal.color.withOpacity(0.3),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons.pets,
                                                        size: 30,
                                                        color: animal.color,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              
              // Antwort-Buttons
              if (!_gameCompleted)
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Wähle die richtige Zahl:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _answerOptions.map((option) {
                          bool isSelected = _selectedAnswer == option;
                          bool isCorrect = option == _targetNumber;
                          bool showResult = _selectedAnswer != 0;
                          
                          Color buttonColor = AppTheme.lightBlue;
                          if (showResult) {
                            if (isCorrect) {
                              buttonColor = AppTheme.magicGreen;
                            } else if (isSelected) {
                              buttonColor = Colors.red;
                            }
                          }
                          
                          return GestureDetector(
                            onTap: () => _onAnswerSelected(option),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    buttonColor.withOpacity(0.8),
                                    buttonColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white,
                                  width: isSelected ? 4 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                  if (isSelected)
                                    BoxShadow(
                                      color: buttonColor.withOpacity(0.6),
                                      blurRadius: 15,
                                      offset: const Offset(0, 0),
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$option',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 2,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              
              // Restart Button (wenn Game Complete)
              if (_gameCompleted)
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

class ZooAnimal {
  final String imagePath;
  final String name;
  final Color color;
  final int? id;

  ZooAnimal(this.imagePath, this.name, this.color, {this.id});
  
  ZooAnimal copyWith({int? id}) {
    return ZooAnimal(imagePath, name, color, id: id ?? this.id);
  }
}