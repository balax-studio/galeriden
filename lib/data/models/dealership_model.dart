import 'car_model.dart';
import 'offer_model.dart';
import 'loan_model.dart';
import 'part_order_model.dart';
import 'staff_model.dart';
import 'customer_review_model.dart';
import 'player_skills.dart';
import 'player_achievements.dart';
import 'expertise_model.dart';
import 'mission_model.dart';
import 'market_trend_model.dart';
import 'sale_record_model.dart';
import 'cheque_model.dart';
import 'installment_contract_model.dart';
import 'rental_agreement_model.dart';
import 'side_business_model.dart';
import 'stock_model.dart';
import 'game_event_model.dart';

class DealershipModel {
  final double balance;
  final int level;
  final int maxGarageSlots;
  final List<CarModel> ownedCars;
  final List<OfferModel> incomingOffers;
  final double totalProfit;
  final int carsSold;
  final DateTime lastActiveTime;
  final PlayerSkills skills;
  final List<AchievementItem> achievements;
  final int loginStreak;
  final DateTime lastLoginDate;
  final List<MissionModel> activeMissions;
  final MarketTrendModel marketTrend;
  final int reputationScore;
  final List<LoanModel> activeLoans;
  final List<PartOrderModel> pendingOrders;
  final List<StaffModel> hiredStaff;
  final List<CustomerReviewModel> customerReviews;
  final List<SaleRecordModel> salesHistory;
  final List<Cheque> activeCheques;
  final List<InstallmentContract> activeInstallments;
  final List<RentalAgreement> activeRentals;
  final bool tutorialCompleted;
  final int tutorialStepIndex;
  final int currentDay;
  final String playerName;
  final String dealershipName;
  final String logoEmblemId;
  final DateTime? lastRewardClaimDate;
  
  // Yeni Pasif Gelir ve Ekonomi Alanları
  final List<SideBusinessModel> sideBusinesses;
  final List<StockModel> marketStocks;
  final List<PlayerStockModel> ownedStocks;
  final List<GameEventModel> recentEvents;
  final double dailyTaxRate;

  DateTime get inGameTime => DateTime.now();

  DealershipModel({
    required this.balance,
    required this.level,
    required this.maxGarageSlots,
    required this.ownedCars,
    required this.incomingOffers,
    required this.totalProfit,
    required this.carsSold,
    required this.lastActiveTime,
    required this.skills,
    required this.achievements,
    required this.loginStreak,
    required this.lastLoginDate,
    required this.activeMissions,
    required this.marketTrend,
    this.reputationScore = 100,
    this.activeLoans = const [],
    this.pendingOrders = const [],
    this.hiredStaff = const [],
    this.customerReviews = const [],
    this.salesHistory = const [],
    this.activeCheques = const [],
    this.activeInstallments = const [],
    this.activeRentals = const [],
    this.tutorialCompleted = false,
    this.tutorialStepIndex = 0,
    this.currentDay = 1,
    this.playerName = 'Kaptan',
    this.dealershipName = 'Miras Oto Galeri',
    this.logoEmblemId = 'crown',
    this.lastRewardClaimDate,
    this.sideBusinesses = const [],
    this.marketStocks = const [],
    this.ownedStocks = const [],
    this.recentEvents = const [],
    this.dailyTaxRate = 150.0,
  });

