import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/mini_games/hidden_stash_canvas.dart';

class BlackMarketScreen extends ConsumerStatefulWidget {
  const BlackMarketScreen({super.key});

  @override
  ConsumerState<BlackMarketScreen> createState() => _BlackMarketScreenState();
}

class _BlackMarketScreenState extends ConsumerState<BlackMarketScreen> {
  final Set<String> _scannedCarIds = {};
  final Set<String> _cleansedRiskCarIds = {};

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/black-market')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('bm_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/black-market',
          featureTitle: context.tr('bm_screen_title'),
          icon: Icons.masks_rounded,
        ),
      );
    }

    final bmCars = game.blackMarketCars;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('bm_screen_title'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // Header Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFF161922),
            borderColor: AppColors.errorRed,
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.masks_rounded, color: AppColors.errorRed, size: 24),
                        SizedBox(width: 8),
                        Text(
                          context.tr('bm_banner_title'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    NeoBrutalBadge(
                      text: context.tr('bm_banner_badge'),
                      backgroundColor: AppColors.errorRed,
                      textColor: Colors.white,
                      fontSize: 9.5,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('bm_banner_desc'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFCBD5E1),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Car List
          if (bmCars.isEmpty || bmCars.every((c) => c.isPurchased))
            NeoBrutalCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  context.tr('bm_empty_title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            )
          else
            ...bmCars.where((c) => !c.isPurchased).map((car) {
              final isScanned = _scannedCarIds.contains(car.id);
              final isCleansed = _cleansedRiskCarIds.contains(car.id);
              final displayRisk = isCleansed ? 0 : car.riskLevelPercent;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isCleansed ? AppColors.brutalGreen : AppColors.errorRed,
                  borderRadius: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${car.modelYear} ${car.brand} ${car.modelName}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                          NeoBrutalBadge(
                            text: isCleansed ? context.tr('bm_police_risk_clean') : context.tr('bm_police_risk_val', {'risk': '$displayRisk'}),
                            backgroundColor: isCleansed ? AppColors.brutalGreen : AppColors.errorRed,
                            textColor: isCleansed ? Colors.black : Colors.white,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('bm_seller_label', {'seller': car.sellerAlias}),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalYellow),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCleansed ? context.tr('bm_clean_desc') : car.riskDescription,
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: isCleansed ? AppColors.brutalGreen : const Color(0xFFEF4444)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Piyasa: ${CurrencyFormatter.formatShort(car.realMarketValue)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    CurrencyFormatter.formatShort(
                                      game.hasHighNpcTrust('golge_ibrahim')
                                          ? (car.askingPrice * 0.85).roundToDouble()
                                          : car.askingPrice,
                                    ),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                  ),
                                  if (game.hasHighNpcTrust('golge_ibrahim')) ...[
                                    const SizedBox(width: 6),
                                    NeoBrutalBadge(
                      text: context.tr('bm_shadow_discount'),
                                      backgroundColor: AppColors.brutalYellow,
                                      textColor: Colors.black,
                                      fontSize: 9,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              NeoBrutalButton(
                                label: isScanned ? context.tr('bm_btn_scanned_stash') : context.tr('bm_btn_scan_stash'),
                                icon: isScanned ? Icons.check_circle_rounded : Icons.radar_rounded,
                                backgroundColor: isScanned ? const Color(0xFF1E293B) : const Color(0xFF6366F1),
                                textColor: isScanned ? Colors.white54 : Colors.white,
                                fontSize: 10,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                onPressed: isScanned
                                    ? null
                                    : () {
                                        HiddenStashModal.show(
                                          context,
                                          car: car,
                                          onInspectionCompleted: (stashFound, rewardCash, itemDesc) {
                                            setState(() {
                                              _scannedCarIds.add(car.id);
                                            });
                                            if (stashFound) {
                                              ref.read(gameProvider.notifier).addMoney(rewardCash);
                                              NotificationService.showSuccess(
                                                context,
                                                'Zula Ele Geçirildi! +${CurrencyFormatter.format(rewardCash)} kasaya aktarıldı.',
                                              );
                                            }
                                          },
                                        );
                                      },
                              ),
                              if (!isCleansed) ...[
                                const SizedBox(height: 6),
                                NeoBrutalButton(
                                  label: context.tr('bm_btn_fake_plate'),
                                  icon: Icons.shield_rounded,
                                  backgroundColor: const Color(0xFF10B981),
                                  textColor: Colors.black,
                                  fontSize: 10,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  onPressed: () {
                                    AdService.instance.showRewardedAdWithFallback(
                                      context: context,
                                      customRewardTitle: 'Gölge Muhbir & Sahte Plaka Evrakı',
                                      onRewardEarned: () {
                                        setState(() {
                                          _cleansedRiskCarIds.add(car.id);
                                        });
                                        NotificationService.showSuccess(
                                          context,
                                          '${car.brand} ${car.modelName} için sahte plaka takıldı - Polis riski %0 oldu!',
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                              const SizedBox(height: 6),
                              NeoBrutalButton(
                                label: context.tr('bm_btn_buy_risk'),
                                icon: Icons.gavel_rounded,
                                backgroundColor: AppColors.errorRed,
                                textColor: Colors.white,
                                fontSize: 11,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                onPressed: () {
                                  if (game.ownedCars.length >= game.maxGarageSlots) {
                                    NotificationService.showError(context, 'Garajında boş yer yok! Şubeni büyüt veya bir araç sat.');
                                    return;
                                  }
                                  final effectiveCost = game.hasHighNpcTrust('golge_ibrahim')
                                      ? (car.askingPrice * 0.85).roundToDouble()
                                      : car.askingPrice;
                                  if (game.balance < effectiveCost) {
                                    NotificationService.showError(context, 'Yetersiz bakiye! ${CurrencyFormatter.formatShort(effectiveCost)} gerekli.');
                                    return;
                                  }

                                  final success = ref.read(gameProvider.notifier).buyBlackMarketCar(car.id);
                                  if (success) {
                                    NotificationService.showSuccess(
                                      context,
                                      '${car.modelName} karaborsadan satın alındı! Garajına eklendi.',
                                    );
                                  }
                                },
                              ),
                            ],
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
