import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/voice_service.dart';
import '../../shared/widgets/progressive_garden.dart';

class GardenPage extends ConsumerStatefulWidget {
  const GardenPage({super.key});

  @override
  ConsumerState<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends ConsumerState<GardenPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _floatingController;
  
  final VoiceService _voiceService = VoiceService();
  
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _cardsStaggerAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Voice Service initialisieren
    _voiceService.initialize();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeInOut),
    );
    _cardsStaggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOutCubic),
    );
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _cardsController.forward();
    
    // Schwebe-Animation dauerhaft wiederholen
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _voiceService.stop(); // Stoppe Voice Service beim Verlassen der Seite
    _headerController.dispose();
    _cardsController.dispose();
    _floatingController.dispose();
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
            // Progressive Garden als Vollbild-Hintergrund
            Positioned.fill(
              child: ProgressiveGarden(
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                showOverlay: true, // Zeige Fortschritt-Overlay
              ),
            ),
            
            // Back Button - oben links
            Positioned(
              top: 50,
              left: 20,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go(AppConstants.landingRoute),
                  ),
                ),
              ),
            ),
            
            // Titel - oben mittig mit custom Grafik
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: SafeArea(
                child: FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
                    ),
                    child: Container(
                      height: 160,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image.asset(
                        'assets/images/überschrift lumengarten.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'Dunkis magischer Lumengarten',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 24,
                              shadows: [
                                Shadow(
                                  color: AppTheme.magicGreen.withOpacity(0.8),
                                  blurRadius: 12,
                                  offset: const Offset(0, 0),
                                ),
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Lernbereiche frei über den Screen verteilt
            // Lese-Abenteuer - links oben
            Positioned(
              top: 200,
              left: 40,
              child: _buildFloatingIcon(
                iconPath: 'assets/images/icons/reading_magic.png',
                color: AppTheme.primaryBlue,
                delay: 0.0,
                onTap: () {
                  _voiceService.speak('Lese-Abenteuer. Magische Geschichten.');
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted) context.go('/games/reading');
                  });
                },
              ),
            ),
            
            // Schreib-Werkstatt - rechts oben
            Positioned(
              top: 180,
              right: 50,
              child: _buildFloatingIcon(
                iconPath: 'assets/images/icons/writing_magic.png',
                color: AppTheme.magicGreen,
                delay: 0.2,
                onTap: () {
                  _voiceService.speak('Schreib-Werkstatt. Zauberhafte Buchstaben.');
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted) context.go('/games/writing');
                  });
                },
              ),
            ),
            
            // Logik-Labor - links unten
            Positioned(
              bottom: 200,
              left: 60,
              child: _buildFloatingIcon(
                iconPath: 'assets/images/icons/logic_magic.png',
                color: AppTheme.lightPurple,
                delay: 0.4,
                onTap: () {
                  _voiceService.speak('Logik-Labor. Clevere Rätsel.');
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted) context.go('/games/logic');
                  });
                },
              ),
            ),
            
            // Zahlen-Zoo - rechts unten
            Positioned(
              bottom: 180,
              right: 40,
              child: _buildFloatingIcon(
                iconPath: 'assets/images/icons/math_magic.png',
                color: AppTheme.starYellow,
                delay: 0.6,
                onTap: () {
                  _voiceService.speak('Zahlen-Zoo. Tierische Mathematik.');
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (mounted) context.go('/games/math');
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIcon({
    required String iconPath,
    required Color color,
    required double delay,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        final floatingOffset = 8 * _floatingAnimation.value * (1 + delay * 0.5);
        return Transform.translate(
          offset: Offset(0, floatingOffset),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _cardsController,
                curve: Interval(delay * 0.5, (delay * 0.5) + 0.5, curve: Curves.elasticOut),
              ),
            ),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: color.withOpacity(0.6),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    iconPath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.school,
                        size: 40,
                        color: color,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
