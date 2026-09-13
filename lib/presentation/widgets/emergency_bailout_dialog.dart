import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/ad_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/notification_service.dart';
import '../../data/models/car_model.dart';
import '../providers/game_provider.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';
import 'pixel_art/neo_brutal_pixel_face.dart';

/// Neo-Brutalist emergency bailout dialog triggered when the player's balance is negative
/// or nearing critical bankruptcy, providing actionable lifelines.
class EmergencyBailoutDialog extends ConsumerStatefulWidget {
  final VoidCallback? onDismissed;

  const EmergencyBailoutDialog({
    super.key,
    this.onDismissed,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onDismissed}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EmergencyBailoutDialog(onDismissed: onDismissed),
    );
  }

  @override
  ConsumerState<EmergencyBailoutDialog> createState() =>
      _EmergencyBailoutDialogState();
}

class _EmergencyBailoutDialogState
    extends ConsumerState<EmergencyBailoutDialog> {
  bool _isClaiming = false;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final deficit = game.balance < 0 ? game.balance.abs() : 0.0;
    // Emergency grant amount: ₺50,000 or deficit + ₺25,000 buffer
    final grantAmount = max(50000.0, ((deficit + 25000.0) / 1000).ceil() * 1000.0);

    // Pick cheapest owned car eligible for spot liquidation
    CarModel? cheapestCar;
    double liquidationPrice = 0.0;
    final eligibleCars = game.ownedCars
        .where((c) => !c.isLockedInShowcase && !c.isRented)
        .toList();
    if (eligibleCars.isNotEmpty) {
      eligibleCars.sort((a, b) => a.estimatedRealValue.compareTo(b.estimatedRealValue));
      cheapestCar = eligibleCars.first;
      liquidationPrice = (cheapestCar.estimatedRealValue * 0.75 / 500).round() * 500.0;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            NeoBrutalCard(
              padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: AppColors.brutalRed,
          borderWidth: 3.0,
          borderRadius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Alert Ribbon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brutalRed,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeoBrutalBadge(
                            text: context.tr('bailout_badge_emergency'),
                            backgroundColor: AppColors.brutalRed,
                            textColor: Colors.white,
                            fontSize: 10,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('bailout_dialog_title'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Deficit Status Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brutalRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.brutalRed, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('bailout_deficit_label'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      '-${CurrencyFormatter.format(deficit)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brutalRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                context.tr('bailout_dialog_desc'),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),

              // 3. Option 1: Sponsor Grant Lifeline
              NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                borderColor: AppColors.brutalGreen,
                borderWidth: 2.0,
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.volunteer_activism_rounded,
                          color: AppColors.brutalGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('bailout_grant_title'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '+${CurrencyFormatter.format(grantAmount)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brutalGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    NeoBrutalButton(
                      label: context.tr('bailout_ad_grant_btn'),
                      icon: Icons.play_circle_fill_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      fullWidth: true,
                      onPressed: _isClaiming
                          ? null
                          : () {
                              setState(() => _isClaiming = true);
                              AdService.instance.showRewardedAdWithFallback(
                                context: context,
                                customRewardTitle: context.tr('bailout_reward_title'),
                                onRewardEarned: () {
                                  ref.read(gameProvider.notifier).addMoney(grantAmount);
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    NotificationService.showSuccess(
                                      context,
                                      context.tr('bailout_grant_claimed_toast'),
                                    );
                                  }
                                },
                              );
                              if (mounted) {
                                setState(() => _isClaiming = false);
                              }
                            },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Option 2: Spot Market Emergency Liquidation
              if (cheapestCar != null) ...[
                NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                  borderColor: AppColors.brutalOrange,
                  borderWidth: 2.0,
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_rounded,
                            color: AppColors.brutalOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${cheapestCar.brand} ${cheapestCar.modelName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '+${CurrencyFormatter.format(liquidationPrice)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      NeoBrutalButton(
                        label: context.tr('bailout_quick_sell_btn'),
                        icon: Icons.sell_rounded,
                        backgroundColor: AppColors.brutalOrange,
                        textColor: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        fullWidth: true,
                        onPressed: _isClaiming
                            ? null
                            : () {
                                ref.read(gameProvider.notifier).sellCar(
                                      cheapestCar!.id,
                                      liquidationPrice,
                                    );
                                Navigator.of(context).pop();
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('bailout_car_sold_toast'),
                                );
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 5. Dismiss / Postpone
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onDismissed?.call();
                  },
                  child: Text(
                    context.tr('bailout_postpone_btn'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.directional(
          textDirection: Directionality.of(context),
          top: -18,
          end: -10,
          child: const NeoBrutalPixelFaceWidget(
            expression: PixelFaceExpression.panickedBanker,
            showBadge: true,
            size: 52,
          ),
        ),
      ],
    ),
  ),
);
  }
}
