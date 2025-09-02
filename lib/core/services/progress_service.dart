import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LearningArea {
  reading,
  writing,
  logic,
  math,
}

class ProgressData {
  final Map<LearningArea, double> areaProgress;
  final double overallProgress;
  final int gardenLevel;

  const ProgressData({
    required this.areaProgress,
    required this.overallProgress,
    required this.gardenLevel,
  });

  ProgressData copyWith({
    Map<LearningArea, double>? areaProgress,
    double? overallProgress,
    int? gardenLevel,
  }) {
    return ProgressData(
      areaProgress: areaProgress ?? this.areaProgress,
      overallProgress: overallProgress ?? this.overallProgress,
      gardenLevel: gardenLevel ?? this.gardenLevel,
    );
  }
}

class ProgressService extends StateNotifier<ProgressData> {
  ProgressService() : super(const ProgressData(
    areaProgress: {
      LearningArea.reading: 0.2,    // Demo-Werte
      LearningArea.writing: 0.1,
      LearningArea.logic: 0.0,
      LearningArea.math: 0.0,
    },
    overallProgress: 0.075, // (0.2 + 0.1 + 0.0 + 0.0) / 4
    gardenLevel: 0,
  ));

  void updateAreaProgress(LearningArea area, double progress) {
    final newAreaProgress = Map<LearningArea, double>.from(state.areaProgress);
    newAreaProgress[area] = progress.clamp(0.0, 1.0);
    
    final newOverallProgress = newAreaProgress.values.reduce((a, b) => a + b) / 4;
    final newGardenLevel = _calculateGardenLevel(newOverallProgress);
    
    state = state.copyWith(
      areaProgress: newAreaProgress,
      overallProgress: newOverallProgress,
      gardenLevel: newGardenLevel,
    );
  }

  int _calculateGardenLevel(double overallProgress) {
    if (overallProgress >= 1.0) return 4; // Vollständig erblüht
    if (overallProgress >= 0.75) return 3; // Kristalle leuchten
    if (overallProgress >= 0.5) return 2;  // Blumen blühen
    if (overallProgress >= 0.25) return 1; // Erste Knospen
    return 0; // Verwelkt
  }

  // Demo-Funktion zum Testen
  void simulateProgress() {
    updateAreaProgress(LearningArea.reading, 0.5);
    Future.delayed(const Duration(seconds: 2), () {
      updateAreaProgress(LearningArea.writing, 0.3);
    });
    Future.delayed(const Duration(seconds: 4), () {
      updateAreaProgress(LearningArea.logic, 0.6);
    });
    Future.delayed(const Duration(seconds: 6), () {
      updateAreaProgress(LearningArea.math, 0.8);
    });
  }
}

final progressProvider = StateNotifierProvider<ProgressService, ProgressData>((ref) {
  return ProgressService();
});