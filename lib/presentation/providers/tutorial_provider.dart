import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TutorialStep {
  inspectCar, // 0: Dede mirası arabayı incele
  openDamageList, // 1: Hasar ve arıza listesini aç
  checkPart, // 2: Parça durumunu ve tamir maliyetini öğren
  tryRepair, // 3: Tamir/sipariş kararını ver (Geçici / Usta / Yeni)
  orderPart, // 4: Parça siparişini ver
  waitDelivery, // 5: Sipariş teslimatını bekle
  installPart, // 6: Teslim alınan parçayı araca monte et
  startEngine, // 7: Motor ve araç durumunu kontrol et
  seeValueIncrease, // 8: Değer artışını gör
  listForSale, // 9: Arabayı ilana koy ve fiyat ayarla
  completeSale, // 10: İlk müşteri teklifini kabul edip satışı tamamla
  finished, // 11: Rehber tamamlandı!
}

class TutorialState {
  final TutorialStep step;
  final bool isActive;

  TutorialState({
    required this.step,
    required this.isActive,
  });
}

final tutorialProvider = StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  return TutorialNotifier();
});

class TutorialNotifier extends StateNotifier<TutorialState> {
  TutorialNotifier()
      : super(TutorialState(
          step: TutorialStep.inspectCar,
          isActive: true,
        ));

  void nextStep() {
    final nextIndex = state.step.index + 1;
    if (nextIndex < TutorialStep.values.length) {
      state = TutorialState(
        step: TutorialStep.values[nextIndex],
        isActive: nextIndex < TutorialStep.finished.index,
      );
    }
  }

  void setStep(TutorialStep newStep) {
    state = TutorialState(
      step: newStep,
      isActive: newStep != TutorialStep.finished,
    );
  }

  void skipTutorial() {
    state = TutorialState(
      step: TutorialStep.finished,
      isActive: false,
    );
  }
}
