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

  /// Transparent Net ROI text for repair actions
  static String getNetRoiRepairText(double cost, double valueDelta) {
    final netGain = valueDelta - cost;
    final costStr = '₺${cost.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    final deltaStr = '₺${valueDelta.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
    final netStr = '₺${netGain.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    return 'Bu onarım $costStr • Değer artışı +$deltaStr • Net kâr katkısı: +$netStr';
  }

  /// Legacy sunk cost alert text
  static String getSunkCostRepairText(double spentSoFar, double estimatedGain) {
    return 'Şu ana kadar bu araca ₺${spentSoFar.round()} harcadın. Bir parça daha boyatsan satış fiyatı ₺${estimatedGain.round()} artacak!';
  }

  /// Calculate login streak with calendar day comparison and freeze support
  static int calculateLoginStreak({
    required DateTime lastLoginDate,
    required int currentStreak,
    required DateTime now,
    bool hasStreakFreeze = false,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
    final calendarDiffDays = today.difference(lastDate).inDays;

    if (calendarDiffDays == 0) {
      // Same calendar day, streak remains unchanged
      return currentStreak > 0 ? currentStreak : 1;
    } else if (calendarDiffDays == 1) {
      // Next calendar day, increment streak!
      return currentStreak + 1;
    } else {
      // Missed one or more calendar days
      if (hasStreakFreeze) {
        return currentStreak > 0 ? currentStreak : 1;
      }
      return 1;
    }
  }

  /// Calculate progressive, uncapped login streak reward (D7 to D30+)
  static int getStreakReward(int streakDays) {
    if (streakDays <= 1) return 2500;
    if (streakDays <= 3) return 5000;
    if (streakDays <= 6) return 10000;
    if (streakDays == 7) return 25000; // D7 Milestone 1
    if (streakDays <= 13) return 35000;
    if (streakDays == 14) return 60000; // D14 Milestone 2
    if (streakDays <= 20) return 75000;
    if (streakDays == 21) return 100000; // D21 Milestone 3
    if (streakDays <= 29) return 125000;
    if (streakDays == 30) return 200000; // D30 Milestone 4
    // Uncapped linear/log progression after day 30
    return 200000 + ((streakDays - 30) * 10000);
  }

  /// Open loops summary for exit hook / idle dialog
  static Map<String, dynamic> getOpenLoopsSummary({
    required int pendingOrdersCount,
    required int showroomListedCarsCount,
    required int currentStreak,
  }) {
    final tomorrowStreak = currentStreak + 1;
    final tomorrowReward = getStreakReward(tomorrowStreak);
    final items = <String>[];
    if (pendingOrdersCount > 0) {
      items.add('$pendingOrdersCount parça siparişi yolda, kargolar ulaşıyor.');
    }
    if (showroomListedCarsCount > 0) {
      items.add('$showroomListedCarsCount vitrin aracı için potansiyel alıcılar sırada.');
    }
    items.add('Yarın giriş yaparsan $tomorrowStreak. Gün Serisi: ₺$tomorrowReward hazır.');

    return {
      'title': 'DÖNÜŞÜNÜ BEKLEYENLER',
      'items': items,
      'tomorrowReward': tomorrowReward,
      'tomorrowStreak': tomorrowStreak,
    };
  }

  /// Rich breakdown for "Yokluğunda Neler Oldu?" modal
  static Map<String, dynamic> getOfflineRecapSummary({
    required int offlineHours,
    required double earnedIncome,
    required int partsArrivedCount,
    required int newOffersCount,
    required int streakDays,
  }) {
    final bulletPoints = <String>[];
    if (earnedIncome > 0) {
      final incomeStr = '₺${earnedIncome.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
      bulletPoints.add('Yan işletmeler ve kiralamalardan $incomeStr pasif gelir toplandı.');
    }
    if (partsArrivedCount > 0) {
      bulletPoints.add('$partsArrivedCount adet yedek parça siparişin kargodan ulaştı.');
    }
    if (newOffersCount > 0) {
      bulletPoints.add('Vitlindeki araçlar için $newOffersCount yeni alıcı teklifi geldi.');
    }
    bulletPoints.add('$streakDays. gün giriş serin başarıyla korundu.');

    return {
      'title': 'YOKLUĞUNDA NELER OLDU?',
      'offlineHours': offlineHours,
      'earnedIncome': earnedIncome,
      'bulletPoints': bulletPoints,
    };
  }
}