  factory DealershipModel.initial() {
    final now = DateTime.now();
    // Inherited Heritage Car from grandfather Hasan Usta
    final heritageCar = CarModel(
      id: 'car_heritage_dede',
      brand: 'Tofaş',
      modelName: 'Murat 124 (Dede Mirası)',
      modelYear: 1978,
      bodyType: 'Klasik',
      colorHex: '0xFF8B4513', // Saddle Brown
      baseMarketValue: 240000.0,
      currentPurchasePrice: 0.0, // Inherited for free
      isRare: true,
      expertise: ExpertiseReport(
        engineCondition: 40.0, // Low condition engine
        transmissionCondition: 50.0, // Low condition gearbox
        tramerAmount: 12500,
        mileage: 215000,
        isMileageTampered: false,
        bodyParts: {
          'Kaput': PartStatus.damaged,
          'Tavan': PartStatus.painted,
          'Sol Kapı': PartStatus.changed,
          'Sağ Kapı': PartStatus.damaged,
          'Bagaj': PartStatus.painted,
        },
        partConditions: {
          'Kaput': 25.0,
          'Tavan': 65.0,
          'Sol Kapı': 45.0,
          'Sağ Kapı': 30.0,
          'Bagaj': 70.0,
        },
      ),
    );

    return DealershipModel(
      balance: 75000.0, // Starting money: 75k TL
      level: 1,
      maxGarageSlots: 3,
      ownedCars: [heritageCar],
      incomingOffers: [],
      totalProfit: 0.0,
      carsSold: 0,
      lastActiveTime: now,
      skills: PlayerSkills(),
      achievements: PlayerAchievements.initialList,
      loginStreak: 1,
      lastLoginDate: now,
      activeMissions: [
        MissionModel(
          id: 'm_heritage_1',
          title: 'Dede Mirası',
          description: 'Miras arabayı onarıp ilk satışını yap',
          type: MissionType.sellCars,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 35000,
          rewardXP: 250,
        ),
      ],
      marketTrend: MarketTrendModel.defaultTrend(),
      activeLoans: const [],
      pendingOrders: const [],
      activeCheques: const [],
      activeInstallments: const [],
      activeRentals: const [],
      salesHistory: [
        SaleRecordModel(
          id: 'sale_init_1',
          carTitle: '1998 Tofaş Şahin 1.6 ie',
          buyerName: 'Ahmet Yılmaz',
          purchasePrice: 95000.0,
          salePrice: 135000.0,
          netProfit: 40000.0,
          saleDay: 0,
          saleDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        SaleRecordModel(
          id: 'sale_init_2',
          carTitle: '2004 Renault Toros Wagon',
          buyerName: 'Mehmet Kaya',
          purchasePrice: 110000.0,
          salePrice: 148000.0,
          netProfit: 38000.0,
          saleDay: 0,
          saleDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      tutorialCompleted: false,
      tutorialStepIndex: 0,
      sideBusinesses: [
        SideBusinessModel(
          id: 'sb_1',
          name: 'Otomat & Kahve İstasyonu',
          description: 'Galeri müşterilerine taze çekirdek espresso ve soğuk meşrubat satarak günlük pasif gelir sağla.',
          type: SideBusinessType.vendingMachine,
          dailyIncome: 120.0,
          cost: 6000.0,
          managerTitle: 'Kafeterya Sorumlusu Canan Hanım',
          managerCost: 5000.0,
          managerSalary: 40.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_1_u1', title: 'İtalyan Espresso Öğütücü', description: 'Gelen müşterilerin bekleme süresinde taze kahve tüketimini artıran barista modülü.', cost: 3000.0, bonusDailyIncome: 80.0, iconName: 'coffee'),
            SideBusinessUpgradeModel(id: 'sb_1_u2', title: 'Soğuk İçecek & Enerji Kutusu Modülü', description: 'Yaz aylarında otomat satışlarını ikiye katlayan soğutucu hazne.', cost: 5000.0, bonusDailyIncome: 140.0, iconName: 'local_drink'),
            SideBusinessUpgradeModel(id: 'sb_1_u3', title: 'Temassız POS Ödeme Terminali', description: 'Nakit taşımayan müşterilerin doğrudan NFC & Kredi Kartı ile ödeme yapmasını sağlar.', cost: 9000.0, bonusDailyIncome: 250.0, iconName: 'credit_card'),
            SideBusinessUpgradeModel(id: 'sb_1_u4', title: 'Akıllı Atıştırmalık & Sandviç Dolabı', description: 'Gece ve gündüz 24 saat kesintisiz taze gıda imkanı.', cost: 14000.0, bonusDailyIncome: 400.0, iconName: 'restaurant'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_2',
          name: 'Oto Yıkama & Detaylandırma Merkezi',
          description: 'Galerinin yanında profesyonel oto yıkama, köpük tüneli ve iç temizleme peronu kur.',
          type: SideBusinessType.carWash,
          dailyIncome: 400.0,
          cost: 25000.0,
          managerTitle: 'Yıkama Amiri İsmail Usta',
          managerCost: 15000.0,
          managerSalary: 100.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_2_u1', title: 'Köpük Tabancası & Seramik Şampuan', description: 'Hızlı yıkama kapasitesini artırır ve araç başına kâr marjını yükseltir.', cost: 12000.0, bonusDailyIncome: 300.0, iconName: 'water_drop'),
            SideBusinessUpgradeModel(id: 'sb_2_u2', title: 'Otomatik Fırçasız Yıkama Tüneli', description: 'Dakikada 2 araç yıkayan tam otomatik yüksek basınçlı konveyör tünel.', cost: 25000.0, bonusDailyIncome: 650.0, iconName: 'precision_manufacturing'),
            SideBusinessUpgradeModel(id: 'sb_2_u3', title: 'VIP Buharlı Sterilizasyon & Detay', description: 'Araç içi bakterileri yok eden, deri ve döşeme yenileyen VIP alan.', cost: 45000.0, bonusDailyIncome: 1200.0, iconName: 'clean_hands'),
            SideBusinessUpgradeModel(id: 'sb_2_u4', title: 'Seramik Kaplama & Pasta Cila Pad’i', description: 'Sıfır ve ikinci el araçlara profesyonel boya koruma uygulaması.', cost: 75000.0, bonusDailyIncome: 2100.0, iconName: 'auto_awesome'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_3',
          name: 'Dijital Reklam Panosu & Medya Cephesi',
          description: 'Galerinin caddeye bakan cephesine LED panolar kurarak dev markalardan kurumsal reklam al.',
          type: SideBusinessType.billboard,
          dailyIncome: 800.0,
          cost: 60000.0,
          managerTitle: 'Medya & Reklam Müdürü Sibel Hanım',
          managerCost: 25000.0,
          managerSalary: 150.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_3_u1', title: '4K Ultra HD LED Panel Upgrade', description: 'Yüksek çözünürlüklü ekranlarla premium markalardan reklam al.', cost: 35000.0, bonusDailyIncome: 750.0, iconName: 'tv'),
            SideBusinessUpgradeModel(id: 'sb_3_u2', title: 'Lazer Gece Gösterisi & 3D Projektör', description: 'Gece trafiğinde sürücülerin dikkatini çeken ikonik lazer gösterisi.', cost: 65000.0, bonusDailyIncome: 1500.0, iconName: 'wb_incandescent'),
            SideBusinessUpgradeModel(id: 'sb_3_u3', title: 'Kurumsal Sigorta & Akaryakıt Sponsorluğu', description: 'Ulusal oto sigorta ve petrol devleriyle sabit yıllık reklam sözleşmesi.', cost: 110000.0, bonusDailyIncome: 2600.0, iconName: 'handshake'),
            SideBusinessUpgradeModel(id: 'sb_3_u4', title: 'AI Odaklı Canlı Trafik Reklam Sistemi', description: 'Kamera verileriyle yoldan geçen araç segmentine göre anlık reklam değiştirir.', cost: 170000.0, bonusDailyIncome: 4200.0, iconName: 'psychology'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_4',
          name: '7/24 Oto Çekici & Kurtarma Filosu',
          description: 'Otobanda veya şehir içinde yolda kalan araçlara 7/24 çekici ve vinç hizmeti ver.',
          type: SideBusinessType.towTruck,
          dailyIncome: 1500.0,
          cost: 120000.0,
          managerTitle: 'Filo Başşoförü Kadir Usta',
          managerCost: 35000.0,
          managerSalary: 250.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_4_u1', title: 'Hidrolik Kayar Kasa Vinç', description: 'Lüks ve alçak tabanlı spor araçları sıfır hasarla çekme yeteneği.', cost: 60000.0, bonusDailyIncome: 1400.0, iconName: 'minor_crash'),
            SideBusinessUpgradeModel(id: 'sb_4_u2', title: 'Gece Acil Yol Yardım Sözleşmesi', description: 'Sigorta acenteleriyle anlaşarak gece çağrılarına özel yüksek tarife uygula.', cost: 110000.0, bonusDailyIncome: 2800.0, iconName: 'emergency'),
            SideBusinessUpgradeModel(id: 'sb_4_u3', title: 'Çift Araç Taşıyıcı Ağır Treyler', description: 'Aynı anda 2 aracı birden taşıyabilen ağır hizmet çekici kamyonu.', cost: 180000.0, bonusDailyIncome: 4800.0, iconName: 'fire_truck'),
            SideBusinessUpgradeModel(id: 'sb_4_u4', title: 'Otoyol Devriye Lojistik Merkezi', description: 'Otoyol gişelerine yakın lojistik istasyonuyla çağrı süresini 10 dakikaya indirir.', cost: 280000.0, bonusDailyIncome: 8000.0, iconName: 'alt_route'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_5',
          name: 'Oto Aksesuar & Tuning Store',
          description: 'Galerinin içinde yedek parça, kokpit aksesuarları, jant ve ses sistemleri satan mağaza aç.',
          type: SideBusinessType.autoShop,
          dailyIncome: 700.0,
          cost: 50000.0,
          managerTitle: 'Tuning Mağaza Müdürü Hakan Bey',
          managerCost: 20000.0,
          managerSalary: 120.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_5_u1', title: 'Oto Kokusu & Seramik Bakım Stantı', description: 'Hızlı tüketim araç bakım kimyasalları ve lüks oto kokuları stantı.', cost: 25000.0, bonusDailyIncome: 550.0, iconName: 'sanitizer'),
            SideBusinessUpgradeModel(id: 'sb_5_u2', title: 'Performans Egzoz & Tuning Reyonu', description: 'Spor araç tutkunları için açık hava filtreleri, chip tuning ve egzoz sistemleri.', cost: 45000.0, bonusDailyIncome: 1100.0, iconName: 'speed'),
            SideBusinessUpgradeModel(id: 'sb_5_u3', title: 'Lüks Jant & Lastik Teşhir Vitrini', description: 'Çelik ve döküm alaşım 18-22 inç performans jant takımları vitrini.', cost: 80000.0, bonusDailyIncome: 2000.0, iconName: 'tire_repair'),
            SideBusinessUpgradeModel(id: 'sb_5_u4', title: 'Online E-Ticaret & Kargo Entegrasyonu', description: 'Tüm Türkiye’ye İnternet üzerinden aksesuar ve tuning parçaları kargolama.', cost: 130000.0, bonusDailyIncome: 3400.0, iconName: 'local_shipping'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_6',
          name: 'Oto Ekspertiz & Muayene İstasyonu',
          description: 'İkinci el araç alım-satımında motor, kaporta, şase ve beyin ekspertizi yaparak kurumsal güven sağla.',
          type: SideBusinessType.inspectionStation,
          dailyIncome: 1200.0,
          cost: 90000.0,
          managerTitle: 'Başeksper Turgut Usta',
          managerCost: 30000.0,
          managerSalary: 200.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_6_u1', title: 'Dinamometre (Dyno) Güç Test Cihazı', description: 'Motor BG ve tork performansını milisaniyelik ölçen silindir dyno testi.', cost: 40000.0, bonusDailyIncome: 950.0, iconName: 'speed'),
            SideBusinessUpgradeModel(id: 'sb_6_u2', title: 'Dijital Süspansiyon & Fren Test Hattı', description: 'Amortisör verimliliği ve fren sapmalarını bilgisayarlı rampada test etme.', cost: 75000.0, bonusDailyIncome: 1800.0, iconName: 'build_circle'),
            SideBusinessUpgradeModel(id: 'sb_6_u3', title: 'OBD2 Ağır Vasıta Beyin Tarayıcı', description: 'Gizlenen kilometre ve geçmiş arıza kodlarını ortaya çıkaran lisanslı tarayıcı.', cost: 130000.0, bonusDailyIncome: 3300.0, iconName: 'memory'),
            SideBusinessUpgradeModel(id: 'sb_6_u4', title: 'Mikron Kaporta & Şase Lazer Cihazı', description: 'Kazalı veya boyalı parçaları mikron hassasiyetinde tespit eden mikroskopik tarayıcı.', cost: 210000.0, bonusDailyIncome: 5500.0, iconName: 'center_focus_strong'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_7',
          name: 'Oto Kiralama & VIP Filo Hizmetleri',
          description: 'Galerideki araçları veya özel filoyu günlük, haftalık ve kurumsal bazda kiralayarak yüksek gelir elde et.',
          type: SideBusinessType.carRental,
          dailyIncome: 2200.0,
          cost: 180000.0,
          managerTitle: 'Filo Operasyon Müdürü Zeynep Hanım',
          managerCost: 45000.0,
          managerSalary: 300.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_7_u1', title: 'Şehir İçi Günlük Kiralama Filosu', description: 'Havalimanı ve otogarlarda turistlere ve iş insanlarına araç teslimi.', cost: 90000.0, bonusDailyIncome: 2000.0, iconName: 'flight_land'),
            SideBusinessUpgradeModel(id: 'sb_7_u2', title: 'VIP Makam Aracı & Şoförlü Transfer', description: 'Siyah camlı lüks SUV ve sedan araçlarla özel lansman transferleri.', cost: 160000.0, bonusDailyIncome: 4000.0, iconName: 'airline_seat_recline_extra'),
            SideBusinessUpgradeModel(id: 'sb_7_u3', title: 'Kurumsal Şirket Filo Sözleşmeleri', description: 'Holdinglere 12 aylık filo kiralama yaparak düzenli nakit akışı oluşturma.', cost: 270000.0, bonusDailyIncome: 7200.0, iconName: 'business_center'),
            SideBusinessUpgradeModel(id: 'sb_7_u4', title: 'Akıllı Mobil Araç Paylaşım Uygulaması', description: 'Müşterilerin cep telefonundan kapısını açıp dakika bazlı kiralama yapması.', cost: 420000.0, bonusDailyIncome: 11500.0, iconName: 'phone_android'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_8',
          name: 'Oto Elektrik & EV Hızlı Şarj Hub’ı',
          description: 'Geleceğin otomotiv teknolojisi: Elektrikli araçlar için ultra hızlı DC şarj istasyonu ve batarya servisi.',
          type: SideBusinessType.evCharging,
          dailyIncome: 3000.0,
          cost: 250000.0,
          managerTitle: 'Elektrik Mühendisi Burak Bey',
          managerCost: 55000.0,
          managerSalary: 400.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_8_u1', title: 'AC Type-2 22kW Şarj Prizleri', description: 'Park halindeki araçların 2-4 saatte şarj olmasını sağlayan standart peronlar.', cost: 120000.0, bonusDailyIncome: 2800.0, iconName: 'electric_car'),
            SideBusinessUpgradeModel(id: 'sb_8_u2', title: 'DC 180kW Ultra Hızlı Supercharger', description: '20 dakikada %80 şarj sağlayan sıvı soğutmalı yüksek voltajlı şarj üniteleri.', cost: 220000.0, bonusDailyIncome: 5500.0, iconName: 'bolt'),
            SideBusinessUpgradeModel(id: 'sb_8_u3', title: 'Güneş Panelli Depolama Çatısı', description: 'İstasyon çatısına kurulan solar panellerle elektrik maliyetini sıfırlama.', cost: 360000.0, bonusDailyIncome: 9500.0, iconName: 'solar_power'),
            SideBusinessUpgradeModel(id: 'sb_8_u4', title: 'Batarya Sağlık Ölçüm & Değişim Merkezi', description: 'EV araç bataryalarının hücre bazında tamiri ve hızlı batarya takas istasyonu.', cost: 550000.0, bonusDailyIncome: 15000.0, iconName: 'battery_charging_full'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_9',
          name: 'Kurumsal Oto Ekspertiz Bayii',
          description: 'Noter onaylı, garantili ekspertiz raporları ve ekspertiz sigortası ile alım-satım işlemlerine tam güven sağla.',
          type: SideBusinessType.corporateExpertise,
          dailyIncome: 7500.0,
          cost: 150000.0,
          managerTitle: 'Ekspertiz Şube Müdürü Erhan Bey',
          managerCost: 35000.0,
          managerSalary: 300.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_9_u1', title: 'Lazer Şase Ölçüm Çatısı', description: 'Şase eğriliklerini 0.1 mm hassasiyetle tespit eden lazer rampa.', cost: 45000.0, bonusDailyIncome: 1800.0, iconName: 'precision_manufacturing'),
            SideBusinessUpgradeModel(id: 'sb_9_u2', title: 'Noter & Sigorta Entegrasyon Lisansı', description: 'Devir işlemlerinde anında noter onaylı dijital rapor üretimi.', cost: 80000.0, bonusDailyIncome: 3500.0, iconName: 'verified'),
            SideBusinessUpgradeModel(id: 'sb_9_u3', title: 'Ağır Vasıta & Ticari Dyno Testi', description: 'Kamyonet ve ticari filolar için yüksek torklu ekspertiz peronu.', cost: 140000.0, bonusDailyIncome: 6200.0, iconName: 'speed'),
            SideBusinessUpgradeModel(id: 'sb_9_u4', title: 'Garantili Ekspertiz Kasko Sigortası', description: 'Raporlanan araçlara 1 yıl 50.000 km mekanik garanti teminatı.', cost: 220000.0, bonusDailyIncome: 10500.0, iconName: 'shield'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_10',
          name: 'Oto Yedek Parça & Depo Merkezi',
          description: 'Orijinal OEM ve muadil yedek parça satışı, toptan sanayi dağıtımı ve e-ticaret lojistiği.',
          type: SideBusinessType.sparePartsStore,
          dailyIncome: 13000.0,
          cost: 250000.0,
          managerTitle: 'Depo & Lojistik Müdürü Selim Bey',
          managerCost: 50000.0,
          managerSalary: 450.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_10_u1', title: 'Otomatik Dikey Depo Raf Sistemi', description: 'Parça arama süresini 5 saniyeye indiren akıllı robotik raf alanı.', cost: 75000.0, bonusDailyIncome: 3200.0, iconName: 'inventory_2'),
            SideBusinessUpgradeModel(id: 'sb_10_u2', title: 'B2B Sanayi Dağıtım Filosu', description: 'Şehirdeki tüm tamirhanelere günlük düzenli yedek parça servisi.', cost: 130000.0, bonusDailyIncome: 6000.0, iconName: 'local_shipping'),
            SideBusinessUpgradeModel(id: 'sb_10_u3', title: 'Almanya & Japonya İthalat Lisansı', description: 'Doğrudan üreticiden parça ithal ederek kâr marjını 2 katına çıkar.', cost: 220000.0, bonusDailyIncome: 11000.0, iconName: 'flight_takeoff'),
            SideBusinessUpgradeModel(id: 'sb_10_u4', title: 'Oto Parça E-Ticaret & Pazaryeri Entegrasyonu', description: 'İnternet üzerinden tüm Türkiye’ye dakikada 5 parça siparişi kargolama.', cost: 350000.0, bonusDailyIncome: 18000.0, iconName: 'shopping_cart'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_11',
          name: 'Lüks Araç Wrap & Folyo Stüdyosu',
          description: 'Süper spor ve lüks otomobiller için PPF şeffaf koruma folyosu, renk değişimi ve özel tasarım kaplama.',
          type: SideBusinessType.wrapStudio,
          dailyIncome: 28000.0,
          cost: 500000.0,
          managerTitle: 'Master Wrap Tasarımcısı Murat Bey',
          managerCost: 80000.0,
          managerSalary: 700.0,
          managerBonusPercent: 0.30,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_11_u1', title: 'Self-Healing TPU PPF Kaplama Seti', description: 'Çizikleri ısı ile kendi kendine onaran 200 mikron şeffaf koruma zırhı.', cost: 150000.0, bonusDailyIncome: 7000.0, iconName: 'auto_fix_high'),
            SideBusinessUpgradeModel(id: 'sb_11_u2', title: 'Mat & Krom Özel Renk Kataloğu', description: 'Ekzotik mat, buzağı ve bukalemun renk değişim folyoları stantı.', cost: 260000.0, bonusDailyIncome: 13000.0, iconName: 'palette'),
            SideBusinessUpgradeModel(id: 'sb_11_u3', title: 'İklim Kontrollü Tozsuz Steril Kabin', description: 'Sıfır toz garantisiyle kusursuz folyo kaplama yapılan özel hava kabini.', cost: 420000.0, bonusDailyIncome: 22000.0, iconName: 'air'),
            SideBusinessUpgradeModel(id: 'sb_11_u4', title: 'Karbon Fiber & Aerodinamik Body Kit Stüdyosu', description: 'Gerçek kuru karbon kaput, kanat ve aero parçaları montaj alanı.', cost: 650000.0, bonusDailyIncome: 35000.0, iconName: 'sports_motorsports'),
          ],
        ),
      ],
      marketStocks: [
        StockModel(symbol: 'TOF', name: 'Tof-AŞ Otomotiv', currentPrice: 15.4, previousPrice: 15.0),
        StockModel(symbol: 'FOR', name: 'For-D Motor', currentPrice: 85.2, previousPrice: 84.5),
        StockModel(symbol: 'RNO', name: 'Reno-L Otomotiv', currentPrice: 42.1, previousPrice: 43.0),
        StockModel(symbol: 'PET', name: 'Pet-Kim Akaryakıt & Kimya', currentPrice: 28.6, previousPrice: 27.9),
        StockModel(symbol: 'TOG', name: 'Togg Elektrikli Otomobil', currentPrice: 110.5, previousPrice: 108.0),
      ],
      ownedStocks: const [],
      recentEvents: const [],
      dailyTaxRate: 150.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'level': level,
      'maxGarageSlots': maxGarageSlots,
      'ownedCars': ownedCars.map((c) => c.toJson()).toList(),
      'incomingOffers': incomingOffers.map((o) => o.toJson()).toList(),
      'totalProfit': totalProfit,
      'carsSold': carsSold,
      'lastActiveTime': lastActiveTime.toIso8601String(),
      'skills': skills.toJson(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'loginStreak': loginStreak,
      'lastLoginDate': lastLoginDate.toIso8601String(),
      'activeMissions': activeMissions.map((m) => m.toJson()).toList(),
      'marketTrend': marketTrend.toJson(),
      'reputationScore': reputationScore,
      'activeLoans': activeLoans.map((l) => l.toJson()).toList(),
      'pendingOrders': pendingOrders.map((p) => p.toJson()).toList(),
      'hiredStaff': hiredStaff.map((s) => s.toJson()).toList(),
      'customerReviews': customerReviews.map((r) => r.toJson()).toList(),
      'salesHistory': salesHistory.map((s) => s.toJson()).toList(),
      'activeCheques': activeCheques.map((c) => c.toJson()).toList(),
      'activeInstallments': activeInstallments.map((i) => i.toJson()).toList(),
      'activeRentals': activeRentals.map((r) => r.toJson()).toList(),
      'tutorialCompleted': tutorialCompleted,
      'tutorialStepIndex': tutorialStepIndex,
      'currentDay': currentDay,
      'playerName': playerName,
      'dealershipName': dealershipName,
      'logoEmblemId': logoEmblemId,
      'lastRewardClaimDate': lastRewardClaimDate?.toIso8601String(),
      'sideBusinesses': sideBusinesses.map((e) => e.toJson()).toList(),
      'marketStocks': marketStocks.map((e) => e.toJson()).toList(),
      'ownedStocks': ownedStocks.map((e) => e.toJson()).toList(),
      'recentEvents': recentEvents.map((e) => e.toJson()).toList(),
      'dailyTaxRate': dailyTaxRate,
    };
  }

  factory DealershipModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return DealershipModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 50000.0,
      level: json['level'] as int? ?? 1,
      maxGarageSlots: json['maxGarageSlots'] as int? ?? 4,
      ownedCars: (json['ownedCars'] as List<dynamic>?)
              ?.map((c) => CarModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      incomingOffers: (json['incomingOffers'] as List<dynamic>?)
              ?.map((o) => OfferModel.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      totalProfit: (json['totalProfit'] as num?)?.toDouble() ?? 0.0,
      carsSold: json['carsSold'] as int? ?? 0,
      lastActiveTime: DateTime.tryParse(json['lastActiveTime'] as String? ?? '') ?? now,
      skills: json['skills'] != null ? PlayerSkills.fromJson(json['skills'] as Map<String, dynamic>) : PlayerSkills(),
      achievements: json['achievements'] != null
          ? (json['achievements'] as List<dynamic>).map((a) => AchievementItem.fromJson(a as Map<String, dynamic>)).toList()
          : PlayerAchievements.initialList,
      loginStreak: json['loginStreak'] as int? ?? 1,
      lastLoginDate: DateTime.tryParse(json['lastLoginDate'] as String? ?? '') ?? now,
      activeMissions: json['activeMissions'] != null
          ? (json['activeMissions'] as List<dynamic>).map((m) => MissionModel.fromJson(m as Map<String, dynamic>)).toList()
          : DealershipModel.initial().activeMissions,
      marketTrend: json['marketTrend'] != null
          ? MarketTrendModel.fromJson(json['marketTrend'] as Map<String, dynamic>)
          : MarketTrendModel.defaultTrend(),
      reputationScore: json['reputationScore'] as int? ?? 100,
      activeLoans: json['activeLoans'] != null
          ? (json['activeLoans'] as List<dynamic>).map((l) => LoanModel.fromJson(l as Map<String, dynamic>)).toList()
          : const [],
      pendingOrders: (json['pendingOrders'] as List<dynamic>?)
              ?.map((p) => PartOrderModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
      hiredStaff: (json['hiredStaff'] as List<dynamic>?)
              ?.map((s) => StaffModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      customerReviews: (json['customerReviews'] as List<dynamic>?)
              ?.map((r) => CustomerReviewModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
      salesHistory: (json['salesHistory'] as List<dynamic>?)
              ?.map((s) => SaleRecordModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      activeCheques: (json['activeCheques'] as List<dynamic>?)
              ?.map((c) => Cheque.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      activeInstallments: (json['activeInstallments'] as List<dynamic>?)
              ?.map((i) => InstallmentContract.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      activeRentals: (json['activeRentals'] as List<dynamic>?)
              ?.map((r) => RentalAgreement.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
      tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
      tutorialStepIndex: json['tutorialStepIndex'] as int? ?? 0,
      currentDay: json['currentDay'] as int? ?? 1,
      playerName: json['playerName'] as String? ?? 'Kaptan',
      dealershipName: json['dealershipName'] as String? ?? 'Miras Oto Galeri',
      logoEmblemId: json['logoEmblemId'] as String? ?? 'crown',
      lastRewardClaimDate: json['lastRewardClaimDate'] != null ? DateTime.tryParse(json['lastRewardClaimDate'] as String) : null,
      sideBusinesses: (json['sideBusinesses'] as List<dynamic>?)
              ?.map((e) => SideBusinessModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      marketStocks: (json['marketStocks'] as List<dynamic>?)
              ?.map((e) => StockModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          DealershipModel.initial().marketStocks,
      ownedStocks: (json['ownedStocks'] as List<dynamic>?)
              ?.map((e) => PlayerStockModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentEvents: (json['recentEvents'] as List<dynamic>?)
              ?.map((e) => GameEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dailyTaxRate: (json['dailyTaxRate'] as num?)?.toDouble() ?? 150.0,
    );
  }

  DealershipModel copyWith({
    double? balance,
    int? level,
    int? maxGarageSlots,
    List<CarModel>? ownedCars,
    List<OfferModel>? incomingOffers,
    double? totalProfit,
    int? carsSold,
    DateTime? lastActiveTime,
    PlayerSkills? skills,
    List<AchievementItem>? achievements,
    int? loginStreak,
    DateTime? lastLoginDate,
    List<MissionModel>? activeMissions,
    MarketTrendModel? marketTrend,
    int? reputationScore,
    List<LoanModel>? activeLoans,
    List<PartOrderModel>? pendingOrders,
    List<StaffModel>? hiredStaff,
    List<CustomerReviewModel>? customerReviews,
    List<SaleRecordModel>? salesHistory,
    List<Cheque>? activeCheques,
    List<InstallmentContract>? activeInstallments,
    List<RentalAgreement>? activeRentals,
    bool? tutorialCompleted,
    int? tutorialStepIndex,
    int? currentDay,
    String? playerName,
    String? dealershipName,
    String? logoEmblemId,
    DateTime? lastRewardClaimDate,
    List<SideBusinessModel>? sideBusinesses,
    List<StockModel>? marketStocks,
    List<PlayerStockModel>? ownedStocks,
    List<GameEventModel>? recentEvents,
    double? dailyTaxRate,
  }) {
    return DealershipModel(
      balance: balance ?? this.balance,
      level: level ?? this.level,
      maxGarageSlots: maxGarageSlots ?? this.maxGarageSlots,
      ownedCars: ownedCars ?? this.ownedCars,
      incomingOffers: incomingOffers ?? this.incomingOffers,
      totalProfit: totalProfit ?? this.totalProfit,
      carsSold: carsSold ?? this.carsSold,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      skills: skills ?? this.skills,
      achievements: achievements ?? this.achievements,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      activeMissions: activeMissions ?? this.activeMissions,
      marketTrend: marketTrend ?? this.marketTrend,
      reputationScore: reputationScore ?? this.reputationScore,
      activeLoans: activeLoans ?? this.activeLoans,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      hiredStaff: hiredStaff ?? this.hiredStaff,
      customerReviews: customerReviews ?? this.customerReviews,
      salesHistory: salesHistory ?? this.salesHistory,
      activeCheques: activeCheques ?? this.activeCheques,
      activeInstallments: activeInstallments ?? this.activeInstallments,
      activeRentals: activeRentals ?? this.activeRentals,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      tutorialStepIndex: tutorialStepIndex ?? this.tutorialStepIndex,
      currentDay: currentDay ?? this.currentDay,
      playerName: playerName ?? this.playerName,
      dealershipName: dealershipName ?? this.dealershipName,
      logoEmblemId: logoEmblemId ?? this.logoEmblemId,
      lastRewardClaimDate: lastRewardClaimDate ?? this.lastRewardClaimDate,
      sideBusinesses: sideBusinesses ?? this.sideBusinesses,
      marketStocks: marketStocks ?? this.marketStocks,
      ownedStocks: ownedStocks ?? this.ownedStocks,
      recentEvents: recentEvents ?? this.recentEvents,
      dailyTaxRate: dailyTaxRate ?? this.dailyTaxRate,
    );
  }
}
