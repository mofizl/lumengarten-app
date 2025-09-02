import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/voice_service.dart';

class LogicGamesPage extends StatefulWidget {
  const LogicGamesPage({super.key});

  @override
  State<LogicGamesPage> createState() => _LogicGamesPageState();
}

class _LogicGamesPageState extends State<LogicGamesPage> {
  final VoiceService _voiceService = VoiceService();

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    _voiceService.speak('Logik-Labor! Wähle ein cleveres Rätselspiel!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.crystalBlue,
              AppTheme.lightPurple,
              AppTheme.primaryBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Logik-Labor',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Clevere Rätsel für clevere Köpfe!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
                      // Game Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildGameCard(
                              context,
                              title: 'Farben Merken',
                              description: 'Merke dir die Reihenfolge der Farben!',
                              icon: Icons.palette,
                              color: AppTheme.primaryPurple,
                              onTap: () => context.go('/games/logic/pattern'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildGameCard(
                              context,
                              title: 'Dunkis Labyrinth',
                              description: 'Hilf Dunki durch das magische Labyrinth!',
                              icon: Icons.account_tree,
                              color: AppTheme.magicGreen,
                              onTap: () => context.go('/games/logic/labyrinth'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
            onPressed: () => context.go('/games'),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _voiceService.speak(title);
        onTap();
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}