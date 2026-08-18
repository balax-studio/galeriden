import 'package:flutter/material.dart';
import '../../core/utils/iterable_extensions.dart';

enum DramaticCategory {
  loss, // Kategori A: Kayıp & Para
  betrayal, // Kategori B: İhanet & Çalınma
  conscience, // Kategori C: Vicdan & İtibar
  legacy, // Kategori D: Miras & Bağlılık
  gamble, // Kategori E: Kumar & Adrenalin
}

enum DramaticSeverity {
  low,
  medium,
  high,
  extreme,
}

class DramaticOutcomeModel {
  final double probability; // 0.0 to 1.0
  final String title;
  final String message;
  final bool isSuccess;
  final double moneyDelta;
  final int reputationDelta;
  final int xpReward;
  final bool loseTargetCar;
  final double? recoverCarValueMultiplier;
  final bool makeFamilyHeirloom;
  final bool spawnBargainCar;
  final double? staffSalaryMultiplier;

  const DramaticOutcomeModel({
    required this.probability,
    required this.title,
    required this.message,
    this.isSuccess = true,
    this.moneyDelta = 0.0,
    this.reputationDelta = 0,
    this.xpReward = 20,
    this.loseTargetCar = false,
    this.recoverCarValueMultiplier,
    this.makeFamilyHeirloom = false,
    this.spawnBargainCar = false,
    this.staffSalaryMultiplier,
  });

  Map<String, dynamic> toJson() => {
        'probability': probability,
        'title': title,
        'message': message,
        'isSuccess': isSuccess,
        'moneyDelta': moneyDelta,
        'reputationDelta': reputationDelta,
        'xpReward': xpReward,
        'loseTargetCar': loseTargetCar,
        'recoverCarValueMultiplier': recoverCarValueMultiplier,
        'makeFamilyHeirloom': makeFamilyHeirloom,
        'spawnBargainCar': spawnBargainCar,
        'staffSalaryMultiplier': staffSalaryMultiplier,
      };

  factory DramaticOutcomeModel.fromJson(Map<String, dynamic> json) => DramaticOutcomeModel(
        probability: (json['probability'] as num?)?.toDouble() ?? 1.0,
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        isSuccess: json['isSuccess'] as bool? ?? true,
        moneyDelta: (json['moneyDelta'] as num?)?.toDouble() ?? 0.0,
        reputationDelta: json['reputationDelta'] as int? ?? 0,
        xpReward: json['xpReward'] as int? ?? 20,
        loseTargetCar: json['loseTargetCar'] as bool? ?? false,
        recoverCarValueMultiplier: (json['recoverCarValueMultiplier'] as num?)?.toDouble(),
        makeFamilyHeirloom: json['makeFamilyHeirloom'] as bool? ?? false,
        spawnBargainCar: json['spawnBargainCar'] as bool? ?? false,
        staffSalaryMultiplier: (json['staffSalaryMultiplier'] as num?)?.toDouble(),
      );
}

class DramaticChoiceModel {
  final String id;
  final String label;
  final String shortDescription;
  final double upfrontCost;
  final List<DramaticOutcomeModel> outcomes;

