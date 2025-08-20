import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lernbereiche'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.gardenRoute),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightPurple,
              AppTheme.lightBlue,
              AppTheme.lightPink,
            ],
          ),
        ),
        child: Padding(
          padding: AppStyles.pagePadding,
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildGameAreaCard(
                context,
                title: 'Lese-Abenteuer',
                icon: Icons.menu_book,
                color: AppTheme.primaryBlue,
                onTap: () {
                  // TODO: Navigate to reading games
                },
              ),
              _buildGameAreaCard(
                context,
                title: 'Schreib-Werkstatt',
                icon: Icons.edit,
                color: AppTheme.primaryPurple,
                onTap: () {
                  // TODO: Navigate to writing games
                },
              ),
              _buildGameAreaCard(
                context,
                title: 'Logik-Labor',
                icon: Icons.psychology,
                color: AppTheme.crystalBlue,
                onTap: () {
                  // TODO: Navigate to logic games
                },
              ),
              _buildGameAreaCard(
                context,
                title: 'Zahlen-Zoo',
                icon: Icons.calculate,
                color: AppTheme.magicGreen,
                onTap: () {
                  // TODO: Navigate to math games
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameAreaCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: AppStyles.cardRadius,
          boxShadow: AppStyles.cardShadow,
          border: Border.all(
            color: color,
            width: 3,
          ),
        ),
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
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return const Icon(
                  Icons.star_outline,
                  color: AppTheme.starYellow,
                  size: 20,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}