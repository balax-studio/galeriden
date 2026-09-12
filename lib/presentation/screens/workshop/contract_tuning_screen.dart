import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/outsourced_tuning_model.dart';
import '../../../domain/usecases/outsourced_tuning_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/outsourced_tuning_provider.dart';
import '../../widgets/hazard_stripe_widget.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_page_background.dart';
import 'widgets/carbon_weave_painter.dart';

class ContractTuningScreen extends ConsumerStatefulWidget {
  const ContractTuningScreen({super.key});

  @override
  ConsumerState<ContractTuningScreen> createState() => _ContractTuningScreenState();
}

class _ContractTuningScreenState extends ConsumerState<ContractTuningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentDay = ref.read(gameProvider).currentDay;
        ref.read(outsourcedTuningProvider.notifier).onDayAdvanced(currentDay);
      }
    });
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '00:00';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      final remM = m % 60;
      return '${h.toString().padLeft(2, '0')}:${remM.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _openCarSelectionSheet(OutsourcedTuningStudio studio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CarSelectionBottomSheet(
        studio: studio,
        onCarSelected: (car) => _handleOrderSubmit(car, studio),
      ),
    );
  }

  void _handleOrderSubmit(CarModel car, OutsourcedTuningStudio studio) {
    final game = ref.read(gameProvider);
    final cost = OutsourcedTuningEngine.calculateCost(studio, car);

    if (game.balance < cost) {
      NotificationService.showError(
        context,
        context.tr('toast_insufficient_balance_needed', {
          'cost': CurrencyFormatter.format(cost),
        }),
      );
      return;
    }

    final order = ref.read(outsourcedTuningProvider.notifier).submitOrder(
      car: car,
      studio: studio,
    );

    if (order != null) {
      NotificationService.showSuccess(
        context,
        '${car.brand} ${car.modelName} ${context.tr(studio.nameKey)} atölyesine teslim edildi',
      );
    }
  }

  void _handleSpeedupAd(TuningOrder order) {
    if (order.speedupCount >= 2) return;

    AdService.instance.showRewardedAdWithFallback(
      context: context,
      customRewardTitle: context.tr('tuning_outsourced_btn_speedup'),
      onRewardEarned: () {
        final success = ref
            .read(outsourcedTuningProvider.notifier)
            .speedupOrderWithAd(order.orderId);
        if (success && mounted) {
          NotificationService.showSuccess(
            context,
            context.tr('tuning_outsourced_speedup_success'),
          );
        }
      },
    );
  }

  void _handlePickupCar(TuningOrder order) {
    final updatedCar = ref
        .read(outsourcedTuningProvider.notifier)
        .claimCompletedOrder(order.orderId);

    if (updatedCar != null && mounted) {
      final studio = OutsourcedTuningEngine.getStudioById(order.studioId);
      _showPickupCelebrationModal(updatedCar, order, studio);
    }
  }

  void _showPickupCelebrationModal(
    CarModel car,
    TuningOrder order,
    OutsourcedTuningStudio? studio,
  ) {
    final studioName = studio != null ? context.tr(studio.nameKey) : 'VIP Atolye';
    final badgeLabel = studio != null ? context.tr(studio.badgeKey) : 'VIP MOD';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161922),
            border: Border.all(color: Colors.black, width: 3.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.toxicLime,
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Colors.black, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('tuning_outsourced_pickup_title'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const HazardStripeWidget(height: 6),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD600),
                          border: Border.all(color: Colors.black, width: 2.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          badgeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${car.brand} ${car.modelName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('tuning_outsourced_pickup_desc', {'studio': studioName}),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFCBD5E1),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0F14),
                        border: Border.all(color: const Color(0xFF2A2E3D), width: 2.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('tuning_outsourced_val_gain_label'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+${CurrencyFormatter.format(order.expectedValueGain)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.toxicLime,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                context.tr('tuning_outsourced_new_val_label'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormatter.format(car.baseMarketValue),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: NeoBrutalButton(
                  label: context.tr('tuning_outsourced_btn_close'),
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final outsourcedState = ref.watch(outsourcedTuningProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ??
        (Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080B10) : const Color(0xFFF3F1EA),
      appBar: NeoBrutalAppBar(
        title: context.tr('tuning_outsourced_screen_title'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.brutalYellow,
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: Text(
                  CurrencyFormatter.formatShort(game.balance),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: NeoBrutalPageBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top Hero Banner with Carbon Weave Generative Art Shader
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRect(
                child: CustomPaint(
                  painter: const CarbonWeavePainter(
                    accentColor: Color(0xFF00E5FF),
                    baseColor: Color(0xFF14171E),
                    scanlineOpacity: 0.12,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF),
                                border: Border.all(color: Colors.black, width: 2.0),
                              ),
                              child: const Icon(
                                Icons.precision_manufacturing_rounded,
                                color: Colors.black,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('tuning_outsourced_banner_title'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    context.tr('tuning_outsourced_banner_subtitle'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          context.tr('tuning_outsourced_banner_desc'),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFFCBD5E1),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.toxicLime,
                                border: Border.all(color: Colors.black, width: 1.8),
                              ),
                              child: Text(
                                '${context.tr('common_level')} ${game.level}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${outsourcedState.activeOrders.length} ${context.tr('tuning_outsourced_active_count_label')}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00E5FF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Orders Section
            if (outsourcedState.activeOrders.isNotEmpty) ...[
              _buildSectionHeader(
                title: context.tr('tuning_outsourced_section_active_orders'),
                icon: Icons.timer_rounded,
                accentColor: AppColors.brutalYellow,
              ),
              const SizedBox(height: 12),
              ...outsourcedState.activeOrders.map((order) {
                final studio = OutsourcedTuningEngine.getStudioById(order.studioId);
                return _ActiveOrderCard(
                  order: order,
                  studio: studio,
                  formattedDuration: _formatDuration(order.remainingSeconds),
                  onSpeedup: () => _handleSpeedupAd(order),
                  onPickup: () => _handlePickupCar(order),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Studios Section
            _buildSectionHeader(
              title: context.tr('tuning_outsourced_section_studios'),
              icon: Icons.storefront_rounded,
              accentColor: const Color(0xFF00E5FF),
            ),
            const SizedBox(height: 12),

            ...OutsourcedTuningEngine.allStudios.map((studio) {
              final isUnlocked = game.level >= studio.minLevel;
              return _StudioCard(
                studio: studio,
                isUnlocked: isUnlocked,
                playerLevel: game.level,
                onSendCar: () => _openCarSelectionSheet(studio),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor,
            border: Border.all(color: Colors.black, width: 2.0),
          ),
          child: Icon(icon, size: 16, color: Colors.black),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// Active Order Live Card
class _ActiveOrderCard extends StatelessWidget {
  final TuningOrder order;
  final OutsourcedTuningStudio? studio;
  final String formattedDuration;
  final VoidCallback onSpeedup;
  final VoidCallback onPickup;

  const _ActiveOrderCard({
    required this.order,
    required this.studio,
    required this.formattedDuration,
    required this.onSpeedup,
    required this.onPickup,
  });

  @override
  Widget build(BuildContext context) {
    final studioName =
        studio != null ? context.tr(studio!.nameKey) : 'VIP Atölye';
    final isReady = order.isReadyForPickup;
    final progress = order.progressFraction;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isReady ? AppColors.toxicLime : const Color(0xFF262B3B),
            child: Row(
              children: [
                Icon(
                  isReady ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                  size: 18,
                  color: isReady ? Colors.black : Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isReady
                        ? context.tr('tuning_outsourced_status_ready')
                        : '${context.tr('tuning_outsourced_status_tuning')} • $studioName',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isReady ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                if (!isReady)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                    ),
                    child: Text(
                      formattedDuration,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E5FF),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${order.carBrand} ${order.carModelName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD600),
                        border: Border.all(color: Colors.black, width: 1.8),
                      ),
                      child: Text(
                        '+${CurrencyFormatter.formatShort(order.expectedValueGain)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0F14),
                    border: Border.all(color: Colors.black, width: 1.8),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          color: isReady
                              ? AppColors.toxicLime
                              : const Color(0xFF00E5FF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Action Buttons
                if (isReady)
                  NeoBrutalButton(
                    label: context.tr('tuning_outsourced_btn_pickup'),
                    backgroundColor: AppColors.toxicLime,
                    textColor: Colors.black,
                    icon: Icons.assignment_turned_in_rounded,
                    onPressed: onPickup,
                  )
                else ...[
                  if (order.speedupCount < 2)
                    NeoBrutalButton(
                      label:
                          '${context.tr('tuning_outsourced_btn_speedup')} • ${2 - order.speedupCount} Hak',
                      backgroundColor: const Color(0xFF00E5FF),
                      textColor: Colors.black,
                      icon: Icons.local_cafe_rounded,
                      onPressed: onSpeedup,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Studio Showcase Card
class _StudioCard extends StatelessWidget {
  final OutsourcedTuningStudio studio;
  final bool isUnlocked;
  final int playerLevel;
  final VoidCallback onSendCar;

  const _StudioCard({
    required this.studio,
    required this.isUnlocked,
    required this.playerLevel,
    required this.onSendCar,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(studio.colorThemeHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Studio Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: isUnlocked ? themeColor : const Color(0xFF333846),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.tr(studio.nameKey),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isUnlocked
                          ? (themeColor.computeLuminance() > 0.4
                              ? Colors.black
                              : Colors.white)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.black : const Color(0xFF1E222D),
                    border: Border.all(
                      color: isUnlocked ? Colors.white : Colors.black,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    isUnlocked
                        ? context.tr(studio.badgeKey)
                        : '${context.tr('common_level')} ${studio.minLevel}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isUnlocked ? themeColor : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const HazardStripeWidget(height: 4),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(studio.taglineKey),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr(studio.descKey),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFFCBD5E1),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Metrics Grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0F14),
                    border: Border.all(color: const Color(0xFF2A2E3D), width: 1.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(
                        title: context.tr('tuning_outsourced_metric_duration'),
                        value: '${studio.durationMinutes} ${context.tr('common_minutes_short')}',
                        accentColor: Colors.white,
                      ),
                      Container(width: 1, height: 28, color: const Color(0xFF2A2E3D)),
                      _buildMetricItem(
                        title: context.tr('tuning_outsourced_metric_hp_gain'),
                        value: '+%${((studio.hpMultiplier - 1.0) * 100).round()}',
                        accentColor: AppColors.toxicLime,
                      ),
                      Container(width: 1, height: 28, color: const Color(0xFF2A2E3D)),
                      _buildMetricItem(
                        title: context.tr('tuning_outsourced_metric_value_gain'),
                        value: '+%${((studio.valueGainMultiplier - 1.0) * 100).round()}',
                        accentColor: AppColors.brutalYellow,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Compatibility tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (studio.acceptedBrands.isEmpty && !studio.isClassicOnly && !studio.isExoticHyperOnly)
                      _buildTag(context.tr('tuning_outsourced_tag_all_cars'), AppColors.brutalYellow),
                    if (studio.acceptedBrands.isNotEmpty)
                      _buildTag(
                        '${context.tr('tuning_outsourced_tag_brands')} • ${studio.acceptedBrands.join(', ')}',
                        const Color(0xFF00E5FF),
                      ),
                    if (studio.isClassicOnly)
                      _buildTag(
                        context.tr('tuning_outsourced_tag_classics_only'),
                        const Color(0xFFFF9100),
                      ),
                    if (studio.isExoticHyperOnly)
                      _buildTag(
                        context.tr('tuning_outsourced_tag_hyper_only'),
                        const Color(0xFFE040FB),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action button
                if (isUnlocked)
                  NeoBrutalButton(
                    label: context.tr('tuning_outsourced_btn_send_car'),
                    backgroundColor: themeColor,
                    textColor: themeColor.computeLuminance() > 0.4 ? Colors.black : Colors.white,
                    icon: Icons.send_rounded,
                    onPressed: onSendCar,
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2430),
                      border: Border.all(color: Colors.black, width: 2.0),
                    ),
                    child: Center(
                      child: Text(
                        '${context.tr('common_level')} ${studio.minLevel} ${context.tr('tuning_outsourced_lbl_required')}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Car Picker Bottom Sheet
class _CarSelectionBottomSheet extends ConsumerStatefulWidget {
  final OutsourcedTuningStudio studio;
  final void Function(CarModel car) onCarSelected;

  const _CarSelectionBottomSheet({
    required this.studio,
    required this.onCarSelected,
  });

  @override
  ConsumerState<_CarSelectionBottomSheet> createState() =>
      _CarSelectionBottomSheetState();
}

class _CarSelectionBottomSheetState
    extends ConsumerState<_CarSelectionBottomSheet> {
  CarModel? _selectedCar;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final cars = game.ownedCars;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        border: const Border(
          top: BorderSide(color: Colors.black, width: 3.5),
          left: BorderSide(color: Colors.black, width: 3.5),
          right: BorderSide(color: Colors.black, width: 3.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, -4),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Color(widget.studio.colorThemeHex),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${context.tr(widget.studio.nameKey)} • ${context.tr('tuning_outsourced_select_car_title')}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(widget.studio.colorThemeHex).computeLuminance() > 0.4
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const HazardStripeWidget(height: 4),

            Expanded(
              child: cars.isEmpty
                  ? Center(
                      child: Text(
                        context.tr('tuning_outsourced_no_cars_in_garage'),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cars.length,
                      itemBuilder: (ctx, idx) {
                        final car = cars[idx];
                        final isAccepted = OutsourcedTuningEngine.isCarAccepted(
                          widget.studio,
                          car,
                          game.level,
                        );
                        final cost = OutsourcedTuningEngine.calculateCost(
                          widget.studio,
                          car,
                        );
                        final gain =
                            OutsourcedTuningEngine.calculateExpectedValueGain(
                          widget.studio,
                          cost,
                        );
                        final isSelected = _selectedCar?.id == car.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF232A3B)
                                : const Color(0xFF1A1E29),
                            border: Border.all(
                              color: isSelected
                                  ? Color(widget.studio.colorThemeHex)
                                  : (isAccepted
                                      ? const Color(0xFF333846)
                                      : const Color(0xFF262B38)),
                              width: isSelected ? 2.5 : 1.8,
                            ),
                          ),
                          child: InkWell(
                            onTap: isAccepted
                                ? () => setState(() => _selectedCar = car)
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${car.brand} ${car.modelName}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: isAccepted
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Color(widget.studio.colorThemeHex),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${car.modelYear} • ${car.bodyType} • ${CurrencyFormatter.format(car.baseMarketValue)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isAccepted
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  if (isAccepted) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${context.tr('tuning_outsourced_cost_label')}: ${CurrencyFormatter.format(cost)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFFFD600),
                                          ),
                                        ),
                                        Text(
                                          '${context.tr('tuning_outsourced_val_gain_label')}: +${CurrencyFormatter.format(gain)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.toxicLime,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    Text(
                                      _getIneligibleReason(context, car),
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (_selectedCar != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: NeoBrutalButton(
                  label: context.tr('tuning_outsourced_btn_confirm_order'),
                  backgroundColor: Color(widget.studio.colorThemeHex),
                  textColor: Color(widget.studio.colorThemeHex).computeLuminance() > 0.4
                      ? Colors.black
                      : Colors.white,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () {
                    final selected = _selectedCar!;
                    Navigator.pop(context);
                    widget.onCarSelected(selected);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getIneligibleReason(BuildContext context, CarModel car) {
    if (car.isOutsourcedTuning) {
      return context.tr('tuning_outsourced_reason_already_in_studio');
    }
    if (car.isListed) {
      return context.tr('tuning_outsourced_reason_car_listed');
    }
    if (car.isRented) {
      return context.tr('tuning_outsourced_reason_car_rented');
    }
    if (car.isPainting) {
      return context.tr('tuning_outsourced_reason_car_painting');
    }
    if (widget.studio.acceptedBrands.isNotEmpty) {
      return context.tr('tuning_outsourced_reason_brand_mismatch');
    }
    if (widget.studio.isClassicOnly) {
      return context.tr('tuning_outsourced_reason_classic_mismatch');
    }
    if (widget.studio.isExoticHyperOnly) {
      return context.tr('tuning_outsourced_reason_hyper_mismatch');
    }
    return context.tr('tuning_outsourced_reason_ineligible');
  }
}
