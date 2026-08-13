import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/app_double_bezel_card.dart';
import '../../../widgets/app_glass_container.dart';
import '../../../widgets/app_tactile_button.dart';

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
    final p = Theme.of(context).extension<AppThemeExtension>()!.palette;
    final game = ref.watch(gameProvider);

    final businessIndex = game.sideBusinesses.indexWhere((b) => b.id == businessId);
    if (businessIndex == -1) return const SizedBox.shrink();

    final business = game.sideBusinesses[businessIndex];
    final nextLevelCost = business.cost * 0.5 * business.level;

    return Container(
      decoration: BoxDecoration(
        color: p.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  height: 5,
                  decoration: BoxDecoration(
                    color: p.surfaceBorderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

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
                          style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 18, letterSpacing: 1.1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dükkan Seviyesi: Lvl ${business.level} • ${business.purchasedUpgradeCount}/${business.upgrades.length} Modül Aktif',
                          style: AppTypography.labelSmall(p.isDark),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: p.textSecondaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Performance & Financial ROI Analytics Card
              AppGlassContainer(
                padding: const EdgeInsets.all(16),
                borderColor: p.primaryColor.withValues(alpha: 0.4),
                glowColor: p.primaryColor.withValues(alpha: 0.15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Net Günlük Kâr', '₺${CurrencyFormatter.formatShort(business.effectiveDailyIncome)}', p.successColor, p.isDark),
                        Container(width: 1, height: 35, color: p.surfaceBorderColor),
                        _buildStatColumn('Biriken Kazanç', '₺${CurrencyFormatter.formatShort(business.totalEarned)}', p.primaryColor, p.isDark),
                        Container(width: 1, height: 35, color: p.surfaceBorderColor),
                        _buildStatColumn('Amorti Süresi', '${business.roiDays} Gün', p.secondaryColor, p.isDark),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: p.surfaceBorderColor, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Toplam Yapılan Sermaye Yatırımı:', style: AppTypography.labelSmall(p.isDark)),
                        Text(
                          '₺${CurrencyFormatter.format(business.totalInvested)}',
                          style: TextStyle(color: p.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dedicated Business Manager Hiring Card
              Text('ÖZEL İŞLETME MÜDÜRÜ VE AMİR ATAMA', style: AppTypography.labelSmall(p.isDark)),
              const SizedBox(height: 8),
              AppGlassContainer(
                padding: const EdgeInsets.all(14),
                borderColor: business.hasManager ? p.successColor.withValues(alpha: 0.5) : p.surfaceBorderColor,
                glowColor: business.hasManager ? p.successColor.withValues(alpha: 0.1) : null,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: business.hasManager ? p.successColor.withValues(alpha: 0.2) : p.surfaceBorderColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.badge_rounded,
                        color: business.hasManager ? p.successColor : p.textSecondaryColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                business.managerTitle,
                                style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+%${(business.managerBonusPercent * 100).toInt()} Gelir',
                                  style: TextStyle(color: p.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            business.hasManager
                                ? 'Müdür atandı. Günlük Maaş: ₺${business.managerSalary.toInt()}'
                                : 'İşletmenin başına müdür atayarak tüm pasif geliri %30 artırın.',
                            style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (business.hasManager)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: p.successColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: p.successColor),
                        ),
                        child: const Text('GÖREVDE', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                      )
                    else
                      AppTactileButton(
                        onPressed: () {
                          final success = ref.read(gameProvider.notifier).hireSideBusinessManager(business.id);
                          if (success) {
                            NotificationService.showSuccess(context, '${business.managerTitle} işe alındı!');
                          } else {
                            NotificationService.showError(context, 'Yetersiz Sermaye!');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: p.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '₺${CurrencyFormatter.formatShort(business.managerCost)}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Business Level Up Section
              Text('DÜKKAN KAPASİTE VE SEVİYE YÜKSELTME', style: AppTypography.labelSmall(p.isDark)),
              const SizedBox(height: 8),
              AppDoubleBezelCard(
                accentColor: p.primaryColor,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: p.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.bolt_rounded, color: p.primaryColor, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Seviye ${business.level + 1} İşletme Genişletme', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('Baz geliri +%40 artırır.', style: AppTypography.labelSmall(p.isDark)),
                        ],
                      ),
                    ),
                    AppTactileButton(
                      onPressed: () {
                        final success = ref.read(gameProvider.notifier).upgradeSideBusiness(business.id);
                        if (success) {
                          NotificationService.showSuccess(context, '${business.name} Seviye ${business.level + 1} oldu!');
                        } else {
                          NotificationService.showError(context, 'Yetersiz Sermaye!');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: p.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '₺${CurrencyFormatter.formatShort(nextLevelCost)}',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sub-Upgrades & Modules Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('DÜKKAN İÇİ EKİPMAN & MODÜL KATALOĞU', style: AppTypography.labelSmall(p.isDark)),
                  Text('${business.purchasedUpgradeCount}/${business.upgrades.length}', style: TextStyle(color: p.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),

              if (business.upgrades.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Bu dükkan için özel modül bulunmuyor.', style: AppTypography.bodyMedium(p.isDark)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: business.upgrades.length,
                  itemBuilder: (context, idx) {
                    final upgrade = business.upgrades[idx];
                    final isPurchased = upgrade.isPurchased;
                    final iconData = _getUpgradeIconData(upgrade.iconName);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: AppGlassContainer(
                        padding: const EdgeInsets.all(14),
                        borderColor: isPurchased ? p.successColor.withValues(alpha: 0.5) : p.surfaceBorderColor,
                        glowColor: isPurchased ? p.successColor.withValues(alpha: 0.1) : null,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isPurchased ? p.successColor.withValues(alpha: 0.2) : p.surfaceBorderColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                iconData,
                                color: isPurchased ? p.successColor : p.textSecondaryColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          upgrade.title,
                                          style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        '+₺${CurrencyFormatter.formatShort(upgrade.bonusDailyIncome)}/gün',
                                        style: TextStyle(color: p.successColor, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    upgrade.description,
                                    style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            if (isPurchased)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: p.successColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: p.successColor),
                                ),
                                child: const Text('AKTİF', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                              )
                            else
                              AppTactileButton(
                                onPressed: () {
                                  final success = ref.read(gameProvider.notifier).buySideBusinessUpgrade(business.id, upgrade.id);
                                  if (success) {
                                    NotificationService.showSuccess(context, '${upgrade.title} modülü satın alındı!');
                                  } else {
                                    NotificationService.showError(context, 'Yetersiz Bakiye!');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: p.secondaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '₺${CurrencyFormatter.formatShort(upgrade.cost)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
