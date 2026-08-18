import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../domain/usecases/weekly_event_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/daily_bulletin_dialog.dart';
import '../../../widgets/floating_money_overlay.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import 'dashboard_retention_modals.dart';

/// 1. Profile & Dealership Banner
class DashboardProfileBanner extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardProfileBanner({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final carsSold = game.carsSold;
    final xpInCurrent = game.skills.xpInCurrentLevel;
    final targetXp = game.skills.currentLevelTargetXp;
    final remainingXp = (targetXp - xpInCurrent).clamp(0, targetXp);
    final xpProgress = (xpInCurrent / targetXp).clamp(0.0, 1.0);
    final collectionCount = game.discoveredCarModelIds.length;

    return NeoBrutalCard(
      onTap: () => context.push('/character-growth'),
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 14,
      child: Column(
        children: [
          Row(
            children: [
              // Dealership Avatar / Logo Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: palette.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 26,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Level Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            game.dealershipName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: 'LVL ${game.level}',
                          backgroundColor: const Color(0xFFFFDE59),
                          textColor: Colors.black,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${game.playerName} • Koleksiyon: $collectionCount/30 • Satış: $carsSold Araç',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Settings Icon
              IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  size: 22,
                ),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Level Progress Bar (Goal Gradient §2.2)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 1.4,
                    ),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xpProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Seviye ${game.level + 1}\'e $remainingXp XP',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFFFFDE59) : const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Weekly Dynamic Event Banner
class DashboardWeeklyEventBanner extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardWeeklyEventBanner({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final event = WeeklyEventEngine.getEventForDay(game.currentDay);
    final dayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final dayName = dayNames[(event.dayOfWeek - 1).clamp(0, 6)];
    final IconData icon = event.dayOfWeek == 1
        ? Icons.credit_card_rounded
        : (event.dayOfWeek == 2
            ? Icons.search_rounded
            : (event.dayOfWeek == 3
                ? Icons.build_rounded
                : (event.dayOfWeek == 4
                    ? Icons.apartment_rounded
                    : (event.dayOfWeek == 5
                        ? Icons.local_fire_department_rounded
                        : (event.dayOfWeek == 6
                            ? Icons.workspace_premium_rounded
                            : Icons.auto_awesome_rounded)))));

    return NeoBrutalCard(
      onTap: () => DailyBulletinDialog.show(context),
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF191D2B) : const Color(0xFFEFF6FF),
      borderColor: const Color(0xFF3B82F6),
      borderRadius: 12,
      borderWidth: 2.0,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NeoBrutalBadge(
                      text: '${dayName.toUpperCase()} ETKİNLİĞİ',
                      backgroundColor: const Color(0xFF3B82F6),
                      textColor: Colors.white,
                      fontSize: 9,
                    ),
                    const Spacer(),
                    Text(
                      '${game.currentDay}. Gün',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// First Day Quest Guide Banner
class DashboardFirstDayQuestBanner extends StatelessWidget {
  final DealershipModel game;
  final VoidCallback onGoToShowroom;

  const DashboardFirstDayQuestBanner({
    super.key,
    required this.game,
    required this.onGoToShowroom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String questTitle;
    String questSubtitle;
    IconData questIcon;
    VoidCallback onQuestTap;

    if (game.ownedCars.isNotEmpty) {
      final hasListedCar = game.ownedCars.any((c) => c.isListed);
      if (!hasListedCar) {
        questTitle = '1. HEDEF: Dede Yadigarı Aracı Vitrine Çıkar!';
        questSubtitle = 'Showroom\'a gir, Murat 124\'e fiyat biç ve ilana koy.';
        questIcon = Icons.storefront_rounded;
        onQuestTap = onGoToShowroom;
      } else {
        questTitle = '2. HEDEF: Gelen Teklifleri İncele & İlk Satışını Yap!';
        questSubtitle = 'Showroom\'da müşterilerle pazarlık yap, kârını cebe koy.';
        questIcon = Icons.handshake_rounded;
        onQuestTap = onGoToShowroom;
      }
    } else {
      questTitle = '1. HEDEF: Pazardan İlk Kelepir Aracını Satın Al!';
      questSubtitle = 'Pazara göz at, ekspertiz raporunu incele ve ilk arabanı al.';
      questIcon = Icons.shopping_cart_rounded;
      onQuestTap = () => context.push('/marketplace');
    }

    return NeoBrutalCard(
      onTap: onQuestTap,
      padding: const EdgeInsets.all(12),
      backgroundColor: const Color(0xFFFEF3C7),
      borderColor: Colors.black,
      borderRadius: 12,
      borderWidth: 2.0,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDE59),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 2.0,
              ),
            ),
            child: Icon(questIcon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    NeoBrutalBadge(
                      text: 'BAŞLANGIÇ GÖREVİ',
                      backgroundColor: Colors.black,
                      textColor: Color(0xFFFFDE59),
                      fontSize: 9,
                    ),
                    Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Hemen Git',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.black),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  questTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  questSubtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Advisor Guidance Banner
class DashboardAdvisorGuidanceBanner extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;
  final VoidCallback onGoToShowroom;

  const DashboardAdvisorGuidanceBanner({
    super.key,
    required this.game,
    required this.palette,
    required this.onGoToShowroom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    String adviceTitle;
    String adviceSubtitle;
    IconData adviceIcon;
    VoidCallback onAdviceTap;

    final dirtyCars = game.ownedCars.where((c) => !c.isWashed || !c.isPolished).toList();
    final damagedCars = game.ownedCars.where((c) => c.expertise.engineCondition < 80 || c.expertise.transmissionCondition < 80 || c.expertise.bodyParts.values.any((s) => s == PartStatus.damaged)).toList();
    final unlistedCars = game.ownedCars.where((c) => !c.isListed).toList();
    final carsWithOffers = game.ownedCars.where((c) => game.incomingOffers.any((o) => o.carId == c.id && !o.isExpired)).toList();

    if (carsWithOffers.isNotEmpty) {
      adviceTitle = 'Müşteri Teklifleri Masada Bekliyor!';
      adviceSubtitle = '${carsWithOffers.length} araç için yeni alıcı teklifleri var. Showroom\'da pazarlığa otur.';
      adviceIcon = Icons.handshake_rounded;
      onAdviceTap = onGoToShowroom;
    } else if (game.ownedCars.isEmpty) {
      adviceTitle = 'Galerin Boş Kaldı!';
      adviceSubtitle = 'İkinci El Pazarından kelepir araç bak, stoğunu güçlendir.';
      adviceIcon = Icons.shopping_cart_rounded;
      onAdviceTap = () => context.push('/marketplace');
    } else if (dirtyCars.isNotEmpty) {
      if (game.isFeatureUnlocked('/car-wash')) {
        adviceTitle = '${dirtyCars.length} Araç Yıkama Bekliyor!';
        adviceSubtitle = 'Kirli araçlar satış hızını düşürür. Oto Yıkama\'da parlat ve vitrine koy.';
        adviceIcon = Icons.local_car_wash_rounded;
        onAdviceTap = () => context.push('/car-wash');
      } else {
        adviceTitle = 'Şubeni Büyüt, Yıkamayı Aç!';
        adviceSubtitle = 'Seviye 2 Mahalle Galerisi açarak Oto Yıkama istasyonu kurabilirsin.';
        adviceIcon = Icons.store_rounded;
        onAdviceTap = () => context.push('/branches');
      }
    } else if (damagedCars.isNotEmpty) {
      if (game.isFeatureUnlocked('/workshop')) {
        adviceTitle = 'Atölyede Onarım Fırsatı!';
        adviceSubtitle = '${damagedCars.length} aracın motor/kaporta masrafı var. Sanayide toparlayıp kâr marjını katla.';
        adviceIcon = Icons.build_circle_rounded;
        onAdviceTap = () => context.push('/workshop');
      } else {
        adviceTitle = 'Sanayi Şubesini Aç & Onar!';
        adviceSubtitle = 'Hasarlı araçları tamir etmek için Seviye 3 Sanayi Sitesi şubesine geçmelisin.';
        adviceIcon = Icons.build_circle_rounded;
        onAdviceTap = () => context.push('/branches');
      }
    } else if (unlistedCars.isNotEmpty) {
      adviceTitle = '${unlistedCars.length} Araç İlanda Değil!';
      adviceSubtitle = 'Showroom\'a gir, araçlarına fiyat biç ve ilana aç.';
      adviceIcon = Icons.storefront_rounded;
      onAdviceTap = onGoToShowroom;
    } else {
      adviceTitle = 'Pazar Hareketli, İşler Yolunda!';
      adviceSubtitle = 'Piyasa trendlerini takip et, VIP siparişleri tamamla veya personele yatırım yap.';
      adviceIcon = Icons.trending_up_rounded;
      onAdviceTap = () => context.push('/marketplace');
    }

    return NeoBrutalCard(
      onTap: onAdviceTap,
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF19231D) : const Color(0xFFECFDF5),
      borderColor: const Color(0xFF10B981),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(adviceIcon, color: Colors.black, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    NeoBrutalBadge(
                      text: 'DANIŞMAN TAVSİYESİ',
                      backgroundColor: Color(0xFF10B981),
                      textColor: Colors.black,
                      fontSize: 8.5,
                    ),
                    Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'İncele',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF10B981)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  adviceTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  adviceSubtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Emergency Rescue Banner (Bailout / Scrapyard gig)
class DashboardEmergencyRescueBanner extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardEmergencyRescueBanner({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;
    final totalOwnedValue = game.ownedCars.fold<double>(
      0.0,
      (sum, c) => sum + c.estimatedRealValue,
    );
    final totalAssets = game.balance + game.bankDepositBalance + totalOwnedValue;
    final canClaimBailout = totalAssets <= 15000;

    final bool canWorkGig = game.lastScrapyardGigDate == null ||
        DateTime.now().difference(game.lastScrapyardGigDate!).inHours >= 20;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF261818) : const Color(0xFFFEF2F2),
      borderColor: const Color(0xFFEF4444),
      borderRadius: 12,
      borderWidth: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
              const SizedBox(width: 8),
              Text(
                'ACİL DURUM & NAKİT DESTEĞİ',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Kasadaki nakit kritik seviyeye düştü (₺${CurrencyFormatter.formatShort(game.balance)}). Gelir yaratmak için aşağıdaki acil durum eylemlerini kullanabilirsin.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF7F1D1D),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 1. Scrapyard Gig
              Expanded(
                child: NeoBrutalButton(
                  label: canWorkGig ? 'Hurdalık Çıraklığı (+₺5.000)' : 'Çıraklık (Tamamlandı)',
                  icon: canWorkGig ? Icons.handyman_rounded : Icons.check_circle_rounded,
                  backgroundColor: canWorkGig
                      ? const Color(0xFFFFDE59)
                      : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                  textColor: canWorkGig ? Colors.black : (isDark ? Colors.white54 : Colors.black54),
                  fontSize: 10.5,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  onPressed: canWorkGig
                      ? () {
                          final success = ref.read(gameProvider.notifier).workScrapyardSideGig();
                          if (success) {
                            FloatingMoneyOverlay.of(context)?.showMoneyPopUp(5000, label: 'Çıraklık Yevmiyesi!');
                            NotificationService.showSuccess(
                              context,
                              'Hurdalıkta akşama kadar çıraklık yaptın. ₺5.000 yevmiye kasana girdi!',
                            );
                          } else {
                            NotificationService.showWarning(context, 'Bugün zaten çıraklık yaptın! Yarın tekrar gel.');
                          }
                        }
                      : null,
                ),
              ),
              if (canClaimBailout) ...[
                const SizedBox(width: 8),
                // 2. Emergency Bailout (Dede Mirası)
                Expanded(
                  child: NeoBrutalButton(
                    label: 'Dede Mirası (+₺50.000)',
                    icon: Icons.volunteer_activism_rounded,
                    backgroundColor: const Color(0xFF00E575),
                    textColor: Colors.black,
                    fontSize: 10.5,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    onPressed: () {
                      final success = ref.read(gameProvider.notifier).claimEmergencyBailout();
                      if (success) {
                        FloatingMoneyOverlay.of(context)?.showMoneyPopUp(50000, label: 'Can Suyu Mirası!');
                        NotificationService.showSuccess(
                          context,
                          'Aile büyüklerinden gelen ₺50.000 can suyu desteği kasana eklendi!',
                        );
                      } else {
                        NotificationService.showWarning(context, 'Mevcut varlıkların ₺15.000 üzerinde olduğu için can suyu onaylanmadı.');
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Retention Highlights Row (Leaderboard, Album, Prestige)
class DashboardRetentionHighlightsRow extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;
  final WidgetRef ref;

  const DashboardRetentionHighlightsRow({
    super.key,
    required this.game,
    required this.palette,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final discoveredCount = game.discoveredCarModelIds.length;
    final canPrestige = game.level >= 4 || game.totalProfit >= 3000000;

    return Row(
      children: [
        // 1. Rivals Leaderboard
        Expanded(
          child: NeoBrutalCard(
            onTap: () => DashboardRetentionModals.showRivalLeaderboardModal(context, game),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE59),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.leaderboard_rounded, color: Colors.black, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ŞEHİR LİGİ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '5 Rakip Galeri',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 2. Collection Album
        Expanded(
          child: NeoBrutalCard(
            onTap: () => DashboardRetentionModals.showCollectionAlbumModal(context, game),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALBÜM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '$discoveredCount/30 Araç',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA855F7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Prestige (If unlocked)
        if (canPrestige) ...[
          const SizedBox(width: 8),
          Expanded(
            child: NeoBrutalCard(
              onTap: () => DashboardRetentionModals.showPrestigeModal(context, game, ref),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              backgroundColor: const Color(0xFFFFDE59),
              borderColor: Colors.black,
              borderRadius: 10,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Color(0xFFFFDE59), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEVRET',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Text(
                          'Yeni Sezon',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Daily Streak Reward Claim Banner
class DashboardDailyStreakBanner extends ConsumerWidget {
  final DealershipModel game;

  const DashboardDailyStreakBanner({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    if (game.lastRewardClaimDate != null) {
      final lastClaim = game.lastRewardClaimDate!;
      if (lastClaim.year == now.year && lastClaim.month == now.month && lastClaim.day == now.day) {
        return const SizedBox.shrink();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFFFFDE59),
        borderColor: const Color(0xFF0F172A),
        borderRadius: 12,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF7A00),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${game.loginStreak} Günlük Giriş Serisi!',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Bugünün bonus ödülünü hemen kasana ekle.',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            NeoBrutalButton(
              label: 'TOPLA',
              icon: Icons.attach_money_rounded,
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              borderColor: const Color(0xFF0F172A),
              fontSize: 11.5,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onPressed: () {
                final reward = ref.read(gameProvider.notifier).claimDailyStreak();
                FloatingMoneyOverlay.of(context)?.showMoneyPopUp(reward.toDouble(), label: 'Seri Ödülü!');
                NotificationService.showSuccess(
                  context,
                  '${CurrencyFormatter.formatShort(reward.toDouble())} Günlük Seri Ödülü Hesabına Eklendi!',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Estimated Daily Cash Flow Breakdown Card
class DashboardDailyCashFlowCard extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardDailyCashFlowCard({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final dailyPassiveIncome = game.sideBusinesses.where((b) => b.isOwned).fold<double>(
      0.0,
      (sum, b) => sum + b.grossDailyIncome,
    );
    final dailySalaries = game.hiredStaff.fold<double>(
      0.0,
      (sum, s) => sum + (s.dailySalary),
    );
    final dailyLoanPayment = game.activeLoans.fold<double>(
      0.0,
      (sum, l) => sum + (l.monthlyPayment),
    );
    final netDailyFlow = dailyPassiveIncome - dailySalaries - dailyLoanPayment;

    return NeoBrutalCard(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/finance/daily-cashflow');
      },
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GÜNLÜK NET NAKİT AKIŞI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${netDailyFlow >= 0 ? '+' : ''}${CurrencyFormatter.formatShort(netDailyFlow)}/gün',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: netDailyFlow >= 0 ? const Color(0xFF00E575) : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yan Gelirler: +${CurrencyFormatter.formatShort(dailyPassiveIncome)}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00E575)),
              ),
              Text(
                'Maaşlar: -${CurrencyFormatter.formatShort(dailySalaries)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              if (dailyLoanPayment > 0)
                Text(
                  'Krediler: -${CurrencyFormatter.formatShort(dailyLoanPayment)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
