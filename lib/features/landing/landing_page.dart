import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightBlue,
              AppTheme.lightPurple,
              AppTheme.lightPink,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppStyles.pagePadding,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // App-Titel
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                // Platzhalter für Lumengarten-Bild
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.moonSilver,
                    borderRadius: AppStyles.cardRadius,
                    boxShadow: AppStyles.cardShadow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.landscape,
                      size: 80,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Geschichte-Text
                Container(
                  padding: AppStyles.cardPadding,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: AppStyles.cardRadius,
                    boxShadow: AppStyles.cardShadow,
                  ),
                  child: Text(
                    'Im magischen Lumengarten ist etwas Schreckliches passiert! '
                    'Alle Lichtblumen sind verwelkt und die Kristallbäume haben ihren Glanz verloren. '
                    '\n\nNur DU kannst dem kleinen Gartendrachen helfen, das Licht zurückzubringen! '
                    'Mit jedem Rätsel das du löst, erblüht eine neue Lichtpflanze.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Hilfst du mir Button
                ElevatedButton.icon(
                  onPressed: () {
                    context.go(AppConstants.gardenRoute);
                  },
                  icon: const Icon(Icons.pets, size: 28),
                  label: Text(
                    'Hilfst du mir?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: AppTheme.white,
                    minimumSize: const Size(200, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}