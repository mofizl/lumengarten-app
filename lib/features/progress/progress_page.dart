import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fortschritt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.gardenRoute),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightBlue,
              AppTheme.lightPurple,
            ],
          ),
        ),
        child: Padding(
          padding: AppStyles.pagePadding,
          child: Column(
            children: [
              // Gesamt-Fortschritt
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
                      'Deine Erfolge',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          context,
                          icon: Icons.star,
                          value: '12',
                          label: 'Sterne',
                          color: AppTheme.starYellow,
                        ),
                        _buildStatCard(
                          context,
                          icon: Icons.eco,
                          value: '3',
                          label: 'Pflanzen',
                          color: AppTheme.magicGreen,
                        ),
                        _buildStatCard(
                          context,
                          icon: Icons.pets,
                          value: '1',
                          label: 'Tiere',
                          color: AppTheme.primaryPurple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Lernbereich-Fortschritt
              Expanded(
                child: ListView(
                  children: [
                    _buildProgressCard(
                      context,
                      title: 'Lese-Abenteuer',
                      progress: 0.3,
                      color: AppTheme.primaryBlue,
                      tasksCompleted: 6,
                      totalTasks: 20,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCard(
                      context,
                      title: 'Schreib-Werkstatt',
                      progress: 0.1,
                      color: AppTheme.primaryPurple,
                      tasksCompleted: 2,
                      totalTasks: 20,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCard(
                      context,
                      title: 'Logik-Labor',
                      progress: 0.2,
                      color: AppTheme.crystalBlue,
                      tasksCompleted: 4,
                      totalTasks: 20,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCard(
                      context,
                      title: 'Zahlen-Zoo',
                      progress: 0.0,
                      color: AppTheme.magicGreen,
                      tasksCompleted: 0,
                      totalTasks: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required String title,
    required double progress,
    required Color color,
    required int tasksCompleted,
    required int totalTasks,
  }) {
    return Container(
      padding: AppStyles.cardPadding,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: AppStyles.cardRadius,
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.lightGray,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$tasksCompleted von $totalTasks Aufgaben geschafft',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}