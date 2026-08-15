class AlbumProgress {
  final int discoveredCount;
  final int totalCatalogCarsCount;
  final double completionPercentage;

  AlbumProgress({
    required this.discoveredCount,
    required this.totalCatalogCarsCount,
    required this.completionPercentage,
  });
}

class CollectionAlbumEngine {
  /// Computes album progress statistics
  static AlbumProgress calculateAlbumProgress({
    required List<String> discoveredCarIds,
    int totalCatalogCarsCount = 30,
  }) {
    final uniqueCount = discoveredCarIds.toSet().length;
    final pct = totalCatalogCarsCount > 0 ? (uniqueCount / totalCatalogCarsCount) : 0.0;
    return AlbumProgress(
      discoveredCount: uniqueCount,
      totalCatalogCarsCount: totalCatalogCarsCount,
      completionPercentage: pct,
    );
  }

  /// Payout bonus based on milestone count reached (e.g. 5, 10, 20, 30 cars)
  static int? getMilestoneReward(int discoveredCount) {
    if (discoveredCount >= 30) return 500000;
    if (discoveredCount >= 20) return 250000;
    if (discoveredCount >= 10) return 100000;
    if (discoveredCount >= 5) return 35000;
    if (discoveredCount >= 3) return 15000;
    return null;
  }
}
