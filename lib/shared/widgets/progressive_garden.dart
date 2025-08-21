import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/progress_service.dart';

class ProgressiveGarden extends ConsumerStatefulWidget {
  final double width;
  final double height;
  final BoxFit fit;
  final bool showOverlay;

  const ProgressiveGarden({
    super.key,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.showOverlay = true,
  });

  @override
  ConsumerState<ProgressiveGarden> createState() => _ProgressiveGardenState();
}

class _ProgressiveGardenState extends ConsumerState<ProgressiveGarden>
    with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  
  int _currentLevel = 0;
  int _targetLevel = 0;

  @override
  void initState() {
    super.initState();
    
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  String _getGardenImagePath(int level) {
    // Verwende beide vorhandene Bilder für echte Transformation
    switch (level) {
      case 0:
      case 1:
        return 'assets/images/landing/withered_garden.png'; // Verwelkt bis erste Besserung
      case 2:
      case 3:
      case 4:
        return 'assets/images/garden/awakening_garden.png'; // Erblühend bis strahlend
      default:
        return 'assets/images/landing/withered_garden.png';
    }
  }

  ColorFilter? _getColorFilter(int level) {
    switch (level) {
      case 0: // Komplett verwelkt
        return ColorFilter.matrix([
          0.4, 0.4, 0.4, 0, -20, // Sehr grau und dunkel
          0.4, 0.4, 0.4, 0, -20,
          0.4, 0.4, 0.4, 0, -20,
          0, 0, 0, 1, 0,
        ]);
      case 1: // Erste Hoffnung - etwas weniger grau
        return ColorFilter.matrix([
          0.6, 0.3, 0.3, 0, -10, // Leichte Verbesserung
          0.3, 0.7, 0.3, 0, -10,
          0.3, 0.3, 0.6, 0, -10,
          0, 0, 0, 1, 0,
        ]);
      case 2: // Erwachend - wechselt zu awakening_garden mit Dämpfung
        return ColorFilter.matrix([
          0.7, 0.1, 0.1, 0, 0, // Gedämpfte Farben
          0.1, 0.8, 0.1, 0, 0,
          0.1, 0.1, 0.7, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case 3: // Blühend - hellere Farben
        return ColorFilter.matrix([
          0.9, 0.05, 0.05, 0, 10, // Lebendige Farben
          0.05, 1.0, 0.05, 0, 10,
          0.05, 0.05, 0.9, 0, 10,
          0, 0, 0, 1, 0,
        ]);
      case 4: // Strahlend - maximale Pracht
        return ColorFilter.matrix([
          1.1, 0.0, 0.0, 0, 20, // Sehr hell und strahlend
          0.0, 1.2, 0.0, 0, 15,
          0.0, 0.0, 1.1, 0, 25,
          0, 0, 0, 1, 0,
        ]);
      default:
        return null;
    }
  }

  void _animateToLevel(int newLevel) {
    if (newLevel != _currentLevel) {
      setState(() {
        _targetLevel = newLevel;
      });
      
      _transitionController.forward().then((_) {
        setState(() {
          _currentLevel = _targetLevel;
        });
        _transitionController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressData = ref.watch(progressProvider);
    
    // Trigger animation when garden level changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (progressData.gardenLevel != _currentLevel) {
        _animateToLevel(progressData.gardenLevel);
      }
    });

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Current garden level mit Farbfilter
          ColorFiltered(
            colorFilter: _getColorFilter(_currentLevel) ?? 
                const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
            child: Image.asset(
              _getGardenImagePath(_currentLevel),
              fit: widget.fit,
              width: widget.width,
              height: widget.height,
            ),
          ),
          
          // Transition overlay for smooth crossfade
          if (_transitionController.isAnimating)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: ColorFiltered(
                    colorFilter: _getColorFilter(_targetLevel) ?? 
                        const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: Image.asset(
                      _getGardenImagePath(_targetLevel),
                      fit: widget.fit,
                      width: widget.width,
                      height: widget.height,
                    ),
                  ),
                );
              },
            ),
          
          // Magical transformation particles during transition
          if (_transitionController.isAnimating)
            ...List.generate(20, (index) {
              return AnimatedBuilder(
                animation: _transitionController,
                builder: (context, child) {
                  final progress = _transitionController.value;
                  final delay = index * 0.05;
                  final particleProgress = (progress - delay).clamp(0.0, 1.0);
                  
                  return Positioned(
                    left: (widget.width * 0.1) + (index % 5) * (widget.width * 0.2),
                    top: widget.height * (0.2 + particleProgress * 0.6),
                    child: Opacity(
                      opacity: (1.0 - particleProgress) * 0.8,
                      child: Container(
                        width: 6 + (index % 3) * 2,
                        height: 6 + (index % 3) * 2,
                        decoration: BoxDecoration(
                          color: _getParticleColor(progressData.gardenLevel),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getParticleColor(progressData.gardenLevel)
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
          
          // Progress overlay
          if (widget.showOverlay)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getBorderColor(progressData.gardenLevel),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _getGardenStatusText(progressData.gardenLevel),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progressData.overallProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getBorderColor(progressData.gardenLevel),
                      ),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progressData.overallProgress * 100).toInt()}% erwacht',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getParticleColor(int level) {
    switch (level) {
      case 1: return Colors.green.shade400;      // Knospen
      case 2: return Colors.pink.shade300;       // Blüten
      case 3: return Colors.blue.shade300;       // Kristalle
      case 4: return Colors.yellow.shade300;     // Strahlendes Licht
      default: return Colors.grey.shade400;
    }
  }

  Color _getBorderColor(int level) {
    switch (level) {
      case 1: return Colors.green.shade400;
      case 2: return Colors.pink.shade400;
      case 3: return Colors.blue.shade400;
      case 4: return Colors.yellow.shade600;
      default: return Colors.grey.shade400;
    }
  }

  String _getGardenStatusText(int level) {
    switch (level) {
      case 0: return '🌑 Dunkis Garten ist verwelkt und traurig...';
      case 1: return '🌱 Dunki spürt einen Hoffnungsschimmer!';
      case 2: return '🌸 Dunkis Garten beginnt zu erblühen!';
      case 3: return '💎 Magische Energie durchströmt Dunkis Reich!';
      case 4: return '✨ Dunkis Lumengarten erstrahlt in voller Pracht!';
      default: return '';
    }
  }
}