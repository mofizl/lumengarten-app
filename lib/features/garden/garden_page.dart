import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class GardenPage extends StatelessWidget {
  const GardenPage({super.key});

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
              // Garten-Status
              Container(
                width: double.infinity,
                padding: AppStyles.cardPadding,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: AppStyles.cardRadius,
                  boxShadow: AppStyles.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      'Dein magischer Garten erwacht langsam...',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(
                      value: 0.1,
                      backgroundColor: AppTheme.lightGray,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.starYellow,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Garten-Bereich (Platzhalter)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.3),
                    borderRadius: AppStyles.cardRadius,
                    border: Border.all(
                      color: AppTheme.moonSilver,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.eco,
                          size: 100,
                          color: AppTheme.darkGray.withOpacity(0.5),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Löse Aufgaben, um deinen\nGarten zum Leben zu erwecken!',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Spiel-Bereiche Button
              ElevatedButton.icon(
                onPressed: () {
                  context.go(AppConstants.gamesRoute);
                },
                icon: const Icon(Icons.games, size: 24),
                label: const Text('Zu den Aufgaben'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: AppTheme.white,
                  minimumSize: const Size(200, 60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}