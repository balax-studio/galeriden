import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/scrapyard_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/hydraulic_crush_wave_widget.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import 'scrapyard_dismantle_dialog.dart';
import 'scrapyard_search_zone_dialog.dart';

class ScrapyardScrapCarsTab extends ConsumerWidget {
  const ScrapyardScrapCarsTab({super.key});

  Color _getTierColor(PartQualityTier tier) {
    switch (tier) {
      case PartQualityTier.worn:
        return const Color(0xFFEF4444);
      case PartQualityTier.usable:
        return const Color(0xFFF59E0B);
      case PartQualityTier.good:
        return const Color(0xFF3B82F6);
      case PartQualityTier.pristine:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeScrapCars = game.scrapyardCars;

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      itemCount: activeScrapCars.isEmpty ? 2 : activeScrapCars.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor:
                  isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 14,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.brutalOrange,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(Icons.car_crash_rounded,
                            color: Colors.black, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('scrap_banner_title'),
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('scrap_banner_desc'),
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final bool canWorkGig = game.lastScrapyardGigDay < game.currentDay;

                            return NeoBrutalButton(
                              label: canWorkGig
                                  ? context.tr('scrap_btn_gig_available')
                                  : context.tr('scrap_btn_gig_done'),
                              icon: canWorkGig
                                  ? Icons.work_history_rounded
                                  : Icons.check_circle_rounded,
                              backgroundColor: canWorkGig
                                  ? (isDark
                                      ? const Color(0xFF1E2330)
                                      : const Color(0xFFE2E8F0))
                                  : (isDark
                                      ? const Color(0xFF141721)
                                      : const Color(0xFFCBD5E1)),
                              textColor: canWorkGig
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isDark ? Colors.white38 : Colors.black38),
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              onPressed: canWorkGig
                                  ? () {
                                      final success = ref
                                          .read(gameProvider.notifier)
                                          .workScrapyardSideGig();
                                      if (success) {
                                        NotificationService.showSuccess(
                                          context,
                                          context.tr(
                                              'scrapyard_toast_apprentice_done'),
                                        );
                                      } else {
                                        NotificationService.showError(
                                          context,
                                          context.tr(
                                              'scrapyard_toast_apprentice_limit'),
                                        );
                                      }
                                    }
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  NeoBrutalButton(
                    label: context.tr('scrap_btn_search_zone'),
                    icon: Icons.travel_explore_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 11,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: () =>
                        ScrapyardSearchZoneDialog.show(context, ref),
                  ),
                ],
              ),
            ),
          );
        }

        if (activeScrapCars.isEmpty) {
          return NeoBrutalCard(
            padding: const EdgeInsets.all(24),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Center(
              child: Text(
                context.tr('scrap_empty_cars'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          );
        }

        final car = activeScrapCars[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${car.modelYear} ${car.brand} ${car.modelName}',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (car.isPurchased) ...[
                          NeoBrutalBadge(
                            text: context.tr('scrap_badge_owned'),
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 9.5,
                          ),
                          const SizedBox(width: 6),
                        ],
                        NeoBrutalBadge(
                          text: context.tr('scrap_badge_heavy_damage'),
                          backgroundColor: AppColors.errorRed,
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('scrap_damage_note', {'note': car.damageNote}),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brutalOrange),
                ),
                const SizedBox(height: 8),

                // Chassis weight & Secret find info
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1F2C)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.scale_rounded,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('scrap_chassis_info', {
                              'weight': '${car.chassisScrapMetalWeightKg}',
                              'value': CurrencyFormatter.formatShort(
                                  car.chassisScrapValue)
                            }),
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      if (car.surpriseFindItem != null)
                        Row(
                          children: [
                            const Icon(Icons.card_giftcard_rounded,
                                size: 14, color: AppColors.brutalYellow),
                            const SizedBox(width: 4),
                            Text(
                              context.tr('scrap_glovebox_surprise'),
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brutalYellow),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Sökülebilir Parçalar Listesi
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1118)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              context.tr('scrap_dismantlable_parts',
                                  {'count': '${car.parts.length}'}),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF64748B)),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              context.tr('scrap_total_estimated', {
                                'val': CurrencyFormatter.formatShort(
                                    car.estimatedPartTotalValue)
                              }),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brutalGreen),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (car.parts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            context.tr('scrap_all_parts_dismantled'),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B)),
                          ),
                        )
                      else
                        ...car.parts.map(
                          (p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getTierColor(p.tier),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Text(
                                    '~${CurrencyFormatter.formatShort(p.estimatedValue)}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.brutalGreen),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Fiyat & Aksiyon Butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('scrap_price_label'),
                          style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B)),
                        ),
                        Text(
                          CurrencyFormatter.formatShort(car.scrapPrice),
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalOrange),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (!car.isPurchased) ...[
                          NeoBrutalButton(
                            label: context.tr('scrap_btn_buy_car'),
                            icon: Icons.shopping_cart_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10.5,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            onPressed: () {
                              if (game.balance < car.scrapPrice) {
                                NotificationService.showError(
                                  context,
                                  context.tr(
                                      'toast_insufficient_balance_needed', {
                                    'cost': CurrencyFormatter.formatShort(
                                        car.scrapPrice)
                                  }),
                                );
                                return;
                              }
                              final ok = ref
                                  .read(gameProvider.notifier)
                                  .buyScrapCar(car.id);
                              if (ok) {
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('scrapyard_toast_car_bought'),
                                );
                              } else {
                                NotificationService.showError(
                                  context,
                                  context.tr('forex_tx_failed_toast'),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 6),
                          NeoBrutalButton(
                            label: context.tr('scrap_btn_dismantle_all'),
                            icon: Icons.all_inbox_rounded,
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 10.5,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            onPressed: () {
                              if (game.balance < car.scrapPrice) {
                                NotificationService.showError(
                                  context,
                                  context.tr(
                                      'toast_insufficient_balance_needed', {
                                    'cost': CurrencyFormatter.formatShort(
                                        car.scrapPrice)
                                  }),
                                );
                                return;
                              }
                              final res = ref
                                  .read(gameProvider.notifier)
                                  .buyAndDismantleScrapCar(car.id);
                              if (res.success) {
                                NotificationService.showSuccess(
                                  context,
                                  res.message,
                                );
                              } else {
                                NotificationService.showError(
                                    context, res.message);
                              }
                            },
                          ),
                        ] else if (car.parts.isNotEmpty) ...[
                          NeoBrutalButton(
                            label: context.tr('scrap_btn_dismantle_single'),
                            icon: Icons.handyman_rounded,
                            backgroundColor: isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFE2E8F0),
                            textColor: isDark ? Colors.white : Colors.black,
                            fontSize: 10.5,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            onPressed: () => ScrapyardDismantleDialog.show(
                                context, ref, car),
                          ),
                          const SizedBox(width: 6),
                          NeoBrutalButton(
                            label: context.tr('scrapyard_strip_all_btn'),
                            icon: Icons.all_inbox_rounded,
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 10.5,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            onPressed: () {
                              final res = ref
                                  .read(gameProvider.notifier)
                                  .buyAndDismantleScrapCar(car.id);
                              if (res.success) {
                                NotificationService.showSuccess(
                                  context,
                                  res.message,
                                );
                              } else {
                                NotificationService.showError(
                                    context, res.message);
                              }
                            },
                          ),
                        ] else ...[
                          NeoBrutalButton(
                            label: context.tr('scrap_btn_crush_chassis'),
                            icon: Icons.compress_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10.5,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            onPressed: () {
                              final res = ref
                                  .read(gameProvider.notifier)
                                  .crushChassisToScrapMetal(car.id);
                              if (res.success) {
                                NotificationService.showSuccess(
                                    context, res.message);
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (c) => Center(
                                    child: HydraulicCrushWaveWidget(
                                      size: 160,
                                      onComplete: () {
                                        if (Navigator.canPop(c)) {
                                          Navigator.pop(c);
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
