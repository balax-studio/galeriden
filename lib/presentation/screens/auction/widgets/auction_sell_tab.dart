import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/car_specifications.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/game_sound_haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/auction_model.dart';
import '../../../../data/models/car_model.dart';
import '../../../../domain/usecases/consignment_auction_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import 'auction_sell_live_view.dart';

class AuctionSellTab extends ConsumerStatefulWidget {
  final bool isDark;

  const AuctionSellTab({
    super.key,
    required this.isDark,
  });

  @override
  ConsumerState<AuctionSellTab> createState() => _AuctionSellTabState();
}

class _AuctionSellTabState extends ConsumerState<AuctionSellTab> {
  CarModel? _selectedCar;
  double _reservePrice = 0.0;
  ConsignmentAuctionModel? _activeAuction;
  Timer? _auctionTimer;
  bool _isSoldHandled = false;

  @override
  void dispose() {
    _auctionTimer?.cancel();
    super.dispose();
  }

  void _startAuction(CarModel car, double reservePrice) {
    HapticFeedback.heavyImpact();
    GameSoundHapticService.playAuctionHammer();

    final auction = ConsignmentAuctionEngine.createAuction(
      car: car,
      reservePrice: reservePrice,
    );

    setState(() {
      _activeAuction = auction;
      _isSoldHandled = false;
    });

    _auctionTimer?.cancel();
    _auctionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_activeAuction == null || _activeAuction!.isEnded) {
        timer.cancel();
        return;
      }

      final prevBid = _activeAuction!.currentBid;
      final prevGavel = _activeAuction!.gavelStage;
      final updated = ConsignmentAuctionEngine.tick(_activeAuction!);
      setState(() {
        _activeAuction = updated;
      });

      if (updated.currentBid > prevBid) {
        GameSoundHapticService.playAuctionBid();
      } else if (updated.gavelStage != prevGavel &&
          updated.gavelStage != AuctionGavelStage.ongoing) {
        GameSoundHapticService.playAuctionHammer();
      }

