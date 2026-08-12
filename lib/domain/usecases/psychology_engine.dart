import 'dart:math';

class PsychologyEngine {
  static final Random _random = Random();

  /// Simulated live viewer count for FOMO
  static int getLiveViewerCount() {
    return 2 + _random.nextInt(7);
  }

  /// Generate dynamic FOMO urgency text
  static String getRandomFomoText() {
    final texts = [
      '3 kişi teklif vermeye hazırlanıyor!',
      'Son 10 dakikadaki en popüler ilan',
      '5 farklı galerici bu aracı inceliyor',
      'Piyasa değerinin altında kaçırılmayacak fırsat!',
      'Bugün eklenen en kelepir araç',
    ];
    return texts[_random.nextInt(texts.length)];
  }

  /// Near-miss helper: Generates suspenseful negotiation waiting text
  static String getSuspenseNegotiationText() {
    final texts = [
      'Alıcı bütçesini zorluyor, cevap bekleniyor...',
      'Eşiyle istişare ediyor...',
      'Kredi onayını bekliyor, eli kulağında!',
      'Usta ekspertiz raporunu tekrar okuyor...',
    ];
    return texts[_random.nextInt(texts.length)];
  }

  /// Sunk cost alert text for repair screen
  static String getSunkCostRepairText(double spentSoFar, double estimatedGain) {
    return 'Şu ana kadar bu araca ₺${spentSoFar.round()} harcadın. Bir parça daha boyatsan satış fiyatı ₺${estimatedGain.round()} artacak!';
  }

  /// Calculate login streak reward
  static int getStreakReward(int streakDays) {
    if (streakDays <= 1) return 1000;
    if (streakDays <= 3) return 2500;
    if (streakDays <= 7) return 7500;
    if (streakDays <= 14) return 15000;
    return 30000;
  }
}
