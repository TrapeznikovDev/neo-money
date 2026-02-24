import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/cloacka/features/home/bloc/progress_level_state.dart';

class ProgressLevelsCubit extends Cubit<ProgressLevelsState> {
  ProgressLevelsCubit({
    int totalLevels = 12,
    int purchasesPerLevel = 2,
  }) : super(
    ProgressLevelsState.initial(
      totalLevels: totalLevels,
      purchasesPerLevel: purchasesPerLevel,
    ),
  );

  void setPlannedPurchasesCount(int count) {
    final totalLevels = state.totalLevels;
    final purchasesPerLevel = state.purchasesPerLevel;

    final rawLevel = (count / purchasesPerLevel).floor() + 1;
    final currentLevel = rawLevel.clamp(1, totalLevels);

    final prevLevelPurchases = (currentLevel - 1) * purchasesPerLevel;

    final levelProgress = purchasesPerLevel == 0
        ? 0.0
        : ((count - prevLevelPurchases) / purchasesPerLevel).clamp(0.0, 1.0);

    final completedLevels = math.max(0, currentLevel - 1);

    final purchasesToNext = _purchasesToNextLevel(
      plannedPurchasesCount: count,
      purchasesPerLevel: purchasesPerLevel,
      totalLevels: totalLevels,
      currentLevel: currentLevel,
    );

    emit(
      state.copyWith(
        plannedPurchasesCount: count,
        currentLevel: currentLevel,
        completedLevels: completedLevels,
        levelProgress: levelProgress,
        purchasesToNext: purchasesToNext,
      ),
    );
  }

  static int _purchasesToNextLevel({
    required int plannedPurchasesCount,
    required int purchasesPerLevel,
    required int totalLevels,
    required int currentLevel,
  }) {
    if (currentLevel >= totalLevels) return 0;
    final nextLevelTarget = currentLevel * purchasesPerLevel;
    return math.max(0, nextLevelTarget - plannedPurchasesCount);
  }
}