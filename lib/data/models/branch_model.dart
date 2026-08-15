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
  });

  static List<BranchModel> getAllBranches({
    int currentSlotCount = 3,
    int currentLevel = 1,
    Set<String> unlockedBuildings = const {},
  }) {
    return [
      BranchModel(
        id: 'branch_1',
        name: 'Kaldırım Başı Sokak Garajı',
        locationName: 'Sokak & Kaldırım Otoparkı',
        requiredBalance: 0,
        dailyBurnRate: 300.0,
        maxGarageSlots: 3,
        targetLevel: 1,
        profitMultiplier: 1.0,
        vectorIcon: 'craftsman',
        unlockedSummary: 'İkinci El Pazarı, Showroom, Ekspertiz, Oto Yıkama',
        isUnlocked: true,
      ),
      BranchModel(
        id: 'branch_2',
        name: 'İkitelli Sanayi Dükkânı',
        locationName: 'Sanayi Sitesi / 2 Liftli Atölye',
        requiredBalance: 350000.0,
        dailyBurnRate: 1800.0,
        maxGarageSlots: 6,
        targetLevel: 2,
        profitMultiplier: 1.25,
        vectorIcon: 'workshop',
        unlockedSummary: 'Atölye & Tamirhane, Tuning Stüdyosu, Personel Kadrosu',
        isUnlocked: currentSlotCount >= 6 || unlockedBuildings.contains('property_tier_2'),
      ),
      BranchModel(
        id: 'branch_3',
        name: 'Maslak Otomotiv Plazası',
        locationName: 'Maslak Cam Giydirme Showroom',
        requiredBalance: 2500000.0,
        dailyBurnRate: 12000.0,
        maxGarageSlots: 10,
        targetLevel: 3,
        profitMultiplier: 1.60,
        vectorIcon: 'shield',
        unlockedSummary: 'Canlı İhale, Finans Masası, Borsa & Yatırım, Müşteri Yorumları, Mimari Dekorasyon',
        isUnlocked: currentSlotCount >= 10 || unlockedBuildings.contains('property_tier_3'),
      ),
      BranchModel(
        id: 'branch_4',
        name: 'Levent Mega Holding Plazası',
        locationName: 'Levent Gökdelen Kulesi & Heliped',
        requiredBalance: 12000000.0,
        dailyBurnRate: 50000.0,
        maxGarageSlots: 16,
        targetLevel: 4,
        profitMultiplier: 2.20,
        vectorIcon: 'rare',
        unlockedSummary: 'Hurdalık & Parça, Rent-a-Car Filosu, Karaborsa, Yan İşletmeler',
        isUnlocked: currentSlotCount >= 16 || unlockedBuildings.contains('property_tier_4'),
      ),
    ];
  }
}
