import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/progress_service.dart';
import '../../shared/widgets/progressive_garden.dart';

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
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
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
    
    _startAnimations();
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

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
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
            // Progressiver Vollbild-Garten-Hintergrund
            Positioned.fill(
              child: ProgressiveGarden(
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                showOverlay: false, // Kein Overlay auf Landing Page
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
                      
                      // Sprechblase mit Geschichte
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              margin: const EdgeInsets.only(left: 40),
                              child: CustomPaint(
                                painter: SpeechBubblePainter(),
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                                  child: Text(
                                    'Hilf mir... Im magischen Lumengarten ist etwas Schreckliches passiert! '
                                    'Alle Lichtblumen sind verwelkt. Nur DU kannst das Licht zurückbringen!',
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
                                        'Hilfst du mir?',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: AppTheme.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.9),
                                        foregroundColor: AppTheme.white,
                                        minimumSize: const Size(180, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        elevation: 8,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      // Demo-Button für Progression (zum Testen)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(progressProvider.notifier).simulateProgress();
                          },
                          child: const Text('🌟 Demo: Garten erwecken'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.withOpacity(0.8),
                            foregroundColor: Colors.white,
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