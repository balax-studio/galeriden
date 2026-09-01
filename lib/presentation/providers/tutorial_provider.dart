import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TutorialStep {
  inspectHeritageCar, // 0: Dede mirası arabayı incele
  repairEnginePart, // 1: Hasarlı parçayı onar
  listCarForSale, // 2: Arabayı ilana koy
  acceptFirstOffer, // 3: İlk müşteri teklifini kabul et
  completed, // 4: Rehber tamamlandı
}

class TutorialState {
  final TutorialStep step;
  final bool isActive;

  const TutorialState({
    required this.step,
    required this.isActive,
  });

  bool get isCompleted => step == TutorialStep.completed;

  TutorialState copyWith({
    TutorialStep? step,
    bool? isActive,
  }) {
    return TutorialState(
      step: step ?? this.step,
      isActive: isActive ?? this.isActive,
    );
  }
}

final tutorialProvider =
    StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  return TutorialNotifier();
});

class TutorialNotifier extends StateNotifier<TutorialState> {
  TutorialNotifier()
      : super(const TutorialState(
          step: TutorialStep.inspectHeritageCar,
          isActive: true,
        ));

  void nextStep() {
    final nextIndex = state.step.index + 1;
    if (nextIndex < TutorialStep.values.length) {
      state = TutorialState(
        step: TutorialStep.values[nextIndex],
        isActive: nextIndex < TutorialStep.completed.index,
      );
    }
  }

  void setStep(TutorialStep newStep) {
    state = TutorialState(
      step: newStep,
      isActive: newStep != TutorialStep.completed,
    );
  }

  void completeTutorial() {
    state = const TutorialState(
      step: TutorialStep.completed,
      isActive: false,
    );
  }

  void skipTutorial() {
    state = const TutorialState(
      step: TutorialStep.completed,
      isActive: false,
    );
  }
}
