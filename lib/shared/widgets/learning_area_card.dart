import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LearningAreaCard extends StatefulWidget {
  final String title;
  final String emoji;
  final String description;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  const LearningAreaCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.description,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  @override
  State<LearningAreaCard> createState() => _LearningAreaCardState();
}

class _LearningAreaCardState extends State<LearningAreaCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 8.0, end: 15.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Pulse-Animation für Karten mit Fortschritt
    if (widget.progress > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onEnter() {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onExit() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  Widget _getIconForTitle(String title) {
    switch (title) {
      case 'Lese-Abenteuer':
        return Image.asset(
          'assets/images/icons/reading_magic.png',
          fit: BoxFit.cover,
        );
      case 'Schreib-Werkstatt':
        return Image.asset(
          'assets/images/icons/writing_magic.png',
          fit: BoxFit.cover,
        );
      case 'Logik-Labor':
        return Image.asset(
          'assets/images/icons/logic_magic.png',
          fit: BoxFit.cover,
        );
      case 'Zahlen-Zoo':
        return Image.asset(
          'assets/images/icons/math_magic.png',
          fit: BoxFit.cover,
        );
      default:
        return Text(
          widget.emoji,
          style: const TextStyle(fontSize: 40),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * (_pulseAnimation.value),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedBuilder(
                animation: _elevationAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: _elevationAnimation.value,
                          offset: Offset(0, _elevationAnimation.value * 0.5),
                        ),
                        if (_isHovered)
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: _elevationAnimation.value * 1.5,
                            offset: const Offset(0, 0),
                          ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Farbiger Hintergrund mit Hover-Effekt
                          Positioned.fill(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _isHovered
                                      ? [
                                          widget.color.withOpacity(0.8),
                                          widget.color.withOpacity(0.5),
                                        ]
                                      : [
                                          widget.color.withOpacity(0.7),
                                          widget.color.withOpacity(0.4),
                                        ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Magische Glitzer-Overlays
                          if (_isHovered)
                            ...List.generate(3, (index) {
                              return AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  final delay = index * 0.3;
                                  final animValue = (_pulseAnimation.value + delay) % 1.0;
                                  return Positioned(
                                    left: 20.0 + index * 60.0,
                                    top: 20.0 + 40.0 * animValue,
                                    child: Opacity(
                                      opacity: (1.0 - animValue) * 0.6,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppTheme.starYellow,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.starYellow.withOpacity(0.5),
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
                          
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Magisches Icon mit Hover-Animation
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: _isHovered ? 45 : 40,
                                  height: _isHovered ? 45 : 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                                        blurRadius: _isHovered ? 8 : 4,
                                        offset: Offset(0, _isHovered ? 4 : 2),
                                      ),
                                      if (_isHovered)
                                        BoxShadow(
                                          color: widget.color.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 0),
                                        ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _getIconForTitle(widget.title),
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                // Titel mit Hover-Effekt
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkGray,
                                        fontSize: _isHovered ? 13 : 12,
                                      ) ??
                                      const TextStyle(),
                                  child: Text(
                                    widget.title,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                
                                const SizedBox(height: 1),
                                
                                // Beschreibung
                                Text(
                                  widget.description,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.darkGray.withOpacity(0.8),
                                    fontSize: 9,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                const SizedBox(height: 4),
                                
                                // Kompakter Fortschritts-Bereich
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Fortschritt',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontSize: 8,
                                            color: AppTheme.darkGray,
                                          ),
                                        ),
                                        Text(
                                          '${(widget.progress * 100).toInt()}%',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.darkGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      height: _isHovered ? 6 : 4,
                                      child: LinearProgressIndicator(
                                        value: widget.progress,
                                        backgroundColor: AppTheme.lightGray,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          widget.progress > 0 ? AppTheme.magicGreen : AppTheme.lightGray,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    
                                    // Kompakte Sterne
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(3, (index) {
                                        final starThreshold = (index + 1) / 3;
                                        final isEarned = widget.progress >= starThreshold;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0.5),
                                          child: Icon(
                                            isEarned ? Icons.star : Icons.star_border,
                                            color: isEarned ? AppTheme.starYellow : AppTheme.lightGray,
                                            size: _isHovered ? 12 : 10,
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Tap-Effekt mit Animation
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onTap,
                                borderRadius: BorderRadius.circular(20),
                                splashColor: Colors.white.withOpacity(0.4),
                                highlightColor: Colors.white.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}