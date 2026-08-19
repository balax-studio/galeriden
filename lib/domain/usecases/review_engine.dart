import 'dart:math';
import '../../core/utils/anti_repetition_queue.dart';
import '../../core/utils/slot_text_composer.dart';
import '../../data/models/car_model.dart';
import '../../data/models/customer_review_model.dart';

/// Result data structure holding generated review and reputation impact
class CustomerReviewResult {
  final CustomerReviewModel review;
  final int reputationChange;

  const CustomerReviewResult({
    required this.review,
    required this.reputationChange,
  });
}

/// Pure domain usecase for generating rich, context-aware customer reviews with anti-slop slots
class ReviewEngine {
  static final Random _defaultRng = Random();
  static final AntiRepetitionQueue<String> _reviewQueue = AntiRepetitionQueue<String>(capacity: 25);

  static final List<String> _honestFlawlessSlot1 = [
    'Aracı pırıl pırıl teslim aldım.',
    'Tam ilanında anlatıldığı gibi diri ve masrafsız.',
    'Noter ve teslimat süreci çok hızlı ve şeffaf ilerledi.',
    'Koltuklarından kaportasına kadar tertemiz bir araç.',
    'Dürüst ve samimi esnaflık örneği.',
    'Aracın kondisyonu beklediğimden bile daha diri çıktı.',
    'Ekspertiz raporuyla beyanlar birebir uyuştu.',
    'Sanayideki ustama da gösterdim, nokta kusursuz dedi.',
  ];

  static final List<String> _honestFlawlessSlot2 = [
    'Motor sesi saat gibi, yürüyen aksam lokum gibi çalışıyor.',
    'İç kozmetiğinde ve butonlarında en ufak yıpranma yok.',
    'Şanzıman geçişleri kusursuz, tek kuruş masraf istemiyor.',
    'Yedek anahtarı ve tüm belgeleri eksiksiz teslim edildi.',
    'Satış öncesi ve sonrası esnaf ilgisi takdire şayan.',
  ];

  static final List<String> _honestFlawlessSlot3 = [
    'Gönül rahatlığıyla tavsiye ederim • Helal olsun.',
    'Hayırlı bereketli kazançlar dilerim.',
    'Gözünüz kapalı güvenebilirsiniz • Teşekkürler.',
    'Gerçek esnaflık budur • Dosta tavsiye edilir.',
  ];

  static final List<String> _honestVipReviews = [
    'VIP karşılama ve ikramlar harikaydı • Dürüst esnaf, son derece keyifli bir alışveriş oldu.',
    'Lounge alanında kahvemizi içerken noter evrakları hazırlandı • Kurumsal ve şeffaf hizmet!',
    'Örnek bir otomotiv işletmesi • Hem dürüstler hem de müşteriye çok kıymet veriyorlar.',
    'Prestijli galeri ortamı ve sıfır sürprizle tamamlanan devir • Herkese tavsiye ediyorum.',
    'Müşteri memnuniyetini ön planda tutan nezih bir galeri • Çok memnun kaldık.',
  ];

  static final List<String> _honestFairReviews = [
    'Ufak tefek bakım masraflarını baştan dürüstçe belirttiler • Teşekkürler.',
    'Yaşına göre normal yıpranmaları vardı, satıcı hepsini şeffaf şekilde izah etti.',
    'Fiyatta esneklik sağladılar ve eksikleri gizlemediler • Güvenilir esnaf.',
    'Pazarlıkta yardımcı oldular, şeffaf ekspertiz tutumu için teşekkür ederim.',
    'Dürüst yaklaşım sergilediler • Masraflarını bilerek aldım, memnun kaldım.',
    'Araç söylediği gibi çıktı • Ufak bakım masraflarını fiyattan düştüler.',
    'Sözünün eri esnaf • Eksikleri baştan duymak içimizi rahatlattı.',
  ];

