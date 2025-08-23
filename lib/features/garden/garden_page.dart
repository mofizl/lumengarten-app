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
  late Animation<Offset> _headerSlideAnimation;
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
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack));
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
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.darkGray),
                    onPressed: () => context.go(AppConstants.landingRoute),
                  ),
                ),
              ),
            ),
            
            // Titel - oben mittig
            Positioned(
              top: 50,
              left: 80,
              right: 20,
              child: SafeArea(
                child: FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppTheme.magicGreen.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      'Dunkis magischer Lumengarten',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            
            // Lernbereich-Karten - unten
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: SafeArea(
                child: FadeTransition(
                  opacity: _cardsStaggerAnimation,
                  child: Container(
                    height: 320,
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        _buildFloatingLearningCard(
                          title: 'Lese-Abenteuer',
                          iconPath: 'assets/images/icons/reading_magic.png',
                          description: 'Magische Geschichten',
                          progress: 0.2,
                          color: AppTheme.primaryBlue,
                          delay: 0.0,
                          onTap: () {
                            _voiceService.speak('Lese-Abenteuer. Magische Geschichten.');
                            Future.delayed(const Duration(milliseconds: 1500), () {
                              context.go('/games/reading');
                            });
                          },
                        ),
                        _buildFloatingLearningCard(
                          title: 'Schreib-Werkstatt', 
                          iconPath: 'assets/images/icons/writing_magic.png',
                          description: 'Zauberhafte Buchstaben',
                          progress: 0.1,
                          color: AppTheme.magicGreen,
                          delay: 0.2,
                          onTap: () {
                            _voiceService.speak('Schreib-Werkstatt. Zauberhafte Buchstaben.');
                            Future.delayed(const Duration(milliseconds: 1500), () {
                              context.go('/games/writing');
                            });
                          },
                        ),
                        _buildFloatingLearningCard(
                          title: 'Logik-Labor',
                          iconPath: 'assets/images/icons/logic_magic.png',
                          description: 'Clevere Rätsel',
                          progress: 0.0,
                          color: AppTheme.lightPurple,
                          delay: 0.4,
                          onTap: () {
                            _voiceService.speak('Logik-Labor. Clevere Rätsel.');
                            Future.delayed(const Duration(milliseconds: 1500), () {
                              context.go('/games/logic');
                            });
                          },
                        ),
                        _buildFloatingLearningCard(
                          title: 'Zahlen-Zoo',
                          iconPath: 'assets/images/icons/math_magic.png',
                          description: 'Tierische Mathematik',
                          progress: 0.0,
                          color: AppTheme.starYellow,
                          delay: 0.6,
                          onTap: () {
                            _voiceService.speak('Zahlen-Zoo. Tierische Mathematik.');
                            Future.delayed(const Duration(milliseconds: 1500), () {
                              context.go('/games/math');
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingLearningCard({
    required String title,
    required String iconPath,
    required String description,
    required double progress,
    required Color color,
    required double delay,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        final floatingOffset = 3 * _floatingAnimation.value * (1 + delay);
        return Transform.translate(
          offset: Offset(0, floatingOffset),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: _cardsController,
                curve: Interval(delay, delay + 0.4, curve: Curves.elasticOut),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              iconPath,
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.school,
                                  size: 30,
                                  color: color,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppTheme.lightGray,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 4,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
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
