import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class SideBusinessDetailSheet extends ConsumerWidget {
  final String businessId;

  const SideBusinessDetailSheet({super.key, required this.businessId});

  IconData _getUpgradeIconData(String iconName) {
    switch (iconName) {
      case 'coffee':
        return Icons.coffee_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'precision_manufacturing':
        return Icons.precision_manufacturing_rounded;
      case 'clean_hands':
        return Icons.clean_hands_rounded;
      case 'tv':
        return Icons.tv_rounded;
      case 'wb_incandescent':
        return Icons.wb_incandescent_rounded;
      case 'handshake':
        return Icons.handshake_rounded;
      case 'minor_crash':
        return Icons.minor_crash_rounded;
      case 'emergency':
        return Icons.emergency_rounded;
      case 'fire_truck':
        return Icons.fire_truck_rounded;
      case 'sanitizer':
        return Icons.sanitizer_rounded;
      case 'speed':
        return Icons.speed_rounded;
      case 'tire_repair':
        return Icons.tire_repair_rounded;
      case 'local_shipping':
        return Icons.local_shipping_rounded;
      case 'build_circle':
        return Icons.build_circle_rounded;
      case 'memory':
        return Icons.memory_rounded;
      case 'center_focus_strong':
        return Icons.center_focus_strong_rounded;
      case 'flight_land':
        return Icons.flight_land_rounded;
      case 'airline_seat_recline_extra':
        return Icons.airline_seat_recline_extra_rounded;
      case 'business_center':
        return Icons.business_center_rounded;
      case 'phone_android':
        return Icons.phone_android_rounded;
      case 'electric_car':
        return Icons.electric_car_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'solar_power':
        return Icons.solar_power_rounded;
      case 'battery_charging_full':
        return Icons.battery_charging_full_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'alt_route':
        return Icons.alt_route_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);

    final businessIndex = game.sideBusinesses.indexWhere((b) => b.id == businessId);
    if (businessIndex == -1) return const SizedBox.shrink();

    final business = game.sideBusinesses[businessIndex];
    final nextLevelCost = business.nextLevelUpgradeCost;
    final isMaxLevel = business.level >= 5;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            width: 2.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Header Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name.toUpperCase(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dükkan Seviyesi: Lvl ${business.level} • ${business.purchasedUpgradeCount}/${business.upgrades.length} Modül Aktif',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ROI Analytics Card
              NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderRadius: 14,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Net Günlük Kâr', CurrencyFormatter.formatShort(business.effectiveDailyIncome), AppColors.brutalGreen),
                        Container(width: 1.5, height: 32, color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0)),
                        _buildStatColumn('Biriken Kazanç', CurrencyFormatter.formatShort(business.totalEarned), AppColors.brutalYellow),
                        Container(width: 1.5, height: 32, color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0)),
                        _buildStatColumn('Amorti', '${business.roiDays} Gün', const Color(0xFF06B6D4)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toplam Sermaye Yatırımı:',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                        Text(
                          CurrencyFormatter.format(business.totalInvested),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.brutalYellow),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Manager Card
              Text(
                'İŞLETME MÜDÜRÜ ATAMA',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: business.hasManager ? AppColors.brutalGreen : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                borderRadius: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: business.hasManager ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: Icon(Icons.badge_rounded, color: business.hasManager ? Colors.black : const Color(0xFF64748B), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                business.managerTitle,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 6),
                              NeoBrutalBadge(
                                text: '+%${(business.managerBonusPercent * 100).toInt()}',
                                backgroundColor: AppColors.brutalYellow,
                                textColor: Colors.black,
                                fontSize: 9.5,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            business.hasManager
                                ? 'Müdür atandı. Günlük Maaş: ${business.managerSalary.toInt()}'
                                : 'İşletmenin başına müdür atayarak geliri %30 artırın.',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (business.hasManager)
                      const NeoBrutalBadge(
                        text: 'GÖREVDE',
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        fontSize: 10,
                      )
                    else
                      NeoBrutalButton(
                        label: 'İŞE AL (${CurrencyFormatter.formatShort(business.managerCost)})',
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        onPressed: () {
                          final success = ref.read(gameProvider.notifier).hireSideBusinessManager(business.id);
                          if (success) {
                            NotificationService.showSuccess(context, '${business.managerTitle} işe alındı!');
                          } else {
                            NotificationService.showError(context, 'Yetersiz Sermaye!');
                          }
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Level Up Business
              Text(
                'DÜKKAN KAPASİTE YÜKSELTME',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderRadius: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.brutalYellow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMaxLevel ? 'Maksimum Seviye (Lvl 5)' : 'Seviye ${business.level + 1} Genişletme',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isMaxLevel ? 'İşletme en yüksek kapasitede.' : 'Baz geliri +%35 artırır.',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    if (isMaxLevel)
                      const NeoBrutalBadge(
                        text: 'MAX LVL',
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 10,
                      )
                    else
                      NeoBrutalButton(
                        label: 'GELİŞTİR (${CurrencyFormatter.formatShort(nextLevelCost)})',
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        onPressed: () {
                          final success = ref.read(gameProvider.notifier).upgradeSideBusiness(business.id);
                          if (success) {
                            NotificationService.showSuccess(context, '${business.name} Seviye ${business.level + 1} oldu!');
                          } else {
                            NotificationService.showError(context, 'Yetersiz Sermaye!');
                          }
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Modules List
              Text(
                'DÜKKAN MODÜL & EKİPMANLARI (${business.purchasedUpgradeCount}/${business.upgrades.length})',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              ...business.upgrades.map((upgrade) {
                final isPurchased = upgrade.isPurchased;
                final iconData = _getUpgradeIconData(upgrade.iconName);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isPurchased ? AppColors.brutalGreen : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                    borderRadius: 10,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isPurchased ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: Icon(iconData, color: isPurchased ? Colors.black : const Color(0xFF64748B), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      upgrade.title,
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                  Text(
                                    '+${CurrencyFormatter.formatShort(upgrade.bonusDailyIncome)}/g',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                upgrade.description,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isPurchased)
                          const NeoBrutalBadge(
                            text: 'AKTİF',
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 9.5,
                          )
                        else
                          NeoBrutalButton(
                            label: CurrencyFormatter.formatShort(upgrade.cost),
                            backgroundColor: const Color(0xFFA855F7),
                            textColor: Colors.white,
                            fontSize: 10.5,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            onPressed: () {
                              final success = ref.read(gameProvider.notifier).buySideBusinessUpgrade(business.id, upgrade.id);
                              if (success) {
                                NotificationService.showSuccess(context, '${upgrade.title} modülü satın alındı!');
                              } else {
                                NotificationService.showError(context, 'Yetersiz Bakiye!');
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
      ],
    );
  }
}
