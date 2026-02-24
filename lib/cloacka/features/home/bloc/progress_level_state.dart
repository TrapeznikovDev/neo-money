import 'package:equatable/equatable.dart';

class ProgressLevelsState extends Equatable {
  final int plannedPurchasesCount;

  final int totalLevels;
  final int purchasesPerLevel;

  final int currentLevel;
  final int completedLevels;
  final double levelProgress;
  final int purchasesToNext;

  const ProgressLevelsState({
    required this.plannedPurchasesCount,
    required this.totalLevels,
    required this.purchasesPerLevel,
    required this.currentLevel,
    required this.completedLevels,
    required this.levelProgress,
    required this.purchasesToNext,
  });

  factory ProgressLevelsState.initial({int plannedPurchasesCount = 0, int totalLevels = 12, int purchasesPerLevel = 2}) {
    return ProgressLevelsState(
      plannedPurchasesCount: plannedPurchasesCount,
      totalLevels: totalLevels,
      purchasesPerLevel: purchasesPerLevel,
      currentLevel: 1,
      completedLevels: 0,
      levelProgress: 0,
      purchasesToNext: purchasesPerLevel,
    );
  }

  ProgressLevelsState copyWith({
    int? plannedPurchasesCount,
    int? totalLevels,
    int? purchasesPerLevel,
    int? currentLevel,
    int? completedLevels,
    double? levelProgress,
    int? purchasesToNext,
  }) {
    return ProgressLevelsState(
      plannedPurchasesCount: plannedPurchasesCount ?? this.plannedPurchasesCount,
      totalLevels: totalLevels ?? this.totalLevels,
      purchasesPerLevel: purchasesPerLevel ?? this.purchasesPerLevel,
      currentLevel: currentLevel ?? this.currentLevel,
      completedLevels: completedLevels ?? this.completedLevels,
      levelProgress: levelProgress ?? this.levelProgress,
      purchasesToNext: purchasesToNext ?? this.purchasesToNext,
    );
  }

  @override
  List<Object?> get props => [plannedPurchasesCount, totalLevels, purchasesPerLevel, currentLevel, completedLevels, levelProgress, purchasesToNext];
}
