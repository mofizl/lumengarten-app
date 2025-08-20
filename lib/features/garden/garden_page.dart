import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/learning_area_card.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _floatingController;
  
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _cardsStaggerAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
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
    _headerController.dispose();
    _cardsController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein Lumengarten'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.landingRoute),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightBlue,
              AppTheme.magicGreen,
            ],
          ),
        ),
        child: Padding(
          padding: AppStyles.pagePadding,
          child: Column(
            children: [
              // Magischer Garten Header mit Animationen
              FadeTransition(
                opacity: _headerFadeAnimation,
                child: SlideTransition(
                  position: _headerSlideAnimation,
                  child: AnimatedBuilder(
                    animation: _floatingAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 5 * _floatingAnimation.value),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: AppStyles.cardRadius,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: AppTheme.magicGreen.withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: AppStyles.cardRadius,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Haupt-Garten-Bild
                                Image.asset(
                                  'assets/images/garden/awakening_garden.png',
                                  fit: BoxFit.cover,
                                ),
                                // Magischer Schimmer-Overlay
                                AnimatedBuilder(
                                  animation: _floatingAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppTheme.starYellow.withOpacity(0.1 + 0.1 * _floatingAnimation.value),
                                            Colors.transparent,
                                            AppTheme.magicGreen.withOpacity(0.1 + 0.1 * _floatingAnimation.value),
                                            Colors.transparent,
                                            AppTheme.primaryPurple.withOpacity(0.1 + 0.1 * _floatingAnimation.value),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Fortschritts-Overlay mit Animation
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: _headerController,
                                      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                                    ),
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.5),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: _headerController,
                                        curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
                                      )),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.white.withOpacity(0.95),
                                              AppTheme.white.withOpacity(0.9),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppTheme.magicGreen.withOpacity(0.3),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.magicGreen.withOpacity(0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            AnimatedBuilder(
                                              animation: _floatingAnimation,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: 1.0 + 0.02 * _floatingAnimation.value,
                                                  child: Text(
                                                    'Dein magischer Garten erwacht... 🌱',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.darkGray,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            AnimatedBuilder(
                                              animation: _headerController,
                                              builder: (context, child) {
                                                return LinearProgressIndicator(
                                                  value: 0.2 * _headerController.value,
                                                  backgroundColor: AppTheme.lightGray,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    AppTheme.magicGreen,
                                                  ),
                                                  minHeight: 6,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Glitzer-Partikel-Effekt
                                ...List.generate(6, (index) {
                                  return AnimatedBuilder(
                                    animation: _floatingController,
                                    builder: (context, child) {
                                      final delay = index * 0.2;
                                      final animValue = (_floatingAnimation.value + delay) % 1.0;
                                      return Positioned(
                                        left: 50.0 + index * 45.0,
                                        top: 20.0 + 30.0 * animValue,
                                        child: Opacity(
                                          opacity: (1.0 - animValue) * 0.8,
                                          child: Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: AppTheme.starYellow,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.starYellow.withOpacity(0.5),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 4 Lernbereiche im Garten
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.1),
                    borderRadius: AppStyles.cardRadius,
                    border: Border.all(
                      color: AppTheme.moonSilver.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '🌟 Wähle deinen Lernbereich 🌟',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      
                      // Erste Reihe: Lesen & Schreiben mit gestaffelter Animation
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _cardsStaggerAnimation,
                                builder: (context, child) {
                                  final cardDelay = 0.0;
                                  final cardProgress = Curves.easeOutBack.transform(
                                    (_cardsStaggerAnimation.value - cardDelay).clamp(0.0, 1.0),
                                  );
                                  return Transform.translate(
                                    offset: Offset(0, 50 * (1 - cardProgress)),
                                    child: Opacity(
                                      opacity: cardProgress,
                                      child: Transform.scale(
                                        scale: 0.8 + 0.2 * cardProgress,
                                        child: LearningAreaCard(
                                          title: 'Lese-Abenteuer',
                                          emoji: '📚',
                                          description: 'Buchstaben\n& Wörter',
                                          progress: 0.2,
                                          color: AppTheme.lightPurple,
                                          onTap: () => context.go('/games/reading'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _cardsStaggerAnimation,
                                builder: (context, child) {
                                  final cardDelay = 0.2;
                                  final cardProgress = Curves.easeOutBack.transform(
                                    (_cardsStaggerAnimation.value - cardDelay).clamp(0.0, 1.0),
                                  );
                                  return Transform.translate(
                                    offset: Offset(0, 50 * (1 - cardProgress)),
                                    child: Opacity(
                                      opacity: cardProgress,
                                      child: Transform.scale(
                                        scale: 0.8 + 0.2 * cardProgress,
                                        child: LearningAreaCard(
                                          title: 'Schreib-Werkstatt',
                                          emoji: '✏️',
                                          description: 'Motorik\n& Formen',
                                          progress: 0.1,
                                          color: AppTheme.starYellow,
                                          onTap: () => context.go('/games/writing'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Zweite Reihe: Logik & Mathe mit gestaffelter Animation
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _cardsStaggerAnimation,
                                builder: (context, child) {
                                  final cardDelay = 0.4;
                                  final cardProgress = Curves.easeOutBack.transform(
                                    (_cardsStaggerAnimation.value - cardDelay).clamp(0.0, 1.0),
                                  );
                                  return Transform.translate(
                                    offset: Offset(0, 50 * (1 - cardProgress)),
                                    child: Opacity(
                                      opacity: cardProgress,
                                      child: Transform.scale(
                                        scale: 0.8 + 0.2 * cardProgress,
                                        child: LearningAreaCard(
                                          title: 'Logik-Labor',
                                          emoji: '🧪',
                                          description: 'Denken\n& Rätseln',
                                          progress: 0.0,
                                          color: AppTheme.magicGreen,
                                          onTap: () => context.go('/games/logic'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _cardsStaggerAnimation,
                                builder: (context, child) {
                                  final cardDelay = 0.6;
                                  final cardProgress = Curves.easeOutBack.transform(
                                    (_cardsStaggerAnimation.value - cardDelay).clamp(0.0, 1.0),
                                  );
                                  return Transform.translate(
                                    offset: Offset(0, 50 * (1 - cardProgress)),
                                    child: Opacity(
                                      opacity: cardProgress,
                                      child: Transform.scale(
                                        scale: 0.8 + 0.2 * cardProgress,
                                        child: LearningAreaCard(
                                          title: 'Zahlen-Zoo',
                                          emoji: '🦁',
                                          description: 'Rechnen\n& Zählen',
                                          progress: 0.0,
                                          color: AppTheme.primaryBlue,
                                          onTap: () => context.go('/games/math'),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Fortschritts-Button
              ElevatedButton.icon(
                onPressed: () {
                  context.go(AppConstants.progressRoute);
                },
                icon: const Icon(Icons.analytics, size: 24),
                label: const Text('Meine Erfolge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: AppTheme.white,
                  minimumSize: const Size(180, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}