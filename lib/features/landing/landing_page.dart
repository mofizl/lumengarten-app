import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/progress_service.dart';
import '../../core/services/voice_service.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _storyController;
  
  final VoiceService _voiceService = VoiceService();
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _storyAnimation;
  late Animation<double> _corruptionAnimation;
  
  bool _showBeautifulGarden = true;
  bool _showStoryText = false;
  bool _showCorruption = false;
  String _currentStoryText = "";

  @override
  void initState() {
    super.initState();
    
    // Voice Service initialisieren
    _voiceService.initialize();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _storyController = AnimationController(
      duration: const Duration(milliseconds: 8000), // 8 Sekunden für die gesamte Story
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Story-Animationen für die dramatische Sequenz
    _storyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _storyController, curve: Curves.easeInOut),
    );
    _corruptionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _storyController, 
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut), // Startet bei 50% der Story
      ),
    );
    
    _startStorySequence();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    
    // Pulsing animation für den Button
    _pulseController.repeat(reverse: true);
  }

  void _startStorySequence() async {
    // Phase 1: Zeige den schönen Garten (4 Sekunden)
    setState(() {
      _showBeautifulGarden = true;
      _currentStoryText = "Es war einmal ein wunderschöner magischer Garten...";
      _showStoryText = true;
    });
    _speakText(_currentStoryText);
    
    await Future.delayed(const Duration(seconds: 4));
    
    // Phase 2: Dunki stellt sich vor (4 Sekunden)  
    setState(() {
      _currentStoryText = "Hier lebte Dunki, der freundliche Gartendrachen! 🐲";
    });
    _speakText(_currentStoryText);
    
    await Future.delayed(const Duration(seconds: 4));
    
    // Phase 3: Der dunkle Zauber beginnt (3 Sekunden)
    setState(() {
      _currentStoryText = "Doch plötzlich... Ein dunkler Schatten zog über das Land! ⚡";
      _showCorruption = true;
    });
    _speakText(_currentStoryText);
    
    _storyController.forward();
    
    await Future.delayed(const Duration(seconds: 3));
    
    // Phase 4: Garten wird verwelkt (4 Sekunden)
    setState(() {
      _showBeautifulGarden = false;
      _currentStoryText = "Ein böser Zauberer hat alle Lichtblumen gestohlen! 😢";
    });
    _speakText(_currentStoryText);
    
    await Future.delayed(const Duration(seconds: 4));
    
    // Phase 5: Aufruf zur Hilfe
    setState(() {
      _currentStoryText = "Hallo! Ich bin Dunki! Hilfst du mir?";
    });
    _speakText(_currentStoryText);
    
    // Normale Animationen starten
    _startAnimations();
  }

  void _speakText(String text) {
    // Voice Service - bevorzugt Kinderstimmen-Audio, fallback zu TTS
    _voiceService.speak(text);
  }

  @override
  void dispose() {
    _voiceService.stop(); // Stoppe Voice Service beim Verlassen der Seite
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dynamischer Garten-Hintergrund basierend auf Story-Phase
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 2000),
                child: _showBeautifulGarden
                    ? Container(
                        key: const ValueKey('beautiful'),
                        width: double.infinity,
                        height: double.infinity,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            1.2, 0.0, 0.0, 0, 20,  // Heller und lebendiger
                            0.0, 1.1, 0.0, 0, 15,
                            0.0, 0.0, 1.2, 0, 25,
                            0, 0, 0, 1, 0,
                          ]),
                          child: Image.asset(
                            'assets/images/garden/awakening_garden.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        key: const ValueKey('withered'), 
                        width: double.infinity,
                        height: double.infinity,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.matrix([
                            0.4, 0.4, 0.4, 0, -20, // Grau und dunkel
                            0.4, 0.4, 0.4, 0, -20,
                            0.4, 0.4, 0.4, 0, -20,
                            0, 0, 0, 1, 0,
                          ]),
                          child: Image.asset(
                            'assets/images/landing/withered_garden.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
            ),
            
            // Korruptions-Overlay während der Transformation
            if (_showCorruption)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _corruptionAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.3, -0.5),
                          radius: 1.5,
                          colors: [
                            Colors.purple.shade900.withOpacity(0.8 * _corruptionAnimation.value),
                            Colors.black.withOpacity(0.6 * _corruptionAnimation.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      // Blitze und dunkle Energie-Effekte
                      child: Stack(
                        children: List.generate(8, (index) {
                          final delay = index * 0.1;
                          final animValue = (_corruptionAnimation.value + delay) % 1.0;
                          return Positioned(
                            left: 50.0 + index * 100.0,
                            top: 50.0 + 200.0 * animValue,
                            child: Opacity(
                              opacity: (1.0 - animValue) * _corruptionAnimation.value,
                              child: Icon(
                                index % 2 == 0 ? Icons.flash_on : Icons.cloud,
                                color: Colors.purple.shade300,
                                size: 20 + (index % 3) * 10,
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            
            // Dunkler Overlay für bessere Lesbarkeit
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                          Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                          Colors.black.withOpacity(0.7 * _fadeAnimation.value),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Magische Glitzer-Partikel über das gesamte Bild
            ...List.generate(12, (index) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animValue = (_pulseAnimation.value + delay) % 1.0;
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;
                  
                  return Positioned(
                    left: (50.0 + index * (screenWidth / 12)) % screenWidth,
                    top: 50.0 + (screenHeight * 0.8) * animValue,
                    child: Opacity(
                      opacity: (1.0 - animValue) * 0.8,
                      child: Container(
                        width: 4 + (index % 3) * 2,
                        height: 4 + (index % 3) * 2,
                        decoration: BoxDecoration(
                          color: index % 2 == 0 ? AppTheme.starYellow : AppTheme.moonSilver,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (index % 2 == 0 ? AppTheme.starYellow : AppTheme.moonSilver)
                                  .withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            
            // Content Overlay
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: AppStyles.pagePadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),
                      
                      // App-Titel mit verbesserter Sichtbarkeit
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutBack,
                          )),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.white.withOpacity(0.95),
                                  AppTheme.white.withOpacity(0.85),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: AppTheme.magicGreen.withOpacity(0.5),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: AppTheme.magicGreen.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Text(
                              AppConstants.appName,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [AppTheme.primaryPurple, AppTheme.magicGreen],
                                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 80.0)),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(flex: 2),
                      
                      // Sprechblase mit dynamischer Geschichte
                      if (_showStoryText)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 450),
                            margin: const EdgeInsets.only(left: 40),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 800),
                              child: CustomPaint(
                                key: ValueKey(_currentStoryText),
                                painter: SpeechBubblePainter(),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                                  child: Text(
                                    _currentStoryText,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      height: 1.4,
                                      color: AppTheme.darkGray,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      const Spacer(flex: 2),
                      
                      // Subtiler Button der ins Bild passt
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _slideController,
                          curve: Curves.easeOut,
                        )),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 60),
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + 0.02 * _pulseAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context.go(AppConstants.gardenRoute);
                                      },
                                      icon: const Icon(Icons.pets, size: 20),
                                      label: Text(
                                        'Ich helfe Dunki!',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: AppTheme.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.magicGreen.withOpacity(0.8),
                                        foregroundColor: AppTheme.white,
                                        minimumSize: const Size(180, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          side: BorderSide(
                                            color: AppTheme.magicGreen.withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        elevation: 4,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpeechBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    final shadowPath = Path();
    
    const radius = 12.0;
    const tailSize = 12.0;
    
    // Shadow path (offset)
    shadowPath.addRRect(RRect.fromLTRBR(
      2, 2, size.width + 2, size.height - tailSize + 2, 
      const Radius.circular(radius)
    ));
    
    // Tail shadow
    shadowPath.moveTo(22, size.height - tailSize + 2);
    shadowPath.lineTo(2, size.height + 2);
    shadowPath.lineTo(22 + tailSize, size.height - tailSize + 2);
    shadowPath.close();
    
    // Main bubble path
    path.addRRect(RRect.fromLTRBR(
      0, 0, size.width, size.height - tailSize, 
      const Radius.circular(radius)
    ));
    
    // Tail
    path.moveTo(20, size.height - tailSize);
    path.lineTo(0, size.height);
    path.lineTo(20 + tailSize, size.height - tailSize);
    path.close();
    
    // Draw shadow first
    canvas.drawPath(shadowPath, shadowPaint);
    
    // Draw bubble
    canvas.drawPath(path, paint);
    
    // Border
    final borderPaint = Paint()
      ..color = AppTheme.magicGreen.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}