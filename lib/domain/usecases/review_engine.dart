import 'dart:math';
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

/// Pure domain usecase for generating rich, context-aware customer reviews
class ReviewEngine {
  static final Random _defaultRng = Random();

  static final List<String> _honestFlawlessReviews = [
    'Aracı pırıl pırıl teslim aldım. Ekspertizde tek bir sürpriz çıkmadı, esnaflık budur!',
    'Tam ilanında anlatıldığı gibi diri ve masrafsız. Motor sesi saat gibi, hayırlı işler.',
    'Noter ve teslimat süreci çok hızlı ve şeffaf ilerledi. Gönül rahatlığıyla tavsiye ederim.',
    'Koltuklarından kaportasına kadar tertemiz araç. İlgi ve alaka için çok teşekkürler.',
    'Dürüst ve samimi ticaret. Söylediklerinin haricinde tek bir kusur çıkmadı.',
    'Aracın kondisyonu beklediğimden bile iyi çıktı. Harika bir galeri esnafı.',
    'Ekspertiz raporuyla birebir uyuştu. Tertemiz teslim ettiler, helal olsun.',
    'Sanayideki ustama da gösterdim, nokta hatasız dedi. Gözünüz kapalı güvenebilirsiniz.',
    'Satış öncesi ve sonrası iletişim kusursuzdu. Çok memnun kaldım.',
  ];

  static final List<String> _honestVipReviews = [
    'VIP karşılama ve samimi ikramları harikaydı. Dürüst esnaf, keyifli bir alışveriş oldu.',
    'Lounge alanında kahvemizi içerken noter evrakları hazırlandı. Kurumsal ve şeffaf hizmet!',
    'Örnek bir otomotiv işletmesi. Hem dürüstler hem de müşteriye çok kıymet veriyorlar.',
    'Prestijli galeri ortamı ve sıfır sürprizle tamamlanan devir. Herkese tavsiye ediyorum.',
  ];

  static final List<String> _honestFairReviews = [
    'Ufak tefek masraflarını baştan dürüstçe belirttiler. Teşekkürler.',
    'Yaşına göre normal yıpranmaları vardı, satıcı hepsini şeffaf şekilde izah etti.',
    'Fiyatta esneklik sağladılar ve eksikleri gizlemediler. Güvenilir esnaf.',
    'Pazarlıkta yardımcı oldular, şeffaf ekspertiz tutumu için teşekkür ederim.',
    'Dürüst yaklaşım sergilediler. Masraflarını bilerek aldım, memnun kaldım.',
    'Araç söylediği gibi çıktı. Ufak bakım ihtiyaçlarını fiyattan düştüler.',
    'Sözünün eri esnaf. Eksikleri baştan duymak içimizi rahatlattı.',
  ];

  static final List<String> _dishonestReviews = [
    'İlanda yazmayan boya ve mekanik kusurlar çıktı. Pek memnun kalmadım.',
    'Ekspertizde sürpriz masraflar tespit edildi. İlan detayları maalesef gerçeği yansıtmıyordu.',
    'Aracın motorundan garip sesler geliyor, ilanda hatasız yazılmıştı. Hayal kırıklığı oldu.',
    'Noterden sonra sanayiye çekmek zorunda kaldım. Şeffaf esnaflık göremedim.',
    'Gizlenen kusurlar canımı sıktı. Bir daha bu galeriden araç almayı düşünmüyorum.',
    'Boya ve tramer ilandakinden farklı çıktı. Ticaret ahlakına uygun bir deneyim olmadı.',
    'İlanda kusursuz yazılan araçta gizli yağ kaçağı ve şanzıman vuruntusu çıktı.',
    'Ekspertiz yaptırmasaydık ağır masrafa girecektik. Hiç şeffaf davranılmadı.',
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
          reviewComment = _honestVipReviews[rng.nextInt(_honestVipReviews.length)];
        } else {
          reviewComment = _honestFlawlessReviews[rng.nextInt(_honestFlawlessReviews.length)];
        }
        reputationChange = 5 + (hasVipConcierge || hasVipLounge ? 2 : 0) + (hasTrophy ? 1 : 0);
      } else if (isGoodEngine) {
        reviewRating = (hasVipConcierge || hasVipLounge) ? 4.5 : 4.0;
        if (hasVipConcierge || hasVipLounge) {
          reviewComment = _honestVipReviews[rng.nextInt(_honestVipReviews.length)];
        } else {
          reviewComment = _honestFlawlessReviews[rng.nextInt(_honestFlawlessReviews.length)];
        }
        reputationChange = 3 + (hasVipConcierge ? 1 : 0) + (hasTrophy ? 1 : 0);
      } else {
        reviewRating = (hasVipConcierge || hasVipLounge) ? 4.0 : 3.5;
        reviewComment = _honestFairReviews[rng.nextInt(_honestFairReviews.length)];
        reputationChange = 2 + (hasVipConcierge ? 1 : 0) + (hasTrophy ? 1 : 0);
      }
    } else {
      // Dishonest declaration
      reviewRating = (hasVipConcierge || hasVipLounge) ? 2.5 : 2.0;
      reviewComment = _dishonestReviews[rng.nextInt(_dishonestReviews.length)];
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
