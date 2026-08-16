class AlbumProgress {
  final int discoveredModelsCount;
  final int totalModelsCount;
  final int discoveredColorsCount;
  final int discoveredPlatesCount;
  final int discoveredBarnFindsCount;
  final double completionPercentage;

  int get discoveredCount => discoveredModelsCount;
  int get totalCatalogCarsCount => totalModelsCount;

  AlbumProgress({
    required this.discoveredModelsCount,
    this.totalModelsCount = 30,
    required this.discoveredColorsCount,
    required this.discoveredPlatesCount,
    required this.discoveredBarnFindsCount,
    required this.completionPercentage,
  });
}

class CollectionAlbumEngine {
  /// Computes 4-dimensional album progress statistics (§1.4)
  static AlbumProgress calculateAlbumProgress({
    required List<String> discoveredCarIds,
    List<String> discoveredRareColors = const [],
    List<String> discoveredSpecialPlates = const [],
    List<String> restoredBarnFinds = const [],
    int totalCatalogCarsCount = 30,
  }) {
    final uniqueModels = discoveredCarIds.toSet().length;
    final uniqueColors = discoveredRareColors.toSet().length;
    final uniquePlates = discoveredSpecialPlates.toSet().length;
    final uniqueBarns = restoredBarnFinds.toSet().length;

    final double modelPct = totalCatalogCarsCount > 0 ? (uniqueModels / totalCatalogCarsCount) : 0.0;
    final double colorPct = uniqueColors / 10.0;
    final double platePct = uniquePlates / 15.0;
    final double barnPct = uniqueBarns / 10.0;

    final double totalScore = (uniqueColors == 0 && uniquePlates == 0 && uniqueBarns == 0)
        ? modelPct
        : (modelPct * 0.50) + (colorPct * 0.20) + (platePct * 0.15) + (barnPct * 0.15);

    return AlbumProgress(
      discoveredModelsCount: uniqueModels,
      totalModelsCount: totalCatalogCarsCount,
      discoveredColorsCount: uniqueColors,
      discoveredPlatesCount: uniquePlates,
      discoveredBarnFindsCount: uniqueBarns,
      completionPercentage: totalScore.clamp(0.0, 1.0),
    );
  }

  /// Payout bonus based on milestone count reached (§1.4)
  static int? getMilestoneReward(int discoveredCount) {
    if (discoveredCount >= 90) return 2500000;
    if (discoveredCount >= 60) return 1200000;
    if (discoveredCount >= 30) return 500000;
    if (discoveredCount >= 20) return 250000;
    if (discoveredCount >= 10) return 100000;
    if (discoveredCount >= 5) return 35000;
    if (discoveredCount >= 3) return 15000;
    return null;
  }
}
