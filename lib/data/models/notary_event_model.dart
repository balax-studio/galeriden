import 'dart:math';
import '../../core/utils/anti_repetition_queue.dart';

enum NotaryEventType {
  smoothDeal,
  buyerEftLimit,
  buyerWalkaway,
  clerkBonus,
  lienResolved,
  expiredPowerOfAttorney,
  cashCounterCheck,
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

  static final AntiRepetitionQueue<int> _eventQueue = AntiRepetitionQueue<int>(capacity: 6);

  /// Evaluates random notary events with ~12% special occurrence chance and rich esnaf scenarios
  static NotaryEventResult evaluateNotaryEvent({
    required String buyerName,
    required String carTitle,
    required double price,
    required int dealershipReputation,
  }) {
    final random = Random();
    final roll = random.nextDouble();

    // 88% standard smooth deal (with varied natural descriptions)
    if (roll > 0.12) {
      final smoothDescriptions = [
        'Tescil belgesi ve ruhsat devir işlemleri noter başkatibi huzurunda eksiksiz imzalandı.',
        'Noter veznesinde harçlar yatırıldı, yeni plaka ve ruhsat belgesi alıcıya elden teslim edildi.',
        'Alıcı ve satıcı beyanları tasdik edildi • İki taraf da helalleşerek noteri tamamladı.',
        'Sıra beklemeden hızlı vezne işlemiyle devir başarıyla kayıtlara geçti.',
      ];
      final desc = smoothDescriptions[random.nextInt(smoothDescriptions.length)];

      return NotaryEventResult(
        type: NotaryEventType.smoothDeal,
        title: 'NOTER TASDİK EDİLDİ • DEVİR TAMAMLANDI',
        description: desc,
        bonusXp: 5,
        bonusReputation: 1,
      );
    }

    // 12% special esnaf event pool
    final candidateEvents = [0, 1, 2, 3, 4, 5];
    final selectedEvent = _eventQueue.selectNext(candidateEvents, randomInstance: random);

    switch (selectedEvent) {
      case 0:
        return NotaryEventResult(
          type: NotaryEventType.buyerEftLimit,
          title: 'ALICI EFT LİMİTİNE TAKILDI!',
          description: '$buyerName günlük mobil FAST/EFT limitini doldurdu. Kalan bakiye için ATM ve nakit desteğiyle satışı güçlükle tamamladı.',
          bonusXp: 10,
          bonusReputation: 0,
        );

      case 1:
        // Higher reputation reduces walkaway chance
        if (dealershipReputation >= 65 && random.nextBool()) {
          return const NotaryEventResult(
            type: NotaryEventType.smoothDeal,
            title: 'NOTER TASDİK EDİLDİ • GÜVENLİ DEVİR',
            description: 'Yüksek galeri itibarınız ve şeffaf tutumunuz sayesinde alıcı tereddüt etmeden imzayı attı.',
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
        return const NotaryEventResult(
          type: NotaryEventType.clerkBonus,
          title: 'BAŞKATİP HIZLI ONAYI • SERİ DEVİR',
          description: 'Noter başkatibi evrakları ve tescil kayıtlarını sıra beklemeden hızlıca onaylayıp ruhsatı teslim etti.',
          bonusXp: 15,
          bonusReputation: 2,
        );

      case 3:
        return NotaryEventResult(
          type: NotaryEventType.lienResolved,
          title: 'ESKİ REHİN ŞERHİ ANINDA KALDIRILDI',
          description: '$carTitle üzerinde kalan ufak banka rehin fek yazısı elektronik sistemden anında düşürüldü ve devir açıldı.',
          bonusXp: 12,
          bonusReputation: 1,
        );

      case 4:
        return NotaryEventResult(
          type: NotaryEventType.expiredPowerOfAttorney,
          title: 'VEKALETNAME TEYİT KONTROLÜ',
          description: '$buyerName şirket vekaletnamesiyle işlem yaptı. Noter katibi sicil gazetesini teyit ederek devri güvenle imzalattı.',
          bonusXp: 10,
          bonusReputation: 1,
        );

      case 5:
      default:
        return NotaryEventResult(
          type: NotaryEventType.cashCounterCheck,
          title: 'PARA SAYMA MAKİNESİ TASDİKİ',
          description: 'Nakit ödeme noter para sayma makinesinden kuruşu kuruşuna hatasız geçti ve imzalar atıldı.',
          bonusXp: 8,
          bonusReputation: 1,
        );
    }
  }
}
