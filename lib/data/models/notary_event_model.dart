import 'dart:math';

enum NotaryEventType {
  smoothDeal,
  buyerEftLimit,
  buyerWalkaway,
  clerkBonus,
}

class NotaryEventResult {
  final NotaryEventType type;
  final String title;
  final String description;
  final bool isCancelled;
  final int bonusXp;
  final int bonusReputation;
  final double extraFee;

  const NotaryEventResult({
    required this.type,
    required this.title,
    required this.description,
    this.isCancelled = false,
    this.bonusXp = 0,
    this.bonusReputation = 0,
    this.extraFee = 0.0,
  });

  /// Evaluates random notary events with ~8% special occurrence chance
  static NotaryEventResult evaluateNotaryEvent({
    required String buyerName,
    required String carTitle,
    required double price,
    required int dealershipReputation,
  }) {
    final random = Random();
    final roll = random.nextDouble();

    // 92% standard smooth deal
    if (roll > 0.10) {
      return const NotaryEventResult(
        type: NotaryEventType.smoothDeal,
        title: 'NOTER TASDİK EDİLDİ • DEVİR TAMAMLANDI',
        description: 'Tescil belgesi ve ruhsat devir işlemleri noter başkatibi huzurunda eksiksiz imzalandı.',
        bonusXp: 5,
        bonusReputation: 1,
      );
    }

    // 10% special esnaf event pool
    final eventRoll = random.nextInt(3);
    switch (eventRoll) {
      case 0:
        return NotaryEventResult(
          type: NotaryEventType.buyerEftLimit,
          title: 'ALICI EFT LİMİTİNE TAKILDI!',
          description: '$buyerName günlük mobil bankacılık FAST/EFT limitini doldurdu. Kalan tutar için FAST + elden nakit tamamlayarak satışı güçlükle bitirdi.',
          bonusXp: 10,
          bonusReputation: 0,
        );
      case 1:
        // Higher reputation reduces walkaway chance
        if (dealershipReputation >= 65 && random.nextBool()) {
          return const NotaryEventResult(
            type: NotaryEventType.smoothDeal,
            title: 'NOTER TASDİK EDİLDİ • GÜVENLİ DEVİR',
            description: 'Yüksek galeri itibarınız sayesinde alıcı tereddüt etmeden imzayı attı.',
            bonusXp: 8,
            bonusReputation: 2,
          );
        }
        return NotaryEventResult(
          type: NotaryEventType.buyerWalkaway,
          title: 'ALICI NOTERDE CAYDI • İŞLEM İPTAL',
          description: '$buyerName noter veznesi önünde son anda vazgeçtiğini söyleyerek masadan kalktı. Araç galeri vitrinine geri döndü.',
          isCancelled: true,
          bonusXp: 0,
          bonusReputation: 0,
        );
      case 2:
      default:
        return const NotaryEventResult(
          type: NotaryEventType.clerkBonus,
          title: 'BAŞKATİP HIZLI ONAYI • SERİ DEVİR',
          description: 'Noter başkatibi evrakları sıra beklemeden hızlıca onayladı ve ruhsatı teslim etti.',
          bonusXp: 15,
          bonusReputation: 2,
        );
    }
  }
}