  static final List<String> _dishonestReviews = [
    'İlanda yazmayan boya ve mekanik kusurlar çıktı • Pek memnun kalmadım.',
    'Ekspertizde sürpriz masraflar tespit edildi • İlan detayları maalesef gerçeği yansıtmıyordu.',
    'Aracın motorundan garip sesler geliyor, ilanda hatasız yazılmıştı • Hayal kırıklığı oldu.',
    'Noterden sonra sanayiye çekmek zorunda kaldım • Şeffaf esnaflık göremedim.',
    'Gizlenen kusurlar canımı sıktı • Bir daha bu galeriden araç almayı düşünmüyorum.',
    'Boya ve tramer ilandakinden farklı çıktı • Ticaret ahlakına uygun bir deneyim olmadı.',
    'İlanda kusursuz yazılan araçta gizli yağ kaçağı ve şanzıman vuruntusu çıktı.',
    'Ekspertiz yaptırmasaydık ağır masrafa girecektik • Hiç şeffaf davranılmadı.',
  ];

  /// Generates a dynamic customer review based on car condition, honesty, and dealer prestige
  static CustomerReviewResult generateSaleReview({
    required CarModel car,
    required String buyerName,
    bool hasVipConcierge = false,
    bool hasVipLounge = false,
    bool hasTrophy = false,
    Random? random,
  }) {
    final rng = random ?? _defaultRng;
    final isClean = car.isWashed || car.isDetailedCleaned;
    final isGoodEngine = car.expertise.engineCondition >= 80 && car.expertise.transmissionCondition >= 75;
    final isLowTramer = car.expertise.tramerAmount <= 15000;

    double reviewRating = 4.5;
    String reviewComment = '';
    int reputationChange = 3;

    if (car.declarationType == ListingDeclarationType.honest) {
      if (isClean && isGoodEngine && isLowTramer) {
        reviewRating = 5.0;
        if ((hasVipConcierge || hasVipLounge) && rng.nextBool()) {
          reviewComment = _reviewQueue.selectNext(_honestVipReviews, randomInstance: rng);
        } else {
          final composed = SlotTextComposer.compose3(
            slot1: _honestFlawlessSlot1,
            slot2: _honestFlawlessSlot2,
            slot3: _honestFlawlessSlot3,
            randomInstance: rng,
          );
          _reviewQueue.push(composed);
          reviewComment = composed;
        }
        reputationChange = 5 + (hasVipConcierge || hasVipLounge ? 2 : 0) + (hasTrophy ? 1 : 0);
      } else if (isGoodEngine) {
        reviewRating = (hasVipConcierge || hasVipLounge) ? 4.5 : 4.0;
        if (hasVipConcierge || hasVipLounge) {
          reviewComment = _reviewQueue.selectNext(_honestVipReviews, randomInstance: rng);
        } else {
          final composed = SlotTextComposer.compose3(
            slot1: _honestFlawlessSlot1,
            slot2: _honestFlawlessSlot2,
            slot3: _honestFlawlessSlot3,
            randomInstance: rng,
          );
          _reviewQueue.push(composed);
          reviewComment = composed;
        }
        reputationChange = 3 + (hasVipConcierge ? 1 : 0) + (hasTrophy ? 1 : 0);
      } else {
        reviewRating = (hasVipConcierge || hasVipLounge) ? 4.0 : 3.5;
        reviewComment = _reviewQueue.selectNext(_honestFairReviews, randomInstance: rng);
        reputationChange = 2 + (hasVipConcierge ? 1 : 0) + (hasTrophy ? 1 : 0);
      }
    } else {
      // Dishonest declaration
      reviewRating = (hasVipConcierge || hasVipLounge) ? 2.5 : 2.0;
      reviewComment = _reviewQueue.selectNext(_dishonestReviews, randomInstance: rng);
      reputationChange = -4;
    }

    final review = CustomerReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}_${rng.nextInt(9999)}',
      reviewerName: buyerName,
      carTitle: '${car.modelYear} ${car.brand} ${car.modelName}',
      rating: reviewRating,
      comment: reviewComment,
      createdAt: DateTime.now(),
    );

    return CustomerReviewResult(
      review: review,
      reputationChange: reputationChange,
    );
  }
}