      if (updated.isEnded) {
        timer.cancel();
        if (updated.isSold && updated.highestBidder != null && !_isSoldHandled) {
          _isSoldHandled = true;
          ref.read(gameProvider.notifier).sellCarAtAuction(
                carId: updated.car.id,
                salePrice: updated.currentBid,
                commission: updated.commissionFee,
                fixedFee: updated.fixedFee,
                buyerName: updated.highestBidder!.name,
              );
        }
      }
    });
  }

  void _dismissAuctionResult() {
    _auctionTimer?.cancel();
    setState(() {
      _activeAuction = null;
      _selectedCar = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeAuction != null) {
      return AuctionSellLiveView(
        auction: _activeAuction!,
        isDark: widget.isDark,
        onDismissResult: _dismissAuctionResult,
      );
    }

    final game = ref.watch(gameProvider);
    final eligibleCars = game.ownedCars
        .where((c) => ConsignmentAuctionEngine.canListCar(c))
        .toList();

    if (eligibleCars.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(24),
            backgroundColor: widget.isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: widget.isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.no_crash_rounded,
                    size: 36,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('auction_sell_no_cars'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Auto-select first car if null or no longer exists
    if (_selectedCar == null || !eligibleCars.any((c) => c.id == _selectedCar!.id)) {
      _selectedCar = eligibleCars.first;
      _reservePrice = (_selectedCar!.estimatedRealValue * 0.70).roundToDouble();
    }

    final car = _selectedCar!;
    final minReserve = (car.estimatedRealValue * 0.50).roundToDouble();
    final maxReserve = (car.estimatedRealValue * 0.90).roundToDouble();
    final fees = ConsignmentAuctionEngine.calculateAuctionFees(_reservePrice);

    final hp = car.factoryHorsepower;
    final torque = car.factoryTorque;
    final accel = CarSpecifications.getFactoryZeroToHundred(car.brand, car.modelName, bodyType: car.bodyType);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. CAR SELECTION CAROUSEL / LIST
        Text(
          context.tr('auction_sell_select_car'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: widget.isDark ? Colors.white70 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: eligibleCars.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final c = eligibleCars[index];
              final isSelected = c.id == car.id;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedCar = c;
                    _reservePrice = (c.estimatedRealValue * 0.70).roundToDouble();
                  });
                },
                child: SizedBox(
                  width: 170,
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: isSelected
                        ? (widget.isDark ? const Color(0xFF1E2838) : const Color(0xFFEFF6FF))
                        : (widget.isDark ? const Color(0xFF141721) : Colors.white),
                    borderColor: isSelected
                        ? const Color(0xFF38BDF8)
                        : (widget.isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                    borderWidth: isSelected ? 2.5 : 1.5,
                    borderRadius: 10,
                    shadowOffset: isSelected ? const Offset(2, 2) : const Offset(1, 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${c.modelYear} ${c.brand}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          c.modelName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatShort(c.estimatedRealValue),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brutalGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // 2. VEHICLE SPECIFICATIONS AND INSPECTION REPORT CARD
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: widget.isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: widget.isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_rounded, size: 18, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('auction_sell_specs_title'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  NeoBrutalBadge(
                    text: context.tr(car.vehicleCategory.localizationKey).toUpperCase(),
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Factory Specs Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: context.tr('auction_sell_hp_label'),
                      value: '$hp HP',
                      icon: Icons.speed_rounded,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricTile(
                      label: context.tr('auction_sell_torque_label'),
                      value: '$torque Nm',
                      icon: Icons.offline_bolt_rounded,
                      color: const Color(0xFFFB923C),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricTile(
                      label: context.tr('auction_sell_accel_label'),
                      value: '${accel.toStringAsFixed(1)}s',
                      icon: Icons.timer_outlined,
                      color: const Color(0xFFA855F7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Condition & Inspection Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: context.tr('auction_sell_engine_label'),
                      value: '%${car.expertise.engineCondition.round()}',
                      icon: Icons.engineering_rounded,
                      color: car.expertise.engineCondition >= 80
                          ? AppColors.brutalGreen
                          : AppColors.errorRed,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricTile(
                      label: context.tr('auction_sell_transmission_label'),
                      value: '%${car.expertise.transmissionCondition.round()}',
                      icon: Icons.settings_rounded,
                      color: car.expertise.transmissionCondition >= 80
                          ? AppColors.brutalGreen
                          : AppColors.errorRed,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildMetricTile(
                      label: context.tr('auction_sell_tramer_label'),
                      value: CurrencyFormatter.formatShort(car.expertise.tramerAmount.toDouble()),
                      icon: Icons.receipt_long_rounded,
                      color: car.expertise.tramerAmount > 40000
                          ? AppColors.errorRed
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              if (car.isRare || car.isBarnFind || car.plateRarity != 'standard' || car.colorRarity != 'standard') ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (car.isRare)
                      NeoBrutalBadge(
                        text: context.tr('auction_sell_rare_badge'),
                        backgroundColor: const Color(0xFFA855F7),
                        textColor: Colors.white,
                      ),
                    if (car.isBarnFind)
                      NeoBrutalBadge(
                        text: context.tr('auction_sell_barn_find_badge'),
                        backgroundColor: const Color(0xFFD97706),
                        textColor: Colors.white,
                      ),
                    if (car.plateRarity != 'standard')
                      NeoBrutalBadge(
                        text: '${context.tr('auction_sell_special_plate_badge')} • ${car.plateNumber}',
                        backgroundColor: const Color(0xFF0F172A),
                        textColor: AppColors.brutalYellow,
                      ),
                    if (car.colorRarity != 'standard')
                      NeoBrutalBadge(
                        text: '${context.tr('auction_sell_special_color_badge')} • ${car.colorDisplayName}',
                        backgroundColor: const Color(0xFF2563EB),
                        textColor: Colors.white,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. RESERVE PRICE SLIDER CARD
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: widget.isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: widget.isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('auction_sell_reserve_price'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(_reservePrice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('auction_sell_reserve_desc'),
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.brutalGreen,
                  inactiveTrackColor: widget.isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                  thumbColor: AppColors.brutalYellow,
                  overlayColor: AppColors.brutalYellow.withValues(alpha: 0.2),
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                ),
                child: Slider(
                  value: _reservePrice.clamp(minReserve, maxReserve),
                  min: minReserve,
                  max: maxReserve,
                  divisions: 20,
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _reservePrice = (val / 1000.0).round() * 1000.0;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Min: ${CurrencyFormatter.formatShort(minReserve)} • %50',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Max: ${CurrencyFormatter.formatShort(maxReserve)} • %90',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. FINANCIAL BREAKDOWN CARD
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: widget.isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: widget.isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            children: [
              _buildFeeRow(
                label: context.tr('auction_sell_reserve_price'),
                amount: CurrencyFormatter.format(_reservePrice),
              ),
              _buildFeeRow(
                label: context.tr('auction_sell_commission'),
                amount: '-${CurrencyFormatter.format(fees.commission)}',
                color: AppColors.errorRed,
              ),
              _buildFeeRow(
                label: context.tr('auction_sell_fixed_fee'),
                amount: '-${CurrencyFormatter.format(fees.fixedFee)}',
                color: AppColors.errorRed,
              ),
              const Divider(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('auction_sell_estimated_net'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(fees.netPayout),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 5. START AUCTION BUTTON
        NeoBrutalButton(
          label: context.tr('auction_sell_start_btn'),
          backgroundColor: AppColors.brutalGreen,
          textColor: Colors.black,
          onPressed: () {
            _showConfirmationDialog(context, car, _reservePrice);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow({
    required String label,
    required String amount,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: widget.isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color ?? (widget.isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, CarModel car, double reservePrice) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: widget.isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                  ),
                  child: const Icon(Icons.gavel_rounded, size: 32, color: Colors.black),
                ),
                const SizedBox(height: 14),
                Text(
                  context.tr('auction_sell_confirm_title'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  '${car.modelYear} ${car.brand} ${car.modelName} • Muhammen: ${CurrencyFormatter.formatShort(reservePrice)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.isDark ? Colors.white70 : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('auction_sell_confirm_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        label: context.tr('btn_cancel'),
                        backgroundColor: const Color(0xFF64748B),
                        textColor: Colors.white,
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NeoBrutalButton(
                        label: context.tr('auction_sell_start_dialog_btn'),
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          _startAuction(car, reservePrice);
                        },
                      ),
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
