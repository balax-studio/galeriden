import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/side_business_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
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
      case SideBusinessType.corporateExpertise:
        return Icons.verified_rounded;
      case SideBusinessType.sparePartsStore:
        return Icons.inventory_2_rounded;
      case SideBusinessType.wrapStudio:
        return Icons.auto_fix_high_rounded;
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
    final isDark = p.isDark;

    final ownedBusinesses = game.sideBusinesses.where((b) => b.isOwned).toList();
    final totalDailyIncome = game.sideBusinesses.fold(0.0, (sum, b) => sum + b.effectiveDailyIncome);
    final totalLifetimeEarned = game.sideBusinesses.fold(0.0, (sum, b) => sum + b.totalEarned);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'YAN İŞLETMELER & DÜKKANLAR',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Top Analytics Overview Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brutalGreen,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(Icons.monetization_on_rounded, color: Colors.black, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOPLAM PASİF GELİR',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${CurrencyFormatter.formatShort(totalDailyIncome)} / gün',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                    NeoBrutalBadge(
                      text: '${ownedBusinesses.length}/${game.sideBusinesses.length} Aktif',
                      backgroundColor: const Color(0xFFA855F7),
                      textColor: Colors.white,
                      fontSize: 11,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Toplam Biriken Pasif Kazanç:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    Text(
                      CurrencyFormatter.format(totalLifetimeEarned),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brutalYellow),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'İŞLETME & DÜKKAN KATALOĞU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Business Catalog List
          ...game.sideBusinesses.map((business) {
            final isOwned = business.isOwned;
            final iconData = _getBusinessIcon(business.type);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isOwned ? AppColors.brutalGreen : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isOwned ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                    width: 2.0,
                                  ),
                                ),
                                child: Icon(iconData, color: isOwned ? Colors.black : const Color(0xFF64748B), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      business.name,
                                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                                    ),
                                    if (isOwned && business.upgrades.isNotEmpty)
                                      Text(
                                        '${business.purchasedUpgradeCount}/${business.upgrades.length} Dükkan Modülü Aktif',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brutalYellow),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOwned)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (business.hasManager)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: NeoBrutalBadge(
                                    text: 'Müdürlü',
                                    backgroundColor: Color(0xFF06B6D4),
                                    textColor: Colors.black,
                                    fontSize: 10,
                                  ),
                                ),
                              NeoBrutalBadge(
                                text: 'Lvl ${business.level}',
                                backgroundColor: AppColors.brutalGreen,
                                textColor: Colors.black,
                                fontSize: 10.5,
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      business.description,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GÜNLÜK GELİR',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                            ),
                            Text(
                              '${CurrencyFormatter.formatShort(isOwned ? business.effectiveDailyIncome : business.dailyIncome)} / gün',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isOwned ? AppColors.brutalGreen : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        if (!isOwned)
                          NeoBrutalButton(
                            label: 'SATIN AL (${CurrencyFormatter.formatShort(business.cost)})',
                            icon: Icons.shopping_cart_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            onPressed: () {
                              final success = ref.read(gameProvider.notifier).buySideBusiness(business.id);
                              if (success) {
                                NotificationService.showSuccess(context, '${business.name} satın alındı!');
                              } else {
                                NotificationService.showError(context, 'Yetersiz bakiye!');
                              }
                            },
                          )
                        else
                          NeoBrutalButton(
                            label: 'YÖNET & GELİŞTİR',
                            icon: Icons.store_rounded,
                            backgroundColor: const Color(0xFFA855F7),
                            textColor: Colors.white,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            onPressed: () => _openDetailSheet(context, business.id),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
