class BranchModel {
  final String id;
  final String name;
  final String locationName;
  final double requiredBalance;
  final int maxGarageSlots;
  final double profitMultiplier;
  final String vectorIcon;
  final bool isUnlocked;

  BranchModel({
    required this.id,
    required this.name,
    required this.locationName,
    required this.requiredBalance,
    required this.maxGarageSlots,
    required this.profitMultiplier,
    required this.vectorIcon,
    this.isUnlocked = false,
  });

  static List<BranchModel> getAllBranches(int currentSlotCount) {
    return [
      BranchModel(
        id: 'branch_1',
        name: 'Otoyol Otopark Şubesi',
        locationName: 'E-5 Kenarı Küçük Galeri',
        requiredBalance: 0,
        maxGarageSlots: 3,
        profitMultiplier: 1.0,
        vectorIcon: 'craftsman',
        isUnlocked: true,
      ),
      BranchModel(
        id: 'branch_2',
        name: 'Oto Galericiler Sitesi',
        locationName: 'İkitelli Oto Center',
        requiredBalance: 1500000,
        maxGarageSlots: 6,
        profitMultiplier: 1.25,
        vectorIcon: 'flash',
        isUnlocked: currentSlotCount >= 6,
      ),
      BranchModel(
        id: 'branch_3',
        name: 'Ototeknik Plaza',
        locationName: 'Maslak Otomotiv Plazası',
        requiredBalance: 5000000,
        maxGarageSlots: 10,
        profitMultiplier: 1.60,
        vectorIcon: 'shield',
        isUnlocked: currentSlotCount >= 10,
      ),
      BranchModel(
        id: 'branch_4',
        name: 'Etiler & Bodrum Showroom',
        locationName: 'Etiler Lüks Motor World',
        requiredBalance: 15000000,
        maxGarageSlots: 15,
        profitMultiplier: 2.20,
        vectorIcon: 'rare',
        isUnlocked: currentSlotCount >= 15,
      ),
    ];
  }
}
