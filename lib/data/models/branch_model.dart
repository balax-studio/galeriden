import 'package:flutter/widgets.dart';
import '../../core/localization/app_localizations.dart';

class BranchModel {
  final String id;
  final String name;
  final String locationName;
  final double requiredBalance;
  final double dailyBurnRate;
  final int maxGarageSlots;
  final int targetLevel;
  final double profitMultiplier;
  final String vectorIcon;
  final String unlockedSummary;
  final bool isUnlocked;
  final double deedCost;
  final bool isDeedOwned;

  BranchModel({
    required this.id,
    required this.name,
    required this.locationName,
    required this.requiredBalance,
    required this.dailyBurnRate,
    required this.maxGarageSlots,
    required this.targetLevel,
    required this.profitMultiplier,
    required this.vectorIcon,
    required this.unlockedSummary,
    this.isUnlocked = false,
    required this.deedCost,
    this.isDeedOwned = false,
  });

  String getLocalizedName(BuildContext context) => context.tr('${id}_name');
  String getLocalizedLocation(BuildContext context) =>
      context.tr('${id}_location');
  String getLocalizedSummary(BuildContext context) =>
      context.tr('${id}_summary');

  static List<BranchModel> getAllBranches({
    int currentSlotCount = 3,
    int currentLevel = 1,
    Set<String> unlockedBuildings = const {},
    Set<String> ownedDeeds = const {},
  }) {
    return [
      BranchModel(
        id: 'branch_1',
        name: 'Kaldırım Başı Ayakçı Galerisi',
        locationName: 'Sokak Başı Alım-Satım Noktası',
        requiredBalance: 0,
        dailyBurnRate: ownedDeeds.contains('branch_1') ? 0.0 : 300.0,
        maxGarageSlots: 3,
        targetLevel: 1,
        profitMultiplier: 1.0,
        vectorIcon: 'craftsman',
        unlockedSummary: 'İkinci El Pazarı, Showroom Vitrini, Ekspertiz',
        isUnlocked: true,
        deedCost: 750000.0,
        isDeedOwned: ownedDeeds.contains('branch_1'),
      ),
      BranchModel(
        id: 'branch_2',
        name: 'Mahalle Tipi Açık Oto Galeri',
        locationName: 'Köşebaşı Park Alanı & Hizmet Kulübesi',
        requiredBalance: 100000.0,
        dailyBurnRate: ownedDeeds.contains('branch_2') ? 0.0 : 750.0,
        maxGarageSlots: 4,
        targetLevel: 2,
        profitMultiplier: 1.10,
        vectorIcon: 'car_wash',
        unlockedSummary: 'Oto Yıkama & Detailing, Hızlı İlan Servisi, Satış Geçmişi',
        isUnlocked: unlockedBuildings.contains('property_tier_2'),
        deedCost: 1800000.0,
        isDeedOwned: ownedDeeds.contains('branch_2'),
      ),
      BranchModel(
        id: 'branch_3',
        name: 'Sanayi Sitesi Esnaf Galerisi',
        locationName: 'Sanayi İçi 2 Liftli Atölye & Ofis',
        requiredBalance: 350000.0,
        dailyBurnRate: ownedDeeds.contains('branch_3') ? 0.0 : 1800.0,
        maxGarageSlots: 6,
        targetLevel: 3,
        profitMultiplier: 1.25,
        vectorIcon: 'workshop',
        unlockedSummary: 'Atölye & Tamirhane, Personel Kadrosu & Akademi',
        isUnlocked: unlockedBuildings.contains('property_tier_3'),
        deedCost: 4500000.0,
        isDeedOwned: ownedDeeds.contains('branch_3'),
      ),
      BranchModel(
        id: 'branch_4',
        name: 'Cadde Üstü Butik Oto Galeri',
        locationName: 'Ana Cadde Camlı Butik Vitrin',
        requiredBalance: 900000.0,
        dailyBurnRate: ownedDeeds.contains('branch_4') ? 0.0 : 4200.0,
        maxGarageSlots: 8,
        targetLevel: 4,
        profitMultiplier: 1.40,
        vectorIcon: 'tuning',
        unlockedSummary: 'Tuning & Modifiye Stüdyosu, Showroom Mimari Dekorasyon',
        isUnlocked: unlockedBuildings.contains('property_tier_4'),
        deedCost: 9000000.0,
        isDeedOwned: ownedDeeds.contains('branch_4'),
      ),
      BranchModel(
        id: 'branch_5',
        name: 'Oto Center Kurumsal Galeri',
        locationName: 'Oto Center İhale & Ticaret Pavyonu',
        requiredBalance: 2500000.0,
        dailyBurnRate: ownedDeeds.contains('branch_5') ? 0.0 : 9500.0,
        maxGarageSlots: 10,
        targetLevel: 5,
        profitMultiplier: 1.60,
        vectorIcon: 'auction',
        unlockedSummary: 'Canlı İhale Masası, Finans Masası & Banka Kredileri, Müşteri Yorumları',
        isUnlocked: unlockedBuildings.contains('property_tier_5'),
        deedCost: 18000000.0,
        isDeedOwned: ownedDeeds.contains('branch_5'),
      ),
      BranchModel(
        id: 'branch_6',
        name: 'Premium Cam Showroom Plaza',
        locationName: 'Modern Çelik Konstrüksiyon Plaza',
        requiredBalance: 6000000.0,
        dailyBurnRate: ownedDeeds.contains('branch_6') ? 0.0 : 20000.0,
        maxGarageSlots: 13,
        targetLevel: 6,
        profitMultiplier: 1.85,
        vectorIcon: 'shield',
        unlockedSummary: 'Borsa & Portföy Yatırımları, Banka Mevduat Fonları',
        isUnlocked: unlockedBuildings.contains('property_tier_6'),
        deedCost: 35000000.0,
        isDeedOwned: ownedDeeds.contains('branch_6'),
      ),
      BranchModel(
        id: 'branch_7',
        name: 'Lüks Koleksiyoner VIP Galeri',
        locationName: 'VIP Rezervasyonlu Özel Filo Hangarı',
        requiredBalance: 14000000.0,
        dailyBurnRate: ownedDeeds.contains('branch_7') ? 0.0 : 40000.0,
        maxGarageSlots: 16,
        targetLevel: 7,
        profitMultiplier: 2.10,
        vectorIcon: 'fleet',
        unlockedSummary: 'Rent-a-Car Filosu, Karaborsa & Gece Pazarı Ağı, Semt Hakimiyeti',
        isUnlocked: unlockedBuildings.contains('property_tier_7'),
        deedCost: 70000000.0,
        isDeedOwned: ownedDeeds.contains('branch_7'),
      ),
      BranchModel(
        id: 'branch_8',
        name: 'Mega Otomotiv Holding Plazası',
        locationName: 'Gökdelen Plaza Kulesi & Heliped',
        requiredBalance: 30000000.0,
        dailyBurnRate: ownedDeeds.contains('branch_8') ? 0.0 : 75000.0,
        maxGarageSlots: 20,
        targetLevel: 8,
        profitMultiplier: 2.50,
        vectorIcon: 'rare',
        unlockedSummary: 'Hurdalık & Yedek Parça İmparatorluğu, Yan İşletmeler Holdingi, Konsinye Pazarı, İthalat & Gümrük',
        isUnlocked: unlockedBuildings.contains('property_tier_8'),
        deedCost: 150000000.0,
        isDeedOwned: ownedDeeds.contains('branch_8'),
      ),
    ];
  }
}
