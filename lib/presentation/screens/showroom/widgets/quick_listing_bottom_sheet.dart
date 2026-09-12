import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

/// Tactile Neo-Brutalist bottom sheet prompting player to immediately list their newly acquired vehicle.
class QuickListingBottomSheet extends ConsumerStatefulWidget {
  final CarModel car;

  const QuickListingBottomSheet({
    super.key,
    required this.car,
  });

  static Future<bool?> show(BuildContext context, {required CarModel car}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickListingBottomSheet(car: car),
    );
  }

  @override
  ConsumerState<QuickListingBottomSheet> createState() =>
      _QuickListingBottomSheetState();
}

class _QuickListingBottomSheetState
    extends ConsumerState<QuickListingBottomSheet> {
  late double _selectedPrice;
  bool _applyDopingWithAd = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final fairVal = widget.car.estimatedRealValue;
    // Default recommended price: Fair market value + 15% profit
    final recommended = (fairVal * 1.15 / 500).round() * 500.0;
    _selectedPrice = recommended.clamp(
      widget.car.currentPurchasePrice + 2000.0,
      fairVal * 1.40,
    );
  }

  void _adjustPrice(double delta) {
    setState(() {
      final minP = widget.car.currentPurchasePrice + 1000.0;
      final maxP = widget.car.estimatedRealValue * 1.50;
      _selectedPrice = (_selectedPrice + delta).clamp(minP, maxP);
    });
  }

  Future<void> _handleConfirmListing() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final carId = widget.car.id;

    if (_applyDopingWithAd) {
      AdService.instance.showRewardedAdWithFallback(
        context: context,
        customRewardTitle: context.tr('tuning_outsourced_btn_speedup'),
        onRewardEarned: () {
          _finalizeListing(carId, applyDoping: true);
        },
      );
    } else {
      _finalizeListing(carId, applyDoping: false);
    }
  }

  void _finalizeListing(String carId, {required bool applyDoping}) {
    ref.read(gameProvider.notifier).updateCarListingDetails(
          carId,
          customPrice: _selectedPrice,
        );

    if (applyDoping) {
      final updatedCar = widget.car.copyWith(isDoped: true);
      ref.read(gameProvider.notifier).updateCar(updatedCar);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
      NotificationService.showSuccess(
        context,
        context.tr('quick_listing_success_toast'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final estimatedProfit = _selectedPrice - widget.car.currentPurchasePrice;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 3.0,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Title & Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
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
                        context.tr('quick_listing_title'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('quick_listing_subtitle'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vehicle summary card
            NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? const Color(0xFF1A202C) : const Color(0xFFF8FAFC),
              borderColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFCBD5E1),
              borderRadius: 12,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D3748) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black26,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.brutalCyan,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.car.brand} ${widget.car.modelName}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${context.tr('quick_listing_bought_for')} ${CurrencyFormatter.formatShort(widget.car.currentPurchasePrice)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.toxicLime,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Text(
                      '+${CurrencyFormatter.formatShort(estimatedProfit)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Price Stepper Card
            NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
              borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              borderRadius: 14,
              child: Column(
                children: [
                  Text(
                    context.tr('quick_listing_asking_price_label'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(_selectedPrice),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepButton(label: '-10k', delta: -10000.0, isDark: isDark),
                      const SizedBox(width: 8),
                      _buildStepButton(label: '-2.5k', delta: -2500.0, isDark: isDark),
                      const SizedBox(width: 8),
                      _buildStepButton(label: '+2.5k', delta: 2500.0, isDark: isDark),
                      const SizedBox(width: 8),
                      _buildStepButton(label: '+10k', delta: 10000.0, isDark: isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Doping Rewarded Option Toggle
            GestureDetector(
              onTap: () {
                setState(() => _applyDopingWithAd = !_applyDopingWithAd);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _applyDopingWithAd
                      ? (isDark ? const Color(0xFF2E1C0C) : const Color(0xFFFFFBEB))
                      : (isDark ? const Color(0xFF181C26) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _applyDopingWithAd
                        ? AppColors.brutalOrange
                        : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
                    width: 2.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _applyDopingWithAd
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      color: _applyDopingWithAd
                          ? AppColors.brutalOrange
                          : (isDark ? Colors.white60 : Colors.black54),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('quick_listing_doping_title'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            context.tr('quick_listing_doping_desc'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.brutalOrange,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black, width: 1.2),
                      ),
                      child: Text(
                        context.tr('quick_listing_doping_badge'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            NeoBrutalButton(
              label: context.tr('quick_listing_btn_confirm'),
              icon: Icons.rocket_launch_rounded,
              backgroundColor: AppColors.toxicLime,
              textColor: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fullWidth: true,
              onPressed: _isProcessing ? null : _handleConfirmListing,
            ),
            const SizedBox(height: 8),
            NeoBrutalButton(
              label: context.tr('quick_listing_btn_later'),
              icon: Icons.access_time_rounded,
              backgroundColor: isDark ? const Color(0xFF202637) : const Color(0xFFE2E8F0),
              textColor: isDark ? Colors.white70 : const Color(0xFF334155),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton({
    required String label,
    required double delta,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _adjustPrice(delta),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A3142) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF3E485F) : const Color(0xFF94A3B8),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
