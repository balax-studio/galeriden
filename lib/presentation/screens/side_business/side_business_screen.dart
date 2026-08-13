import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/side_business_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_double_bezel_card.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_tactile_button.dart';
import 'widgets/side_business_detail_sheet.dart';

class SideBusinessScreen extends ConsumerWidget {
  const SideBusinessScreen({super.key});

  IconData _getBusinessIcon(SideBusinessType type) {
    switch (type) {
      case SideBusinessType.vendingMachine:
        return Icons.local_cafe_rounded;
      case SideBusinessType.carWash:
        return Icons.local_car_wash_rounded;
      case SideBusinessType.billboard:
        return Icons.connected_tv_rounded;
      case SideBusinessType.towTruck:
        return Icons.fire_truck_rounded;
      case SideBusinessType.autoShop:
        return Icons.storefront_rounded;
      case SideBusinessType.inspectionStation:
        return Icons.fact_check_rounded;
      case SideBusinessType.carRental:
        return Icons.car_rental_rounded;
      case SideBusinessType.evCharging:
        return Icons.ev_station_rounded;
    }
  }

  void _openDetailSheet(BuildContext context, String businessId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SideBusinessDetailSheet(businessId: businessId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    final ownedBusinesses = game.sideBusinesses.where((b) => b.isOwned).toList();
    final totalDailyIncome = game.sideBusinesses.fold(0.0, (sum, b) => sum + b.effectiveDailyIncome);
    final totalLifetimeEarned = game.sideBusinesses.fold(0.0, (sum, b) => sum + b.totalEarned);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'YAN İŞLETMELER & DÜKKANLAR',
          style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Analytics Overview Card
            AppGlassContainer(
              padding: const EdgeInsets.all(18),
              borderColor: p.primaryColor.withValues(alpha: 0.5),
              glowColor: p.primaryColor.withValues(alpha: 0.15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.monetization_on_rounded, color: p.primaryColor, size: 28),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOPLAM PASİF GELİR', style: AppTypography.labelSmall(p.isDark)),
                              Text(
                                '₺${CurrencyFormatter.formatShort(totalDailyIncome)} / gün',
                                style: AppTypography.titleLarge(p.isDark).copyWith(color: p.successColor, fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: p.secondaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: p.secondaryColor),
                        ),
                        child: Text(
                          '${ownedBusinesses.length}/${game.sideBusinesses.length} Aktif',
                          style: TextStyle(color: p.secondaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: p.surfaceBorderColor, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Toplam Biriken Gelir:', style: AppTypography.labelSmall(p.isDark)),
                      Text(
                        '₺${CurrencyFormatter.format(totalLifetimeEarned)}',
                        style: AppTypography.moneyMedium(p.isDark).copyWith(fontSize: 14, color: p.primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('MEVCUT İŞLETME VE DÜKKAN KATALOĞU', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: game.sideBusinesses.length,
              itemBuilder: (context, index) {
                final business = game.sideBusinesses[index];
                final isOwned = business.isOwned;
                final iconData = _getBusinessIcon(business.type);

                Widget cardContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isOwned ? p.primaryColor.withValues(alpha: 0.15) : p.surfaceBorderColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                iconData,
                                color: isOwned ? p.primaryColor : p.textSecondaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(business.name, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                                if (isOwned && business.upgrades.isNotEmpty)
                                  Text(
                                    '${business.purchasedUpgradeCount}/${business.upgrades.length} Dükkan Modülü Aktif',
                                    style: TextStyle(color: p.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        if (isOwned)
                          Row(
                            children: [
                              if (business.hasManager)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: p.primaryColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: p.primaryColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.badge_rounded, size: 12, color: p.primaryColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Müdürlü',
                                        style: TextStyle(color: p.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: p.successColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: p.successColor),
                                ),
                                child: Text(
                                  'Lvl ${business.level}',
                                  style: TextStyle(color: p.successColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(business.description, style: AppTypography.bodyMedium(p.isDark)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Günlük Gelir', style: AppTypography.labelSmall(p.isDark)),
                            Text(
                              '₺${CurrencyFormatter.formatShort(isOwned ? business.effectiveDailyIncome : business.dailyIncome)}',
                              style: AppTypography.titleLarge(p.isDark).copyWith(color: isOwned ? p.successColor : p.textSecondaryColor),
                            ),
                          ],
                        ),
                        if (!isOwned)
                          AppTactileButton(
                            onPressed: () {
                              final success = ref.read(gameProvider.notifier).buySideBusiness(business.id);
                              if (success) {
                                NotificationService.showSuccess(context, '${business.name} satın alındı!');
                              } else {
                                NotificationService.showError(context, 'Yetersiz bakiye!');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: p.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.shopping_cart_rounded, size: 16, color: Colors.black),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Satın Al: ₺${CurrencyFormatter.formatShort(business.cost)}',
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          AppTactileButton(
                            onPressed: () => _openDetailSheet(context, business.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: p.secondaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.store_rounded, size: 16, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'Dükkanı Yönet & Geliştir',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: isOwned
                      ? AppDoubleBezelCard(
                          accentColor: p.primaryColor,
                          child: cardContent,
                        )
                      : AppGlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: cardContent,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