  const DramaticChoiceModel({
    required this.id,
    required this.label,
    required this.shortDescription,
    this.upfrontCost = 0.0,
    required this.outcomes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'shortDescription': shortDescription,
        'upfrontCost': upfrontCost,
        'outcomes': outcomes.map((o) => o.toJson()).toList(),
      };

  factory DramaticChoiceModel.fromJson(Map<String, dynamic> json) => DramaticChoiceModel(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        shortDescription: json['shortDescription'] as String? ?? '',
        upfrontCost: (json['upfrontCost'] as num?)?.toDouble() ?? 0.0,
        outcomes: (json['outcomes'] as List<dynamic>?)
                ?.map((e) => DramaticOutcomeModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const [],
      );
}

class DramaticCardModel {
  final String id;
  final DramaticCategory category;
  final DramaticSeverity severity;
  final String title;
  final String characterName;
  final String characterRole;
  final String characterAvatar;
  final IconData icon;
  final String dialogue;
  final String foreshadowHint;
  final int minPlayerLevel;
  final bool requiresCarInGarage;
  final bool requiresBlackMarketHistory;
  final bool requiresHeirloomCar;
  final bool isNarrativeOnly;
  final List<DramaticChoiceModel> choices;

  const DramaticCardModel({
    required this.id,
    required this.category,
    required this.severity,
    required this.title,
    required this.characterName,
    required this.characterRole,
    required this.characterAvatar,
    required this.icon,
    required this.dialogue,
    required this.foreshadowHint,
    this.minPlayerLevel = 1,
    this.requiresCarInGarage = false,
    this.requiresBlackMarketHistory = false,
    this.requiresHeirloomCar = false,
    this.isNarrativeOnly = false,
    required this.choices,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'severity': severity.name,
        'title': title,
        'characterName': characterName,
        'characterRole': characterRole,
        'characterAvatar': characterAvatar,
        'dialogue': dialogue,
        'foreshadowHint': foreshadowHint,
        'minPlayerLevel': minPlayerLevel,
        'requiresCarInGarage': requiresCarInGarage,
        'requiresBlackMarketHistory': requiresBlackMarketHistory,
        'requiresHeirloomCar': requiresHeirloomCar,
        'isNarrativeOnly': isNarrativeOnly,
        'choices': choices.map((c) => c.toJson()).toList(),
      };

  factory DramaticCardModel.fromJson(Map<String, dynamic> json) {
    final cardId = json['id'] as String? ?? '';
    final defaultMatch = findFirstWhere(defaultCards, (c) => c.id == cardId);
    if (defaultMatch != null) return defaultMatch;

    return DramaticCardModel(
      id: cardId,
      category: DramaticCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => DramaticCategory.loss,
      ),
      severity: DramaticSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => DramaticSeverity.medium,
      ),
      title: json['title'] as String? ?? 'Dramatik Karar',
      characterName: json['characterName'] as String? ?? 'Misafir',
      characterRole: json['characterRole'] as String? ?? 'Ziyaretçi',
      characterAvatar: json['characterAvatar'] as String? ?? 'user',
      icon: Icons.psychology_alt_rounded,
      dialogue: json['dialogue'] as String? ?? '',
      foreshadowHint: json['foreshadowHint'] as String? ?? '',
      minPlayerLevel: json['minPlayerLevel'] as int? ?? 1,
      requiresCarInGarage: json['requiresCarInGarage'] as bool? ?? false,
      requiresBlackMarketHistory: json['requiresBlackMarketHistory'] as bool? ?? false,
      requiresHeirloomCar: json['requiresHeirloomCar'] as bool? ?? false,
      isNarrativeOnly: json['isNarrativeOnly'] as bool? ?? false,
      choices: (json['choices'] as List<dynamic>?)
              ?.map((e) => DramaticChoiceModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );
  }

  static const List<DramaticCardModel> defaultCards = [
    // -------------------------------------------------------------
    // KATEGORİ A: KAYIP KARTLARI (Para & Risk)
    // -------------------------------------------------------------
    DramaticCardModel(
      id: 'A1',
      category: DramaticCategory.loss,
      severity: DramaticSeverity.medium,
      title: 'Acil Nakit İhtiyacı',
      characterName: 'Eski Ortak Necati',
      characterRole: 'Eski İş Ortağı',
      characterAvatar: 'rose',
      icon: Icons.handshake_rounded,
      dialogue:
          '"Usta... biliyorum aramız iyi değildi ama başım dertte. Kızımın acil ameliyatı var, elimde avucumda hiçbir şey kalmadı. ₺40.000 borç versen, 1 ay içinde ₺80.000 olarak öderim, namus sözü."',
      foreshadowHint: 'Gözleri çukura kaçmış, elleri titriyor. Çaresiz mi yoksa yine kumara mı bulaştı bilinmez.',
      choices: [
        DramaticChoiceModel(
          id: 'A1_give',
          label: '₺40.000 Borç Ver',
          shortDescription: '%55 ihtimalle ₺80.000 döner • +5 İtibar, %45 parayı alıp kaybolur.',
          upfrontCost: 40000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.55,
              title: 'Necati Sözünü Tuttu!',
              message:
                  'Necati bir ay sonra yüzünde minnetle kapına geldi. Borcunu ikiye katlayarak ₺80.000 ödedi! Sanayide cömertliğin dilden dile konuşuluyor.',
              isSuccess: true,
              moneyDelta: 80000.0,
              reputationDelta: 5,
              xpReward: 100,
            ),
            DramaticOutcomeModel(
              probability: 0.45,
              title: 'Necati Sırra Kadem Bastı...',
              message:
                  'Haftalar geçti, Necati telefonunu kapattı ve şehri terk etti. ₺40.000 paran buhar oldu. Vicdanın rahat ama kasan yaralı.',
              isSuccess: false,
              moneyDelta: 0.0, // upfrontCost already deducted
              reputationDelta: 0,
              xpReward: 30,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'A1_refuse',
          label: 'Yardım Etme • Reddet',
          shortDescription: 'Paran cebinde kalır, ancak esnafta soğuk bir dedikodu yayılır • -3 İtibar.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Kapıdan Geri Döndü',
              message:
                  'Necati boynunu büküp ayrıldı. Paranı korudun ama sanayide "Eski ortağının yüzüne bile bakmadı" lafları dolaşmaya başladı.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: -3,
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'A2',
      category: DramaticCategory.loss,
      severity: DramaticSeverity.medium,
      title: 'Sahte Ekspertiz Teklifi',
      characterName: 'Şüpheli Ekspertizci',
      characterRole: 'Saha Temsilcisi',
      characterAvatar: 'detective',
      icon: Icons.assignment_late_rounded,
      dialogue:
          '"Usta, o kusurlu aracına hatasız raporu basayım. ₺8.000 ateşle, kâğıt üstünde sıfır hata çıksın. Müşteri de mest olsun, sen de kârını katla."',
      foreshadowHint: 'Cebinden mühürlü boş rapor kâğıtları sarkıyor. Cazip ama tehlikeli bir oyun.',
      choices: [
        DramaticChoiceModel(
          id: 'A2_accept',
          label: 'Raporu Satın Al • -₺8.000',
          shortDescription: '%70 aracın değeri fırlar • +₺35.000, %30 müşteri uyanıp şikayet eder • -15 İtibar & Ceza.',
          upfrontCost: 8000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.70,
              title: 'Kusursuz İllüzyon Başarılı!',
              message:
                  'Sahte raporla araç vitrinde anında yüksek fiyata alıcı buldu! Kasaya net ₺35.000 ekstra kâr girdi.',
              isSuccess: true,
              moneyDelta: 35000.0,
              reputationDelta: 0,
              xpReward: 80,
            ),
            DramaticOutcomeModel(
              probability: 0.30,
              title: 'Baskın ve İtibar Darbesi!',
              message:
                  'Alıcı aracı kendi güvendiği ustaya gösterdi ve sahte rapor patladı! Tüketici heyetine şikayet edildin, ₺20.000 tazminat ödedin ve itibarın sarsıldı.',
              isSuccess: false,
              moneyDelta: -20000.0,
              reputationDelta: -15,
              xpReward: 30,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'A2_reject',
          label: 'Teklifi Kov • Dürüstlük',
          shortDescription: 'Kirli parayı reddedersin. Galerinin onuru korunur • +4 İtibar.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Dürüst Esnaf Duruşu',
              message:
                  'Ekspertizciyi dükkandan kovdun. "Hileyle kazanılan para bereketsizdir" dedin. Sanayi esnafı dürüstlüğünü takdir etti.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 4,
              xpReward: 40,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'A3',
      category: DramaticCategory.loss,
      severity: DramaticSeverity.low,
      title: 'Vergi Denetimi Söylentisi',
      characterName: 'Muhasebeci Kemal Bey',
      characterRole: 'Mali Danışman',
      characterAvatar: 'briefcase',
      icon: Icons.receipt_long_rounded,
      dialogue:
          '"Patron, vergi dairesinden kulağıma geldi; bu ay oto galericileri mercek altına alacaklar. Defterlerdeki ufak pürüzleri ₺15.000\'e tatlıya bağlayacak bir aracı var. Ne dersin?"',
      foreshadowHint: 'Kemal Bey biraz evhamlı bir adamdır ama maliyenin sağı solu belli olmaz.',
      choices: [
        DramaticChoiceModel(
          id: 'A3_pay',
          label: 'Aracıya Öde • -₺15.000',
          shortDescription: '%75 sorun sessizce kapanır, %25 rüşvet söylentisi sızar • -8 İtibar.',
          upfrontCost: 15000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.75,
              title: 'Evraklar Temizlendi',
              message: 'Dosyalar incelendi ve sorunsuz onaylandı. Gece rahat uyuyacaksın.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 0,
              xpReward: 50,
            ),
            DramaticOutcomeModel(
              probability: 0.25,
              title: 'Rüşvet Skandalı!',
              message:
                  'Aracı memur yakalandı! İsminiz dosyada geçti, para gittiği gibi adliye koridorlarında itibarınız zedelendi.',
              isSuccess: false,
              moneyDelta: 0.0,
              reputationDelta: -8,
              xpReward: 20,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'A3_risk',
          label: 'Ödeme Yapma • Riske Gir',
          shortDescription: '%80 denetim uğramaz • 0 masraf, %20 gerçek ceza kesilir • -₺35.000.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.80,
              title: 'Denetim Pas Geçti!',
              message: 'Müfettişler komşu caddedeki galerileri denetledi, sana uğramadı bile! ₺15.000 cebinde kaldı.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 2,
              xpReward: 60,
            ),
            DramaticOutcomeModel(
              probability: 0.20,
              title: 'Vergi Cezası Tebliğ Edildi',
              message:
                  'Maliye kapıya dayandı ve fatura kesimlerindeki gecikmelerden ötürü ₺35.000 idari para cezası kesti.',
              isSuccess: false,
              moneyDelta: -35000.0,
              reputationDelta: -4,
              xpReward: 30,
            ),
          ],
        ),
      ],
    ),

    // -------------------------------------------------------------
    // KATEGORİ B: İHANET & ÇALINMA KARTLARI (Envanter & Güven)
    // -------------------------------------------------------------
    DramaticCardModel(
      id: 'B1',
      category: DramaticCategory.betrayal,
      severity: DramaticSeverity.extreme,
      minPlayerLevel: 3,
      requiresCarInGarage: true,
      title: 'Gece Yarısı Telefonu',
      characterName: 'Gece Bekçisi Şükrü Amca',
      characterRole: 'Site Güvenliği',
      characterAvatar: 'flashlight',
      icon: Icons.notification_important_rounded,
      dialogue:
          '"Patron... sabaha karşı galerinin arka camını patlatmışlar. İçeri girip vitrindeki en değerli arabanın kilidini kırmışlar, araba yok!"',
      foreshadowHint: 'Sanayide organize bir oto hırsızlık şebekesinin kol gezdiği konuşuluyordu.',
      choices: [
        DramaticChoiceModel(
          id: 'B1_investigate',
          label: 'Özel Dedektif & Takip • -₺5.000',
          shortDescription: '%45 araç hasarlı da olsa bulunur • %60 değer, %55 araç tamamen kaybolur.',
          upfrontCost: 5000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.45,
              title: 'Araç Terk Edilmiş Bulundu!',
              message:
                  'Dedektif aracı tenha bir depoda plakasız buldu. Bazı parçaları sökülmüş ama araç kurtarıldı!',
              isSuccess: true,
              loseTargetCar: false,
              recoverCarValueMultiplier: 0.60,
              reputationDelta: 3,
              xpReward: 120,
            ),
            DramaticOutcomeModel(
              probability: 0.55,
              title: 'İzler Tamamen Silindi...',
              message:
                  'Hırsızlar aracı sahte plakayla sınır dışına kaçırmış. Masraf boşa gitti, araç kalıcı olarak kayboldu.',
              isSuccess: false,
              loseTargetCar: true,
              reputationDelta: -2,
              xpReward: 40,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'B1_accept',
          label: 'Polise Bırak, Masraf Etme',
          shortDescription: 'Ekstra para harcamazsın ancak araç kesin olarak kayıtlardan düşer.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Kayıp Kaydı Açıldı',
              message: 'Tutanak tutuldu ancak araçtan bir daha haber alınamadı. Galerinin en değerli parçası gitti.',
              isSuccess: false,
              loseTargetCar: true,
              reputationDelta: 0,
              xpReward: 30,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'B2',
      category: DramaticCategory.betrayal,
      severity: DramaticSeverity.medium,
      title: 'Güvenilir Çalışanın Teklifi',
      characterName: 'Baş Usta',
      characterRole: 'Kıdemli Personel',
      characterAvatar: 'wrench',
      icon: Icons.badge_rounded,
      dialogue:
          '"Patron, rakip galeriden teklif aldım; maaşımı ikiye katlıyorlar. Gitmeden müşteri defterini de getirmemi istediler. Sana sadık kalmamı istersen maaşıma %40 zam yapmalısın."',
      foreshadowHint: 'Emektar ama aklı çelinmiş bir usta. Kararın personelin geleceğini belirleyecek.',
      choices: [
        DramaticChoiceModel(
          id: 'B2_raise',
          label: 'Zammı Kabul Et • +%40 Maaş',
          shortDescription: 'Personel dükkanda kalır, sadakatle çalışır • +%15 Servis Verimi.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Sadakat Satın Alındı',
              message: 'Usta elini sıktı ve rakip teklifi yırttı. Sadakatle çalışmaya devam ediyor.',
              isSuccess: true,
              staffSalaryMultiplier: 1.40,
              reputationDelta: 2,
              xpReward: 70,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'B2_refuse',
          label: 'Zammı Reddet',
          shortDescription: '%50 sessizce ayrılır, %50 müşteri portföyünü çalıp rakibe geçer • -8 İtibar.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.50,
              title: 'Dürüstçe Ayrıldı',
              message: 'Usta helallik isteyip ayrıldı, müşteri sırlarını paylaşmadı.',
              isSuccess: true,
              reputationDelta: 0,
              xpReward: 40,
            ),
            DramaticOutcomeModel(
              probability: 0.50,
              title: 'Müşterileri Rakibe Taşıdı!',
              message: 'Usta rakibe geçti ve VIP müşterilerini oraya yönlendirdi. İtibarın zedelendi.',
              isSuccess: false,
              reputationDelta: -8,
              xpReward: 30,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'B2_fire',
          label: 'Hemen Kov!',
          shortDescription: 'Hainliği affetmezsin. %25 haksız fesih davası • -₺15.000, %75 temiz ayrılık.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.75,
              title: 'Kapı Dışarı Edildi',
              message: 'Tehdide boyun eğmedin. Esnaf dik duruşunu takdirle karşıladı.',
              isSuccess: true,
              reputationDelta: 3,
              xpReward: 50,
            ),
            DramaticOutcomeModel(
              probability: 0.25,
              title: 'İş Mahkemesi Tazminatı',
              message: 'Usta avukat tutup tazminat davası açtı. Kasadan ₺15.000 çıktı.',
              isSuccess: false,
              moneyDelta: -15000.0,
              reputationDelta: -4,
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'B3',
      category: DramaticCategory.betrayal,
      severity: DramaticSeverity.high,
      requiresCarInGarage: true,
      title: 'Sahte Alıcı, Gerçek Dolandırıcı',
      characterName: 'Kibar Beyefendi',
      characterRole: 'Zengin Görünümlü Alıcı',
      characterAvatar: 'sunglasses',
      icon: Icons.directions_car_filled_rounded,
      dialogue:
          '"Araca bayıldım, hemen nakit alıyorum. Cüzdanımı ve çek koçanımı arabamda unuttum, anahtarı verin bir sesini dinleyip geri döneyim."',
      foreshadowHint: 'Pahalı takım elbisesi var ama gözleri sürekli çıkış kapısına bakıyor.',
      choices: [
        DramaticChoiceModel(
          id: 'B3_trust',
          label: 'Anahtarı Ver • Güven',
          shortDescription: '%65 gerçekten dönüp aracı alır • +₺40.000 Kâr, %35 gaza basıp çalar!',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.65,
              title: 'Cömert ve Hızlı Satış!',
              message: 'Adam gerçekten cüzdanını alıp geldi, parayı nakit saydı ve ekstra ₺40.000 kâr bıraktı!',
              isSuccess: true,
              moneyDelta: 40000.0,
              reputationDelta: 4,
              xpReward: 90,
            ),
            DramaticOutcomeModel(
              probability: 0.35,
              title: 'Tozu Dumana Kattı!',
              message: 'Gaza bastığı gibi ana yola fırladı ve kayıplara karıştı! Araç tamamen çalındı.',
              isSuccess: false,
              loseTargetCar: true,
              reputationDelta: -6,
              xpReward: 30,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'B3_refuse',
          label: 'Önce Parayı Gör • Tedbir',
          shortDescription: 'Alıcı gücenip gider, sıfır riskle araç güvende kalır.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Şüpheli Ayrıldı',
              message: 'Parayı görmeden anahtar vermeyeceğini söyledin. Adam aceleyle dükkandan uzaklaştı.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 1,
              xpReward: 30,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'B4',
      category: DramaticCategory.betrayal,
      severity: DramaticSeverity.high,
      requiresBlackMarketHistory: true,
      requiresCarInGarage: true,
      title: 'Karaborsa İhbarı',
      characterName: 'Gölge İbrahim',
      characterRole: 'Karaborsa Aracısı',
      characterAvatar: 'detective_man',
      icon: Icons.policy_rounded,
      dialogue:
          '"Usta, o aldığın şaibeli araç hakkında mali şube dosya açmış. Polis gelmeden ben evrakları temizlerim ama ₺25.000 bedeli var."',
      foreshadowHint: 'Karaborsadan araç almanın faturası kapıya dayandı.',
      choices: [
        DramaticChoiceModel(
          id: 'B4_bribe',
          label: 'Bedeli Öde • -₺25.000',
          shortDescription: 'Dosya sessizce kapanır, araç güvenle galeride kalır.',
          upfrontCost: 25000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Dosya Kapatıldı',
              message: 'İbrahim gerekli yerlere ulaştı ve inceleme düştü. Araç güvende.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 0,
              xpReward: 60,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'B4_ignore',
          label: 'Blöf Say, Ödeme Yapma',
          shortDescription: '%50 blöftür hiçbir şey olmaz, %50 araca el konur • -20 İtibar.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.50,
              title: 'Blöf Çıktı!',
              message: 'Gölge İbrahim sadece para koparmaya çalışıyormuş. Aracına dokunan olmadı.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 2,
              xpReward: 80,
            ),
            DramaticOutcomeModel(
              probability: 0.50,
              title: 'Mali Şube El Koydu!',
              message: 'Ekipler gelip aracı yediemin otoparkına çekti. Araç gitti ve ağır itibar kaybettin.',
              isSuccess: false,
              loseTargetCar: true,
              reputationDelta: -20,
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),

    // -------------------------------------------------------------
    // KATEGORİ C: VİCDAN KARTLARI (Ahlak & İtibar)
    // -------------------------------------------------------------
    DramaticCardModel(
      id: 'C1',
      category: DramaticCategory.conscience,
      severity: DramaticSeverity.low,
      title: 'Dul Kadının Arabası',
      characterName: 'Gülümser Teyze',
      characterRole: 'Yaşlı Mirasçı',
      characterAvatar: 'grandma',
      icon: Icons.volunteer_activism_rounded,
      dialogue:
          '"Oğlum, rahmetli beyimin arabası garajda duruyor. Ben piyasadan anlamam, bana ₺70.000 versen yeter, ilaca harcayacağım."',
      foreshadowHint: 'Aracın gerçek piyasa değeri en az ₺180.000. Kadının hiçbir şeyden haberi yok.',
      choices: [
        DramaticChoiceModel(
          id: 'C1_honest',
          label: 'Gerçek Değerini Söyle • ₺150.000 Teklif Et',
          shortDescription: 'Daha az kâr edersin ama büyük itibar ve vicdan rahatlığı kazanırsın • +10 İtibar.',
          upfrontCost: 150000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Helal Kazanç & Esnafın Duası',
              message:
                  'Kadın gözyaşlarıyla dua etti. Sanayide "Hakkı yemeyen tek galerici" olarak anılmaya başladın. İtibarın zirve yaptı!',
              isSuccess: true,
              spawnBargainCar: true,
              reputationDelta: 10,
              xpReward: 150,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'C1_exploit',
          label: 'Kadının Dediği Fiyata Al • ₺70.000',
          shortDescription: 'Muazzam kâr marjı • +₺110.000 değer, sıfır mekanik ceza, tamamen senin vicdanın.',
          upfrontCost: 70000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Kelepir Fırsat Kasada',
              message:
                  'Aracı ₺70.000\'e aldın. Çok yüksek bir kâr elde edeceksin. Kadın teşekkür edip gitti ama içinde garip bir burukluk var.',
              isSuccess: true,
              spawnBargainCar: true,
              reputationDelta: 0,
              xpReward: 50,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'C2',
      category: DramaticCategory.conscience,
      severity: DramaticSeverity.low,
      title: 'Rakibin Zor Günü',
      characterName: 'Rakip Galeri Sahibi',
      characterRole: 'Meslektaş',
      characterAvatar: 'suit',
      icon: Icons.storefront_rounded,
      dialogue:
          '"Komşu... banka kredim patlamak üzere. Elimdeki kelepir arabayı zararına ₺80.000\'e veriyorum, bana nakit lazım."',
      foreshadowHint: 'Aracın normal piyasası ₺140.000. Alırsan rakibin dükkanı kapatabilir.',
      choices: [
        DramaticChoiceModel(
          id: 'C2_buy',
          label: 'Fırsatı Kaçırma, Satın Al • -₺80.000',
          shortDescription: 'Kelepir aracı envanterine katarsın, kârlı bir alım.',
          upfrontCost: 80000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Portföye Yeni Araç!',
              message: 'Aracı ucuza kapattın. Vitrinde iyi fiyata satıp güzel kâr elde edebilirsin.',
              isSuccess: true,
              spawnBargainCar: true,
              reputationDelta: 0,
              xpReward: 80,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'C2_help',
          label: 'Dayanışma Göster, Alma',
          shortDescription: 'Centilmen esnaf tavrı sergilersin • +6 İtibar.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Centilmen Galerici',
              message: 'Rakibinin düşüşünden faydalanmadın. Esnaf odasında saygınlığın arttı.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 6,
              xpReward: 60,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'C3',
      category: DramaticCategory.conscience,
      severity: DramaticSeverity.low,
      title: 'Genç Çiftin İlk Arabası',
      characterName: 'Genç Çift • Emre & Selin',
      characterRole: 'Yeni Evliler',
      characterAvatar: 'couple',
      icon: Icons.favorite_rounded,
      dialogue:
          '"Abi bu arabayı çok sevdik ama bütçemiz ₺30.000 eksik kalıyor. Düğün borçlarımız var, biraz indirim yapamaz mısın?"',
      foreshadowHint: 'Gözlerindeki heyecan parlıyor, ilk arabaları olacak.',
      choices: [
        DramaticChoiceModel(
          id: 'C3_discount',
          label: 'Fiyatı Kır, Gençleri Sevindir • -₺30.000 Kâr',
          shortDescription: 'Kârdan feragat edersin, sıcak müşteri sevgisi kazanırsın • +7 İtibar.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Gençlerin Yüzü Güldü!',
              message: 'Aracı indirimle sattın. Çift sosyal medyada galerini öve öve bitiremedi!',
              isSuccess: true,
              moneyDelta: 15000.0,
              reputationDelta: 7,
              xpReward: 90,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'C3_insist',
          label: 'Fiyatta Israr Et • Pazarlık Yok',
          shortDescription: 'Standart kârını korursun, çift üzgün ayrılır.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Ticaret Ticarettir',
              message: 'Taviz vermedin. Araç vitrinde kaldı.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 0,
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),

    // -------------------------------------------------------------
    // KATEGORİ D: MİRAS KARTLARI (Duygu & Bağlılık)
    // -------------------------------------------------------------
    DramaticCardModel(
      id: 'D1',
      category: DramaticCategory.legacy,
      severity: DramaticSeverity.low,
      requiresHeirloomCar: true,
      title: 'Dede\'nin Eski Çırağı',
      characterName: 'Usta Selim',
      characterRole: 'Dede Hasan\'ın Eski Çırağı',
      characterAvatar: 'grandpa',
      icon: Icons.auto_awesome_rounded,
      dialogue:
          '"Evlat... Hasan Ustam o Murat 124\'ü dükkanın ilk gününde almıştı. \'Bu araba bu galerinin ruhudur, satılmaz\' derdi. Sen ne yapacaksın?"',
      foreshadowHint: 'Dedenin mirasına olan vefanı sorgulayan duygusal bir an.',
      choices: [
        DramaticChoiceModel(
          id: 'D1_keep',
          label: 'Miras Olarak Kilitle • Aile Yadigarı',
          shortDescription: 'Araç satılamaz koleksiyon statüsü kazanır, kalıcı itibar sağlar • +8 İtibar.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Aile Yadigarı Tescillendi!',
              message: 'Dedenin emanetine sahip çıktın. Galerinin vitrininde onur köşesine yerleştirildi.',
              isSuccess: true,
              makeFamilyHeirloom: true,
              reputationDelta: 8,
              xpReward: 120,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'D1_sell',
          label: '"Zamanı Geldiğinde Satılır"',
          shortDescription: 'Duygusallığı bir kenara bırakırsın.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Rasyonel Karar',
              message: 'Usta Selim derin bir iç çekip ayrıldı. Ticarete devam.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 0,
              xpReward: 30,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'D2',
      category: DramaticCategory.legacy,
      severity: DramaticSeverity.low,
      isNarrativeOnly: true,
      title: 'Eski Fotoğraf',
      characterName: 'Sarı Zarf',
      characterRole: 'Geçmişten Hatıra',
      characterAvatar: 'letter',
      icon: Icons.photo_library_rounded,
      dialogue:
          'Kapının altından eski bir sarı zarf atılmış. İçinde genç Hasan Usta\'nın ilk galerisi önünde çektirdiği siyah beyaz fotoğraf var. Arkasında el yazısı: "Bir gün torunum burayı benden daha büyük yapacak."',
      foreshadowHint: 'Dedenin inancı sana güç veriyor.',
      choices: [
        DramaticChoiceModel(
          id: 'D2_continue',
          label: 'Fotoğrafı Masana Koy • +100 XP',
          shortDescription: 'Duygusal an, motivasyonunu ve vizyonunu güçlendirir.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'İlham Verici Miras',
              message: 'Fotoğrafı çalışma masanın en güzel yerine astın. Dedenin hayalini büyüteceksin!',
              isSuccess: true,
              reputationDelta: 3,
              xpReward: 100,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'D3',
      category: DramaticCategory.legacy,
      severity: DramaticSeverity.medium,
      title: 'Kardeşin Payı',
      characterName: 'Kuzen Tarık',
      characterRole: 'Miras Hak Sahibi',
      characterAvatar: 'smirk',
      icon: Icons.account_balance_rounded,
      dialogue:
          '"Kuzen, dedemin galerisinde benim de yasal hakkım var. Mahkemeye gitmeden sulh olalım; bana ₺50.000 ver, noterden feragatnameyi imzalayayım."',
      foreshadowHint: 'Avukatıyla gelmiş, işi resmiyete dökmekte kararlı.',
      choices: [
        DramaticChoiceModel(
          id: 'D3_pay',
          label: '₺50.000 Öde, İmzayı Al',
          shortDescription: 'Galerinin mülkiyeti tamamen sana geçer, pürüz kalmaz.',
          upfrontCost: 50000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Mülkiyet Tamamen Senin',
              message: 'Noterde imzalar atıldı. Artık galeride hiç kimse hak iddia edemez.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 4,
              xpReward: 80,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'D3_bargain',
          label: 'Sert Pazarlık Et',
          shortDescription: '%50 ihtimalle ₺25.000\'e razı olur, %50 mahkemeye gider • -₺70.000 & -6 İtibar.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.50,
              title: 'Pazarlık Kazandı!',
              message: 'Tarık sıkıştı ve ₺25.000 nakite razı olup feragat etti.',
              isSuccess: true,
              moneyDelta: -25000.0,
              reputationDelta: 2,
              xpReward: 90,
            ),
            DramaticOutcomeModel(
              probability: 0.50,
              title: 'Dava Açıldı!',
              message: 'Tarık dava açtı. Avukat ve harç masraflarıyla ₺70.000 ödemek zorunda kaldın.',
              isSuccess: false,
              moneyDelta: -70000.0,
              reputationDelta: -6,
              xpReward: 30,
            ),
          ],
        ),
      ],
    ),

    // -------------------------------------------------------------
    // KATEGORİ E: KUMAR & ADRENALİN KARTLARI (Çift Yönlü Risk)
    // -------------------------------------------------------------
    DramaticCardModel(
      id: 'E1',
      category: DramaticCategory.gamble,
      severity: DramaticSeverity.medium,
      title: 'Kapalı Zarf İhalesi',
      characterName: 'Gümrük Komisyoncusu',
      characterRole: 'İhale Simsar',
      characterAvatar: 'dice',
      icon: Icons.casino_rounded,
      dialogue:
          '"Gümrükte el konulan konteynerlerden kapalı zarf araç ihalesi var. ₺50.000 veriyorsun, içinden ne çıkarsa senin oluyor. Var mısın?"',
      foreshadowHint: 'Bazen süper lüks spor araba çıkar, bazen motoru yanmış hurda.',
      choices: [
        DramaticChoiceModel(
          id: 'E1_gamble',
          label: 'Zarfı Satın Al • -₺50.000',
          shortDescription: '%15 Efsane Spor Araç • +₺250.000, %35 İyi Araç • +₺90.000, %50 Hurda Çıkar.',
          upfrontCost: 50000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.15,
              title: 'JACKPOT! Efsane Koleksiyon Arabası!',
              message: 'Konteynerden gümrükte unutulmuş hatasız bir klasik canavar çıktı! Değeri ₺250.000 üzerinde!',
              isSuccess: true,
              spawnBargainCar: true,
              moneyDelta: 150000.0,
              reputationDelta: 8,
              xpReward: 200,
            ),
            DramaticOutcomeModel(
              probability: 0.35,
              title: 'Kârlı Ticaret!',
              message: 'Konteynerden piyasada peynir ekmek gibi giden temiz bir aile aracı çıktı. Güzel kâr bıraktı.',
              isSuccess: true,
              spawnBargainCar: true,
              moneyDelta: 35000.0,
              reputationDelta: 2,
              xpReward: 100,
            ),
            DramaticOutcomeModel(
              probability: 0.50,
              title: 'Hurda Çıktı...',
              message: 'Konteyner açıldığında içi çürümüş bir enkazla karşılaştın. Zarar ettin.',
              isSuccess: false,
              moneyDelta: 5000.0, // scrap scrap salvage
              reputationDelta: 0,
              xpReward: 40,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'E1_pass',
          label: 'Pasa Geç • Sıfır Risk',
          shortDescription: 'Paran kasanda kalır, kumara girmezsin.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Temkinli Tüccar',
              message: 'Bilinmeyen kutuya para yatırmadın. Güvenli ticarete devam.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 0,
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),

    DramaticCardModel(
      id: 'E2',
      category: DramaticCategory.gamble,
      severity: DramaticSeverity.extreme,
      minPlayerLevel: 2,
      requiresCarInGarage: true,
      title: 'Çifte veya Hiç!',
      characterName: 'Zengin Kumarbaz Alıcı',
      characterRole: 'VIP Koleksiyoner',
      characterAvatar: 'slot',
      icon: Icons.monetization_on_rounded,
      dialogue:
          '"En değerli aracını beğendim. Sana çılgın bir teklif: Yazı tura atacağız. Tura gelirse aracın değerinin %180\'ini nakit öderim. Yazı gelirse... aracı bedavaya anahtarıyla alıp giderim!"',
      foreshadowHint: 'Avucundaki altın parayı havaya atıp tutuyor. Saf adrenalin ya da tam hüsran.',
      choices: [
        DramaticChoiceModel(
          id: 'E2_flip',
          label: 'Yazı Tura At! • Çifte veya Hiç',
          shortDescription: '%50 Tura: Dev Kazanç • +%80 Ekstra Kâr, %50 Yazı: Araç Bedavaya Gider!',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.50,
              title: 'TURA GELDİ! MUHTEŞEM KAZANÇ!',
              message: 'Para havada döndü ve TURA düştü! Kumarbaz sözünü tuttu ve ₺120.000 ekstra nakit ödedi!',
              isSuccess: true,
              moneyDelta: 120000.0,
              reputationDelta: 10,
              xpReward: 250,
            ),
            DramaticOutcomeModel(
              probability: 0.50,
              title: 'YAZI GELDİ... ARAÇ GİTTİ!',
              message: 'Para YAZI düştü. Kumarbaz gülümseyerek anahtarı aldı ve gaza bastı. Araç tamamen gitti!',
              isSuccess: false,
              loseTargetCar: true,
              reputationDelta: -5,
              xpReward: 50,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'E2_reject',
          label: 'Kumarı Reddet • Standart Satış',
          shortDescription: 'Riske girmezsin, aracın güvende kalır.',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Sağduyu Kazandı',
              message: 'Kumarbazın teklifini geri çevirdin. Galericilik şans işi değil, emek işidir dedin.',
              isSuccess: true,
              moneyDelta: 0.0,
              reputationDelta: 2,
              xpReward: 40,
            ),
          ],
        ),
      ],
    ),
  ];
}
