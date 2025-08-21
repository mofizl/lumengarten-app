import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/voice_service.dart';

class TouchToStartPage extends ConsumerStatefulWidget {
  const TouchToStartPage({super.key});

  @override
  ConsumerState<TouchToStartPage> createState() => _TouchToStartPageState();
}

class _TouchToStartPageState extends ConsumerState<TouchToStartPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  
  final VoiceService _voiceService = VoiceService();
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    
    // Voice Service initialisieren
    _voiceService.initialize();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _handleTouch() async {
    if (_isStarting) return;
    
    setState(() {
      _isStarting = true;
    });
    
    // Test Audio-System um sicherzustellen, dass es funktioniert
    try {
      await _voiceService.speak('Willkommen in Dunkis Lumengarten!');
    } catch (e) {
      // Bei Problemen mit Audio einfach weiter
      print('Audio test failed: $e');
    }
    
    // Kurz warten, dann zur Landing Page navigieren
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      context.go(AppConstants.landingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlue.withOpacity(0.8),
              AppTheme.magicGreen.withOpacity(0.6),
              AppTheme.lightPurple.withOpacity(0.7),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Magische Partikel im Hintergrund
            ...List.generate(20, (index) {
              return AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animValue = (_glowAnimation.value + delay) % 1.0;
                  return Positioned(
                    left: (index % 5) * (MediaQuery.of(context).size.width / 5) + 
                          50 * animValue,
                    top: (index ~/ 5) * (MediaQuery.of(context).size.height / 4) + 
                         30 * animValue,
                    child: Opacity(
                      opacity: (1.0 - animValue) * 0.6,
                      child: Container(
                        width: 4 + (index % 3) * 2,
                        height: 4 + (index % 3) * 2,
                        decoration: BoxDecoration(
                          color: AppTheme.starYellow,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.starYellow.withOpacity(0.6),
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
            
            // Hauptinhalt
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App-Logo/Titel
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Dunki Drachen-Emoji
                        Text(
                          '🐲',
                          style: const TextStyle(fontSize: 100),
                        ),
                        const SizedBox(height: 20),
                        
                        // App-Name
                        Text(
                          'Dunkis Lumengarten',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Untertitel
                        Text(
                          'Ein magisches Lernabenteuer',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.white.withOpacity(0.9),
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Touch-to-Start Button
                  AnimatedBuilder(
                    animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: GestureDetector(
                          onTap: _handleTouch,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.white.withOpacity(0.9),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.starYellow.withOpacity(_glowAnimation.value),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: _isStarting
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryBlue,
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        size: 60,
                                        color: AppTheme.primaryBlue,
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        'BERÜHR MICH',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryBlue,
                                          fontSize: 16,
                                          letterSpacing: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'um zu beginnen',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.darkGray,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Hinweis-Text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Durch Berühren aktivierst du die Kinderstimmen-Ausgabe',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.white.withOpacity(0.8),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}