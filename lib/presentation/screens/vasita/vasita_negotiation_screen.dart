import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/usecases/vasita_negotiation_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/vasita_market_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import 'widgets/noter_transfer_dialog.dart';

class VasitaNegotiationScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const VasitaNegotiationScreen({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<VasitaNegotiationScreen> createState() =>
      _VasitaNegotiationScreenState();
}

class _VasitaNegotiationScreenState
    extends ConsumerState<VasitaNegotiationScreen> {
  late double _offeredPrice;
  int _sellerPatience = 100;
  int _bonusChancePercent = 0;
  final Set<String> _usedTacticIds = {};
  String _sellerDialogue = '';
  bool _isProcessing = false;
  bool _isAccepted = false;
  bool _isWalkaway = false;
  bool _isInspectionExpanded = false;

  @override
  void initState() {
    super.initState();
    _offeredPrice = (widget.listing.askingPrice * 0.90).roundToDouble();
    _sellerDialogue = VasitaNegotiationEngine.generateDynamicSellerDialogue(
      sellerName: widget.listing.sellerName,
      sellerTrait: widget.listing.sellerTrait,
      offeredPrice: _offeredPrice,
      askingPrice: widget.listing.askingPrice,
      patience: _sellerPatience,
    );
  }

  void _resetToAskingPrice() {
    if (_isAccepted || _isWalkaway || _isProcessing) return;
    HapticFeedback.selectionClick();
    setState(() {
      _offeredPrice = widget.listing.askingPrice;
    });
  }

  void _executeTactic(VasitaTactic tactic) {
    if (_usedTacticIds.contains(tactic.id) || _isAccepted || _isProcessing) return;
    if (_isWalkaway && !tactic.isRescue) return;

    final game = ref.read(gameProvider);
    final outcome = VasitaNegotiationEngine.rollTactic(
      tactic: tactic,
      listing: widget.listing,
      currentPatience: _sellerPatience,
      playerLevel: game.level,
    );

    setState(() {
      _usedTacticIds.add(tactic.id);
      _sellerPatience = (_sellerPatience + outcome.patienceChange).clamp(0, 100).toInt();
      _sellerDialogue = outcome.message;

      if (outcome.isSuccess) {
        _bonusChancePercent += tactic.baseBonusPercent;
        if (tactic.isRescue && _isWalkaway) {
          _isWalkaway = false;
        }
      } else if (outcome.isWalkaway) {
        _isWalkaway = true;
      }
    });

    HapticFeedback.heavyImpact();
    if (outcome.isWalkaway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(context, outcome.message);
    } else if (outcome.isSuccess) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(
        context,
        '${tactic.title} • ${context.tr('vasita_tactic_success_toast')}',
      );
    } else {
      GameSoundHapticService.playTapImpact();
      NotificationService.showWarning(
        context,
        '${tactic.title} • ${context.tr('vasita_tactic_failed_toast')}',
      );
    }
  }

  Future<void> _submitOffer() async {
    if (_isAccepted || _isWalkaway || _isProcessing) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Suspense delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final game = ref.read(gameProvider);
    final outcome = VasitaNegotiationEngine.evaluateOffer(
      listing: widget.listing,
      offeredPrice: _offeredPrice,
      currentPatience: _sellerPatience,
      playerLevel: game.level,
      extraBonusPercent: _bonusChancePercent / 100.0,
    );

    setState(() {
      _isProcessing = false;
      _sellerPatience = outcome.updatedPatience;
      _sellerDialogue = outcome.responseMessage;
      _isAccepted = outcome.isAccepted;
      _isWalkaway = outcome.isWalkaway;
    });

    if (outcome.isAccepted) {
      GameSoundHapticService.playCashSuccess();
      _showNoterTransferDialog();
    } else if (outcome.isWalkaway) {
      GameSoundHapticService.playWarningVibration();
    } else {
      GameSoundHapticService.playTapImpact();
    }
  }

  void _showNoterTransferDialog() {
    final game = ref.read(gameProvider);
    final noterFee = VasitaNegotiationEngine.calculateNoterFee(_offeredPrice);
    const regFee = VasitaNegotiationEngine.registrationFee;
    final isGarageFull = game.ownedCars.length >= game.maxGarageSlots;

    NoterTransferDialog.show(
      context: context,
      car: widget.listing.car,
      buyerName: game.playerName,
      sellerName: widget.listing.sellerName,
      agreedPrice: _offeredPrice,
      noterFee: noterFee,
      registrationFee: regFee,
      playerBalance: game.balance,
      isGarageFull: isGarageFull,
      onComplete: () {
        final success = ref.read(vasitaMarketProvider.notifier).buyVasitaNegotiated(
              listing: widget.listing,
              agreedPrice: _offeredPrice,
              noterFee: noterFee,
              registrationFee: regFee,
            );

        if (success) {
          if (mounted) {
            NotificationService.showSuccess(
              context,
              context.tr('noter_buy_success_toast'),
            );
            Navigator.of(context).pop();
          }
        } else {
          if (mounted) {
            NotificationService.showError(
              context,
              context.tr('noter_buy_error_funds'),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final car = widget.listing.car;
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final successChance = VasitaNegotiationEngine.calculateOfferSuccessProbability(
      listing: widget.listing,
      offeredPrice: _offeredPrice,
      patience: _sellerPatience,
      playerLevel: game.level,
      extraBonusPercent: _bonusChancePercent / 100.0,
    );

    final applicableTactics =
        VasitaNegotiationEngine.getTacticsForVehicle(car.vehicleCategory);

    final isGarageFull = game.ownedCars.length >= game.maxGarageSlots;

    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        appBar: NeoBrutalAppBar(
          title: context.tr('vasita_negotiation_title'),
          subtitle: '${car.brand} ${car.modelName}',
          showLeading: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: NeoBrutalBadge(
                  text: CurrencyFormatter.formatShort(game.balance),
                  icon: Icons.account_balance_wallet_rounded,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        body: NeoBrutalPageBackground(
          watermark: ThematicWatermarkType.carWash,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Vehicle & Seller Header Card
                _buildVehicleHeaderCard(car, isDark),
                const SizedBox(height: 12),

                // 2. Inspection & Expertise Card
                _buildExpertiseCard(car, isDark),
                const SizedBox(height: 12),

                // 3. Seller Card with Patience & Dialogue
                _buildSellerCard(isDark),
                const SizedBox(height: 14),

                // 4. Dealer Tactics Section
                _buildTacticsSection(applicableTactics, isDark),
                const SizedBox(height: 16),

                // 5. Offer & Slider Card
                _buildOfferControlCard(successChance, isDark),
                const SizedBox(height: 14),

                // 6. Action Button
                _buildActionButton(isGarageFull),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleHeaderCard(CarModel car, bool isDark) {
    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeoBrutalBadge(
                text: context.tr(car.vehicleCategory.localizationKey),
                icon: Icons.directions_car_filled_rounded,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white70 : Colors.black87,
                fontSize: 10,
              ),
              const SizedBox(width: 8),
              NeoBrutalBadge(
                text: car.plateNumber.isNotEmpty ? car.plateNumber : '34 GLR 101',
                icon: Icons.badge_rounded,
                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                textColor: isDark ? Colors.white : Colors.black,
                fontSize: 10,
              ),
              const Spacer(),
              Text(
                '${widget.listing.sellerCity} • ${widget.listing.sellerName}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${car.modelYear} ${car.brand} ${car.modelName}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            '${car.bodyType} • ${car.expertise.mileage} KM',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('deal_seller_asking_price'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                CurrencyFormatter.format(widget.listing.askingPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseCard(CarModel car, bool isDark) {
    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.fact_check_rounded, size: 18, color: Color(0xFF00E575)),
                  const SizedBox(width: 6),
                  Text(
                    context.tr('vasita_expertise_card_title'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _isInspectionExpanded = !_isInspectionExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isInspectionExpanded
                            ? context.tr('vasita_expertise_collapse')
                            : context.tr('vasita_expertise_expand'),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                      ),
                      Icon(
                        _isInspectionExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Condition Gauge Indicators
          Row(
            children: [
              Expanded(
                child: _buildConditionGauge(
                  context.tr('vasita_expertise_engine'),
                  car.expertise.engineCondition,
                  Icons.speed_rounded,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConditionGauge(
                  context.tr('vasita_expertise_transmission'),
                  car.expertise.transmissionCondition,
                  Icons.settings_rounded,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tramer & Odometer row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('vasita_expertise_tramer'),
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        car.expertise.tramerAmount > 0
                            ? CurrencyFormatter.format(car.expertise.tramerAmount.toDouble())
                            : context.tr('tramer_no_damage'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: car.expertise.tramerAmount > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('noter_field_mileage'),
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        car.expertise.isMileageTampered
                            ? context.tr('vasita_expertise_mileage_tampered')
                            : context.tr('vasita_expertise_mileage_verified'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: car.expertise.isMileageTampered ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Detailed Bodywork Panels (when expanded)
          if (_isInspectionExpanded) ...[
            const SizedBox(height: 10),
            Text(
              context.tr('vasita_expertise_parts_title'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: car.expertise.bodyParts.entries.map((entry) {
                final partName = entry.key;
                final status = entry.value;

                Color tagColor;
                String statusLabel;
                switch (status) {
                  case PartStatus.original:
                    tagColor = const Color(0xFF10B981);
                    statusLabel = context.tr('vasita_expertise_paint_original');
                    break;
                  case PartStatus.painted:
                    tagColor = const Color(0xFFF59E0B);
                    statusLabel = context.tr('vasita_expertise_paint_local');
                    break;
                  case PartStatus.changed:
                  case PartStatus.damaged:
                    tagColor = const Color(0xFFEF4444);
                    statusLabel = context.tr('vasita_expertise_paint_replaced');
                    break;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: tagColor.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Text(
                    '$partName • $statusLabel',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: tagColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConditionGauge(
    String label,
    double value,
    IconData icon,
    bool isDark,
  ) {
    final color = value >= 75
        ? const Color(0xFF10B981)
        : (value >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              ),
              const Spacer(),
              Text(
                '%${value.toInt()}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100.0).clamp(0.0, 1.0),
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(bool isDark) {
    Color patienceColor = const Color(0xFF10B981);
    if (_sellerPatience < 40) {
      patienceColor = const Color(0xFFEF4444);
    } else if (_sellerPatience < 70) {
      patienceColor = const Color(0xFFF59E0B);
    }

    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF3B82F6),
                child: const Icon(Icons.person_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.listing.sellerName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${widget.listing.sellerCity} • ${widget.listing.sellerTrait}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${context.tr('vasita_label_patience')}: %$_sellerPatience',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: patienceColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_sellerPatience / 100.0).clamp(0.0, 1.0),
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(patienceColor),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Speech Bubble
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _sellerDialogue,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
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

  Widget _buildTacticsSection(List<VasitaTactic> tactics, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('vasita_tactics_header'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            if (_bonusChancePercent > 0)
              Text(
                '${context.tr('vasita_label_bonus_chance')}: +%$_bonusChancePercent',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tactics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final tactic = tactics[index];
              final isUsed = _usedTacticIds.contains(tactic.id);
              final canUse = !isUsed && !_isAccepted && !_isProcessing && (!_isWalkaway || tactic.isRescue);

              return GestureDetector(
                onTap: canUse ? () => _executeTactic(tactic) : null,
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUsed
                        ? (isDark ? const Color(0xFF0C0E14) : const Color(0xFFE2E8F0))
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isUsed
                          ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF94A3B8))
                          : (canUse ? const Color(0xFF00E575) : const Color(0xFF64748B)),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            tactic.isRescue ? Icons.local_cafe_rounded : Icons.flash_on_rounded,
                            size: 16,
                            color: tactic.isRescue ? const Color(0xFFF59E0B) : const Color(0xFF00E575),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUsed
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : const Color(0xFF00E575).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isUsed ? context.tr('vasita_tactic_used') : tactic.badgeText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isUsed ? const Color(0xFF64748B) : const Color(0xFF00E575),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        tactic.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isUsed ? const Color(0xFF64748B) : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferControlCard(int successChance, bool isDark) {
    final askingPrice = widget.listing.askingPrice;
    final safeMax = askingPrice > 1000.0 ? askingPrice : 1000.0;
    final rawMin = (safeMax * 0.50).roundToDouble();
    final minOffer = rawMin < safeMax ? rawMin : (safeMax * 0.5);
    final maxOffer = safeMax;

    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('vasita_label_your_offer'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              ),
              Row(
                children: [
                  Text(
                    '${context.tr('vasita_label_success_chance')}: ',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  Text(
                    '%$successChance',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: successChance >= 70
                          ? const Color(0xFF10B981)
                          : (successChance >= 40 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Offer Amount & Reset Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(_offeredPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00E575),
                ),
              ),
              GestureDetector(
                onTap: _resetToAskingPrice,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    context.tr('vasita_btn_asking_price'),
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00E575),
              inactiveTrackColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF00E575),
              overlayColor: const Color(0xFF00E575).withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _offeredPrice.clamp(minOffer, maxOffer),
              min: minOffer,
              max: maxOffer,
              divisions: 50,
              onChanged: (_isAccepted || _isWalkaway || _isProcessing)
                  ? null
                  : (val) {
                      setState(() => _offeredPrice = (val / 1000).round() * 1000.0);
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isGarageFull) {
    if (_isAccepted) {
      return NeoBrutalButton(
        label: context.tr('vasita_btn_complete_noter'),
        icon: Icons.verified_user_rounded,
        fullWidth: true,
        backgroundColor: const Color(0xFF10B981),
        textColor: Colors.white,
        onPressed: _showNoterTransferDialog,
      );
    }

    if (_isWalkaway) {
      final hasRescueTea = !_usedTacticIds.contains('sanayi_cayi');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasRescueTea) ...[
            NeoBrutalButton(
              label: context.tr('vasita_btn_rescue_tea'),
              icon: Icons.local_cafe_rounded,
              fullWidth: true,
              backgroundColor: const Color(0xFFF59E0B),
              textColor: Colors.black,
              onPressed: () {
                final teaTactic = VasitaNegotiationEngine.allTactics.firstWhere((t) => t.id == 'sanayi_cayi');
                _executeTactic(teaTactic);
              },
            ),
            const SizedBox(height: 8),
          ],
          NeoBrutalButton(
            label: context.tr('vasita_btn_leave_table'),
            icon: Icons.exit_to_app_rounded,
            fullWidth: true,
            backgroundColor: const Color(0xFFEF4444),
            textColor: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    return NeoBrutalButton(
      label: _isProcessing
          ? '...'
          : (isGarageFull
              ? context.tr('vasita_btn_garage_full')
              : context.tr('vasita_btn_submit_offer')),
      icon: isGarageFull ? Icons.warehouse_rounded : Icons.send_rounded,
      fullWidth: true,
      backgroundColor: isGarageFull ? const Color(0xFF94A3B8) : const Color(0xFF00E575),
      textColor: Colors.black,
      onPressed: (_isProcessing || isGarageFull) ? null : _submitOffer,
    );
  }
}
