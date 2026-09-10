import '../../data/models/dealership_model.dart';
import '../../data/models/podium_reward_model.dart';

/// Engine managing weekly seasons, turnover epoch resets, and podium award settlement.
class SeasonEngine {
  /// Computes a standard ISO year-week ID, e.g., 202636 for week 36 of 2026.
  static int getSeasonId([DateTime? date]) {
    final d = (date ?? DateTime.now()).toUtc();
    final dayOfWeek = d.weekday; // 1 = Monday, 7 = Sunday
    // Find nearest Thursday:
    final thursday = d.add(Duration(days: 4 - dayOfWeek));
    final year = thursday.year;
    final firstDayOfYear = DateTime.utc(year, 1, 1);
    final dayOfYear = thursday.difference(firstDayOfYear).inDays + 1;
    final weekNumber = ((dayOfYear - 1) / 7).floor() + 1;
    return (year * 100) + weekNumber;
  }

  /// Calculates the start of the current week (Monday 00:00:00 UTC).
  static DateTime getSeasonStartAt([DateTime? date]) {
    final d = (date ?? DateTime.now()).toUtc();
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return DateTime.utc(monday.year, monday.month, monday.day);
  }

  /// Calculates the end of the current week (Sunday 23:59:59.999 UTC).
  static DateTime getSeasonEndAt([DateTime? date]) {
    final start = getSeasonStartAt(date);
    return start.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
  }

  /// Returns remaining time until the end of the current season.
  static Duration getTimeRemainingInSeason([DateTime? date]) {
    final now = (date ?? DateTime.now()).toUtc();
    final end = getSeasonEndAt(now);
    final diff = end.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Formats remaining time into a localized/readable string, e.g. "4G • 12S • 30D"
  static String formatRemainingTime(Duration duration) {
    if (duration.inSeconds <= 0) return '0D';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    if (days > 0) {
      return '$days G • $hours S';
    } else if (hours > 0) {
      return '$hours S • $minutes D';
    } else {
      return '$minutes D';
    }
  }

  /// Generates the active perks granted to a podium winner for 7 days.
  static ActivePodiumPerks generatePodiumPerks({
    required int rank,
    required int seasonId,
    DateTime? now,
  }) {
    final currentTime = (now ?? DateTime.now()).toUtc();
    final expiry = currentTime.add(const Duration(days: 7));

    switch (rank) {
      case 1:
        return ActivePodiumPerks(
          seasonId: seasonId,
          rank: 1,
          expiresAt: expiry,
          notaryDiscountRate: 0.50,
          hasCustomsAuctionPass: true,
          hasGulfBuyerNetwork: true,
          customPlateTitle: '34 KRAL 01',
        );
      case 2:
        return ActivePodiumPerks(
          seasonId: seasonId,
          rank: 2,
          expiresAt: expiry,
          notaryDiscountRate: 0.30,
          hasFleetLiquidationProtocol: true,
          hasInspectionTransparency: true,
          customPlateTitle: '06 USTA 02',
        );
      case 3:
        return ActivePodiumPerks(
          seasonId: seasonId,
          rank: 3,
          expiresAt: expiry,
          notaryDiscountRate: 0.15,
          hasMasterMechanicVoucher: true,
          hasShowcaseBoost: true,
          customPlateTitle: '35 ESNAF 03',
        );
      default:
        // Rank 4..10
        return ActivePodiumPerks(
          seasonId: seasonId,
          rank: rank,
          expiresAt: expiry,
          freeNoterVouchers: 2,
        );
    }
  }

  /// Creates a permanent trophy if rank is 1, 2, or 3.
  static PodiumTrophy? createPodiumTrophy({
    required int rank,
    required int seasonId,
    DateTime? earnedAt,
  }) {
    if (rank < 1 || rank > 3) return null;
    return PodiumTrophy(
      id: 'trophy_${seasonId}_rank$rank',
      seasonId: seasonId,
      rank: rank,
      titleKey: 'podium_trophy_title_$rank',
      earnedAt: (earnedAt ?? DateTime.now()).toUtc(),
    );
  }

  /// Checks whether the dealership has not yet been initialized with a season ID.
  static bool needsSeasonInit(DealershipModel dealership) {
    return dealership.currentSeasonId == 0;
  }

  /// Determines if the dealership's current season needs to be closed and rolled over.
  static bool shouldSettleSeason(DealershipModel dealership, [DateTime? now]) {
    if (dealership.currentSeasonId == 0) return false;
    final currentEpochSeason = getSeasonId(now);
    return dealership.currentSeasonId < currentEpochSeason;
  }
}
