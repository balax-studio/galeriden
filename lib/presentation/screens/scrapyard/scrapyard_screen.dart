import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/scrapyard_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/dialogs/lucky_opportunity_dialog.dart';
import '../../widgets/mini_games/scrapyard_teardown_canvas.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class ScrapyardScreen extends ConsumerStatefulWidget {
  const ScrapyardScreen({super.key});

  @override
  ConsumerState<ScrapyardScreen> createState() => _ScrapyardScreenState();
}

class _ScrapyardScreenState extends ConsumerState<ScrapyardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  String _searchQuery = '';

  final List<(String id, String label, IconData icon)> _partCategories = const [
    ('all', 'Tümü', Icons.apps_rounded),
    ('engine', 'Motor & Turbo', Icons.speed_rounded),
    ('transmission', 'Şanzıman', Icons.settings_input_component_rounded),
    ('ecu', 'Elektronik & ECU', Icons.memory_rounded),
    ('brakes', 'Yürüyen & Fren', Icons.disc_full_rounded),
    ('bodywork', 'Gövde & Jant', Icons.directions_car_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getTierColor(PartQualityTier tier) {
    switch (tier) {
      case PartQualityTier.worn:
        return const Color(0xFFEF4444); // Red
      case PartQualityTier.usable:
        return const Color(0xFFF59E0B); // Amber
      case PartQualityTier.good:
        return const Color(0xFF3B82F6); // Blue
      case PartQualityTier.pristine:
        return const Color(0xFF10B981); // Emerald
    }
  }

  void _showInstallPartDialog(BuildContext context, SalvagedPart part) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (game.ownedCars.isEmpty) {
      NotificationService.showError(context, 'Garajında parça takabileceğin hiç araç yok!');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(18),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('scrap_dialog_install_title'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('scrap_dialog_install_desc', {'part': part.name, 'cond': '${part.conditionPercent}'}),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: game.ownedCars.length,
                    itemBuilder: (cCtx, i) {
                      final car = game.ownedCars[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            final success = ref.read(gameProvider.notifier).installPartToCar(part.id, car.id);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                '${part.name}, ${car.brand} ${car.modelName} aracına başarıyla takıldı!',
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${car.modelYear} ${car.brand} ${car.modelName}',
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      'Motor: %${car.expertise.engineCondition.round()} • Şanzıman: %${car.expertise.transmissionCondition.round()}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDismantlePartsDialog(BuildContext context, ScrapyardCar car) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialParts = car.parts;

    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (dialogCtx, ref, _) {
            final game = ref.watch(gameProvider);
            final currentCarIndex = game.scrapyardCars.indexWhere((c) => c.id == car.id);
            final currentCar = currentCarIndex != -1 ? game.scrapyardCars[currentCarIndex] : null;
            final remainingPartIds = currentCar?.parts.map((p) => p.id).toSet() ?? <String>{};
            final remainingCount = remainingPartIds.length;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(18),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderRadius: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            context.tr('scrap_dialog_dismantle_title'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        NeoBrutalBadge(
                          text: remainingCount > 0
                              ? context.tr('scrap_remaining_parts_badge', {'count': '$remainingCount'})
                              : context.tr('scrap_all_dismantled_badge'),
                          backgroundColor: remainingCount > 0
                              ? AppColors.brutalOrange
                              : AppColors.brutalGreen,
                          textColor: Colors.black,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${car.brand} ${car.modelName.replaceAll(RegExp(r'\s*\(.*?\)\s*'), '')}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    if (currentCar != null && !currentCar.isPurchased)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.brutalYellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.brutalYellow, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.brutalYellow),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.tr('scrap_buy_first_notice'),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            NeoBrutalButton(
                              label: context.tr('scrap_btn_buy_short'),
                              backgroundColor: AppColors.brutalGreen,
                              textColor: Colors.black,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              onPressed: () {
                                final ok = ref.read(gameProvider.notifier).buyScrapCar(car.id);
                                if (ok) {
                                  NotificationService.showSuccess(context, 'Hurda araç satın alındı!');
                                } else {
                                  NotificationService.showError(context, 'Yetersiz bakiye!');
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: initialParts.length,
                        itemBuilder: (pCtx, i) {
                          final part = initialParts[i];
                          final isDismantled = !remainingPartIds.contains(part.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDismantled
                                    ? (isDark ? const Color(0xFF0B0D13) : const Color(0xFFF1F5F9))
                                    : (isDark ? const Color(0xFF0F1118) : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDismantled
                                      ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1))
                                      : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
                                  width: 2.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: isDismantled ? const Color(0xFF64748B) : _getTierColor(part.tier),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          part.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isDismantled ? const Color(0xFF64748B) : (isDark ? Colors.white : Colors.black),
                                            decoration: isDismantled ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        Text(
                                          isDismantled
                                              ? context.tr('scrap_dismantled_status')
                                              : context.tr('scrap_condition_value', {'cond': '${part.conditionPercent}', 'val': CurrencyFormatter.formatShort(part.estimatedValue)}),
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: isDismantled
                                                ? (isDark ? const Color(0xFF00E575) : const Color(0xFF16A34A))
                                                : const Color(0xFF64748B),
                                            fontWeight: isDismantled ? FontWeight.w700 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  NeoBrutalButton(
                                    label: isDismantled ? context.tr('scrap_btn_dismantled_badge') : context.tr('scrap_btn_dismantle_take'),
                                    icon: isDismantled ? Icons.check_circle_rounded : Icons.handyman_rounded,
                                    backgroundColor: isDismantled
                                        ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))
                                        : AppColors.brutalYellow,
                                    textColor: isDismantled
                                        ? (isDark ? const Color(0xFF00E575) : const Color(0xFF16A34A))
                                        : Colors.black,
                                    fontSize: 10,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    onPressed: (isDismantled || currentCar?.isPurchased != true)
                                        ? null
                                        : () => _handleDismantleChoice(context, car, part),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (remainingCount == 0)
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.brutalGreen, size: 18),
                              SizedBox(width: 4),
                              Text(
                                context.tr('scrap_chassis_ready_crush'),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brutalGreen),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),
                        NeoBrutalButton(
                          label: context.tr('close'),
                          backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                          textColor: isDark ? Colors.white70 : const Color(0xFF64748B),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleDismantleChoice(BuildContext context, ScrapyardCar car, SalvagedPart part) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: AppColors.brutalYellow,
          borderRadius: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('scrap_dismantle_method_title'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${part.name} • Mevcut Kondisyon: %${part.conditionPercent}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              NeoBrutalButton(
                label: context.tr('scrap_manual_dismantle_btn'),
                icon: Icons.build_circle_rounded,
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 11.5,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScrapyardTeardownModal.show(
                    context,
                    partName: part.name,
                    carName: '${car.brand} ${car.modelName}',
                    initialCondition: part.conditionPercent,
                    onCompleted: (isSuccess, finalCondition, message) {
                      final result = ref.read(gameProvider.notifier).dismantleSinglePartFromScrap(
                        car.id,
                        part.id,
                        forceSuccess: isSuccess,
                        customCondition: isSuccess ? finalCondition : null,
                      );
                      if (isSuccess && result.isSalvaged) {
                        NotificationService.showSuccess(
                          context,
                          context.tr('scrap_dismantle_success_toast', {'name': part.name, 'cond': '$finalCondition'}),
                        );
                        final luckyOpp = ref.read(gameProvider.notifier).checkAndRollLuckyOpportunity();
                        if (luckyOpp != null && context.mounted) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (context.mounted) {
                              LuckyOpportunityDialog.show(context, luckyOpp);
                            }
                          });
                        }
                      } else {
                        NotificationService.showWarning(context, result.message);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              NeoBrutalButton(
                label: context.tr('scrap_auto_dismantle_btn'),
                icon: Icons.flash_on_rounded,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white : Colors.black,
                fontSize: 11.5,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  Navigator.pop(ctx);
                  final result = ref.read(gameProvider.notifier).dismantleSinglePartFromScrap(car.id, part.id);
                  if (result.success) {
                    if (result.isSalvaged) {
                      NotificationService.showSuccess(context, result.message);
                    } else {
                      NotificationService.showWarning(context, result.message);
                    }
                  } else {
                    NotificationService.showError(context, result.message);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFulfillOrderDialog(BuildContext context, B2BPartOrder order) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter matching parts
    final matchingParts = game.salvagedParts.where((p) {
      if (p.category != order.requiredCategory) return false;
      if (order.requiredCarBrand != null) {
        if (!p.carModelName.toLowerCase().contains(order.requiredCarBrand!.toLowerCase())) {
          return false;
        }
      }
      return p.tier.index >= order.minQualityTier.index;
    }).toList();

    if (matchingParts.isEmpty) {
      NotificationService.showError(
        context,
        'Deponda ${order.mechanicName} ustasının istediği kriterlere uygun parça bulunmuyor!',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(18),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('scrap_fulfill_title'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('scrap_fulfill_desc', {'mechanic': order.mechanicName}),
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: matchingParts.length,
                    itemBuilder: (mCtx, i) {
                      final part = matchingParts[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            final success = ref.read(gameProvider.notifier).fulfillB2BPartOrder(order.id, part.id);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                '${part.name}, ${order.mechanicName} ustaya ${CurrencyFormatter.formatShort(order.offeredPrice)} karşılığı teslim edildi! • +${order.reputationReward} İtibar',
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      part.name,
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      '${part.carModelName} • %${part.conditionPercent} • ${part.tierName}',
                                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.check_circle_rounded, color: AppColors.brutalGreen, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScrapyardZoneSearchSheet(BuildContext context) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF10131B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.black, width: 3.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('scrap_zone_search_title'),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        context.tr('scrap_remaining_searches', {'count': '${game.remainingScrapSearchesToday}'}),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  NeoBrutalBadge(
                    text: context.tr('scrap_searches_badge', {'count': '${game.remainingScrapSearchesToday}'}),
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 10,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Günün Sanayi Tüyosu
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F293D) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brutalBlue, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.record_voice_over_rounded, size: 16, color: AppColors.brutalBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ScrapyardZoneExtension.getDailySanayiRumor(game.currentDay),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...ScrapyardZoneType.values.map((zone) {
                final canAfford = game.balance >= zone.cost;
                final hasRemaining = game.remainingScrapSearchesToday > 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: isDark ? const Color(0xFF161B26) : const Color(0xFFF8FAFC),
                    borderColor: zone.color,
                    borderWidth: 2.0,
                    borderRadius: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: zone.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Icon(zone.icon, color: Colors.black, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                zone.title,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                zone.description,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeoBrutalButton(
                          label: CurrencyFormatter.formatShort(zone.cost),
                          backgroundColor: (canAfford && hasRemaining) ? zone.color : Colors.grey,
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          onPressed: (canAfford && hasRemaining)
                              ? () {
                                  Navigator.pop(ctx);
                                  final found = ref.read(gameProvider.notifier).searchScrapForTreasures(zone: zone);
                                  if (found != null) {
                                    if (found > 0) {
                                      NotificationService.showSuccess(
                                        context,
                                        '${zone.title} taramasında +${CurrencyFormatter.format(found)} değerinde parça ve hazine buldun!',
                                      );
                                    } else {
                                      NotificationService.showWarning(
                                        context,
                                        '${zone.title} bölgesinde bu sefer değerli bir şey çıkmadı.',
                                      );
                                    }
                                  } else {
                                    NotificationService.showError(context, 'Günlük arama hakkın tükendi veya yetersiz bakiye!');
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/scrapyard')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('scrapyard')),
        body: NeoBrutalLockedFeatureView(
          route: '/scrapyard',
          featureTitle: context.tr('scrap_screen_title'),
          icon: Icons.delete_outline_rounded,
        ),
      );
    }

    final scrapCars = game.scrapyardCars;
    final salvagedParts = game.salvagedParts;
    final b2bOrders = game.b2bPartOrders.where((o) => !o.isCompleted).toList();

    // Filter parts
    final filteredParts = salvagedParts.where((part) {
      final matchesCat = _selectedCategory == 'all' ||
          (_selectedCategory == 'engine' && (part.category == 'engine' || part.category == 'turbo' || part.category == 'radiator')) ||
          (_selectedCategory == 'transmission' && part.category == 'transmission') ||
          (_selectedCategory == 'ecu' && part.category == 'ecu') ||
          (_selectedCategory == 'brakes' && (part.category == 'brakes' || part.category == 'suspension')) ||
          (_selectedCategory == 'bodywork' && (part.category == 'bodywork' || part.category == 'wheels' || part.category == 'headlights' || part.category == 'seats'));

      final matchesSearch = _searchQuery.isEmpty ||
          part.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          part.carModelName.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('scrapyard'),
        bottom: NeoBrutalTabBar(
          controller: _tabController,
          tabs: [
            context.tr('scrap_tab_scrap_cars', {'count': '${scrapCars.where((c) => !c.isPurchased).length}'}),
            context.tr('scrap_tab_salvaged_parts', {'count': '${salvagedParts.length}'}),
            context.tr('scrap_tab_b2b_orders', {'count': '${b2bOrders.length}'}),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ==================== TAB 1: PERT HURDA ARAÇLAR ====================
          Builder(
            builder: (context) {
              final activeScrapCars = scrapCars;
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
                        borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
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
                                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: const Icon(Icons.car_crash_rounded, color: Colors.black, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('scrap_banner_title'),
                                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        context.tr('scrap_banner_desc'),
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
                                      final bool canWorkGig = game.lastScrapyardGigDate == null ||
                                          DateTime.now().difference(game.lastScrapyardGigDate!).inHours >= 20;

                                      return NeoBrutalButton(
                                        label: canWorkGig ? context.tr('scrap_btn_gig_available') : context.tr('scrap_btn_gig_done'),
                                        icon: canWorkGig ? Icons.work_history_rounded : Icons.check_circle_rounded,
                                        backgroundColor: canWorkGig
                                            ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                                            : (isDark ? const Color(0xFF141721) : const Color(0xFFCBD5E1)),
                                        textColor: canWorkGig
                                            ? (isDark ? Colors.white : Colors.black)
                                            : (isDark ? Colors.white38 : Colors.black38),
                                        fontSize: 11,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        onPressed: canWorkGig
                                            ? () {
                                                final success = ref.read(gameProvider.notifier).workScrapyardSideGig();
                                                if (success) {
                                                  NotificationService.showSuccess(
                                                    context,
                                                    'Hurdalıkta günlük çıraklık yaptın ve ₺5.000 yevmiye kazandın!',
                                                  );
                                                } else {
                                                  NotificationService.showError(context, 'Hurdalık çıraklık işini günde sadece 1 kez yapabilirsin.');
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
                              onPressed: () => _showScrapyardZoneSearchSheet(context),
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
                      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                      borderRadius: 14,
                      child: Center(
                        child: Text(
                          context.tr('scrap_empty_cars'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
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
                      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
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
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.brutalOrange),
                          ),
                          const SizedBox(height: 8),

                          // Chassis weight & Secret find info
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1F2C) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.scale_rounded, size: 14, color: Color(0xFF64748B)),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.tr('scrap_chassis_info', {'weight': '${car.chassisScrapMetalWeightKg}', 'value': CurrencyFormatter.formatShort(car.chassisScrapValue)}),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                if (car.surpriseFindItem != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.card_giftcard_rounded, size: 14, color: AppColors.brutalYellow),
                                      const SizedBox(width: 4),
                                      Text(
                                context.tr('scrap_glovebox_surprise'),
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.brutalYellow),
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
                              color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.tr('scrap_dismantlable_parts', {'count': '${car.parts.length}'}),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                                    ),
                                    Text(
                                      context.tr('scrap_total_estimated', {'val': CurrencyFormatter.formatShort(car.estimatedPartTotalValue)}),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (car.parts.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      context.tr('scrap_all_parts_dismantled'),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                                    ),
                                  )
                                else
                                  ...car.parts.map((p) => Padding(
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
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '~${CurrencyFormatter.formatShort(p.estimatedValue)}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                            ),
                                          ],
                                        ),
                                      )),
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
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatShort(car.scrapPrice),
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.brutalOrange),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      onPressed: () {
                                        if (game.balance < car.scrapPrice) {
                                          NotificationService.showError(context, 'Yetersiz bakiye • ${CurrencyFormatter.formatShort(car.scrapPrice)} gerekli.');
                                          return;
                                        }
                                        final ok = ref.read(gameProvider.notifier).buyScrapCar(car.id);
                                        if (ok) {
                                          NotificationService.showSuccess(context, 'Hurda araç satın alındı!');
                                        } else {
                                          NotificationService.showError(context, 'Satın alma başarısız oldu.');
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
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      onPressed: () {
                                        if (game.balance < car.scrapPrice) {
                                          NotificationService.showError(context, 'Yetersiz bakiye • ${CurrencyFormatter.formatShort(car.scrapPrice)} gerekli.');
                                          return;
                                        }
                                        final res = ref.read(gameProvider.notifier).buyAndDismantleScrapCar(car.id);
                                        if (res.success) {
                                          NotificationService.showSuccess(
                                            context,
                                            res.message,
                                          );
                                        } else {
                                          NotificationService.showError(context, res.message);
                                        }
                                      },
                                    ),
                                  ] else if (car.parts.isNotEmpty) ...[
                                    NeoBrutalButton(
                                      label: context.tr('scrap_btn_dismantle_single'),
                                      icon: Icons.handyman_rounded,
                                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                      textColor: isDark ? Colors.white : Colors.black,
                                      fontSize: 10.5,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      onPressed: () => _showDismantlePartsDialog(context, car),
                                    ),
                                    const SizedBox(width: 6),
                                    NeoBrutalButton(
                                      label: 'HEPSİNİ SÖK',
                                      icon: Icons.all_inbox_rounded,
                                      backgroundColor: AppColors.brutalYellow,
                                      textColor: Colors.black,
                                      fontSize: 10.5,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      onPressed: () {
                                        final res = ref.read(gameProvider.notifier).buyAndDismantleScrapCar(car.id);
                                        if (res.success) {
                                          NotificationService.showSuccess(
                                            context,
                                            res.message,
                                          );
                                        } else {
                                          NotificationService.showError(context, res.message);
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
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      onPressed: () {
                                        final res = ref.read(gameProvider.notifier).crushChassisToScrapMetal(car.id);
                                        if (res.success) {
                                          NotificationService.showSuccess(context, res.message);
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
            },
          ),

          // ==================== TAB 2: ÇIKMA PARÇA DEPOSU & ATÖLYE ====================
          Column(
            children: [
              // Search and Category Filter Bar
              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                color: isDark ? const Color(0xFF12151E) : Colors.white,
                child: Column(
                  children: [
                    // Search box
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: context.tr('scrap_search_hint'),
                          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          prefixIcon: Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Categories horizontal bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _partCategories.map((cat) {
                          final isSelected = _selectedCategory == cat.$1;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () => setState(() => _selectedCategory = cat.$1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.brutalYellow
                                      : (isDark ? const Color(0xFF1A1F2C) : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      cat.$3,
                                      size: 13,
                                      color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      cat.$2,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Parts List
              Expanded(
                child: filteredParts.isEmpty
                    ? Center(
                        child: NeoBrutalCard(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(28),
                          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                          borderRadius: 14,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_rounded, color: Color(0xFF64748B), size: 40),
                              const SizedBox(height: 10),
                              Text(
                                context.tr('scrap_no_parts_found'),
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedCategory == 'all' && _searchQuery.isEmpty
                                    ? context.tr('scrap_no_parts_desc_all')
                                    : context.tr('scrap_no_parts_desc_filter'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredParts.length,
                        itemBuilder: (context, index) {
                          final part = filteredParts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: NeoBrutalCard(
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
                                      Expanded(
                                        child: Text(
                                          part.name,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      NeoBrutalBadge(
                                        text: part.tierName,
                                        backgroundColor: _getTierColor(part.tier),
                                        textColor: Colors.white,
                                        fontSize: 9.5,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Model: ${part.carModelName} • Kondisyon: %${part.conditionPercent}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        CurrencyFormatter.formatShort(part.estimatedValue),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                      ),
                                      Row(
                                        children: [
                                          if (part.canRefurbish) ...[
                                            NeoBrutalButton(
                                              label: context.tr('scrap_btn_refurbish', {'cost': '₺${part.refurbishCost.toInt()}'}),
                                              icon: Icons.auto_fix_high_rounded,
                                              backgroundColor: AppColors.brutalPurple,
                                              textColor: Colors.white,
                                              fontSize: 10,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              onPressed: () {
                                                if (game.balance < part.refurbishCost) {
                                                  NotificationService.showError(
                                                    context,
                                                    'Yetersiz bakiye! Revizyon için ${CurrencyFormatter.formatShort(part.refurbishCost)} gerekli.',
                                                  );
                                                  return;
                                                }
                                                final success = ref.read(gameProvider.notifier).refurbishSalvagedPart(part.id);
                                                if (success) {
                                                  NotificationService.showSuccess(
                                                    context,
                                                    '${part.name} atölyede başarıyla revize edildi ve kondisyonu yükseltildi!',
                                                  );
                                                }
                                              },
                                            ),
                                            const SizedBox(width: 6),
                                          ],
                                          NeoBrutalButton(
                                            label: context.tr('scrap_btn_install'),
                                            icon: Icons.handyman_rounded,
                                            backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                            textColor: isDark ? Colors.white : Colors.black,
                                            fontSize: 10,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            onPressed: () => _showInstallPartDialog(context, part),
                                          ),
                                          const SizedBox(width: 6),
                                          NeoBrutalButton(
                                            label: context.tr('scrap_btn_sell'),
                                            icon: Icons.attach_money_rounded,
                                            backgroundColor: AppColors.brutalGreen,
                                            textColor: Colors.black,
                                            fontSize: 10,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            onPressed: () {
                                              final success = ref.read(gameProvider.notifier).sellSalvagedPart(part.id);
                                              if (success) {
                                                NotificationService.showSuccess(
                                                  context,
                                                  '${part.name} ${CurrencyFormatter.formatShort(part.estimatedValue)} karşılığı satıldı!',
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
                        },
                      ),
              ),
            ],
          ),

          // ==================== TAB 3: SANAYİ B2B TALEPLERİ ====================
          b2bOrders.isEmpty
              ? Center(
                  child: NeoBrutalCard(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(28),
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                    borderRadius: 14,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.assignment_turned_in_rounded, color: AppColors.brutalGreen, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          context.tr('scrap_b2b_all_done_title'),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4),
                        Text(
                          context.tr('scrap_b2b_all_done_desc'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(14),
                  physics: const BouncingScrollPhysics(),
                  itemCount: b2bOrders.length,
                  itemBuilder: (context, index) {
                    final order = b2bOrders[index];

                    // Check if stock has matching part
                    final hasMatchingPart = salvagedParts.any((p) {
                      if (p.category != order.requiredCategory) return false;
                      if (order.requiredCarBrand != null) {
                        if (!p.carModelName.toLowerCase().contains(order.requiredCarBrand!.toLowerCase())) {
                          return false;
                        }
                      }
                      return p.tier.index >= order.minQualityTier.index;
                    });

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(14),
                        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                        borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                        borderRadius: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(order.mechanicAvatar, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Text(
                                      order.mechanicName,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                NeoBrutalBadge(
                                  text: '+${order.reputationReward} İtibar',
                                  backgroundColor: AppColors.brutalPurple,
                                  textColor: Colors.white,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.description,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 10),

                            // Required specifications
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.tr('scrap_b2b_category', {'cat': '${order.requiredCategory.toUpperCase()}${order.requiredCarBrand != null ? " • ${order.requiredCarBrand}" : ""}'}),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    context.tr('scrap_b2b_min_tier', {'tier': order.minQualityTier.name.toUpperCase()}),
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: _getTierColor(order.minQualityTier)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                  context.tr('scrap_b2b_mechanic_offer'),
                                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                    ),
                                    Text(
                                      CurrencyFormatter.formatShort(order.offeredPrice),
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                    ),
                                  ],
                                ),
                                NeoBrutalButton(
                                  label: hasMatchingPart ? context.tr('scrap_b2b_btn_fulfill') : context.tr('scrap_b2b_btn_no_part'),
                                  icon: hasMatchingPart ? Icons.local_shipping_rounded : Icons.block_rounded,
                                  backgroundColor: hasMatchingPart ? AppColors.brutalGreen : const Color(0xFF64748B),
                                  textColor: hasMatchingPart ? Colors.black : Colors.white,
                                  fontSize: 11,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  onPressed: () => _showFulfillOrderDialog(context, order),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
