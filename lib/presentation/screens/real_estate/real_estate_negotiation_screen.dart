import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../domain/usecases/real_estate_chat_negotiation_engine.dart';
import '../../../domain/usecases/real_estate_negotiation_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/real_estate_market_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import 'widgets/real_estate_negotiation_log_box.dart';
import 'widgets/tapu_transfer_dialog.dart';

class RealEstateNegotiationScreen extends ConsumerStatefulWidget {
  final RealEstateListingModel listing;

  const RealEstateNegotiationScreen({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<RealEstateNegotiationScreen> createState() =>
      _RealEstateNegotiationScreenState();
}

class _RealEstateNegotiationScreenState
    extends ConsumerState<RealEstateNegotiationScreen> {
  late double _offeredPrice;
  late int _sellerPatience;
  String? _sellerDialogue;
  bool _isAccepted = false;
  bool _isWalkaway = false;
  bool _isProcessing = false;
  int _bonusChancePercent = 0;
  final Set<String> _usedTacticIds = {};
  RealEstateDiscrepancyInfo? _discrepancy;
  late RealEstateSellerPersonality _personality;

  // Real Estate Negotiation Log & Suspense
  final List<ChatMessageModel> _messages = [];
  bool _isThinking = false;
  String? _thinkingText;
  double? _counterOfferPrice;
  bool _isCounterOfferPending = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _offeredPrice = (widget.listing.askingPrice * 0.90).roundToDouble();
    _sellerPatience = 100;
    _personality = RealEstateNegotiationEngine.getSellerPersonality(widget.listing);
    _discrepancy = RealEstateNegotiationEngine.evaluateDiscrepancy(widget.listing);
    _sellerDialogue = RealEstateNegotiationEngine.generateDynamicSellerDialogue(
      sellerName: widget.listing.sellerName,
      sellerType: widget.listing.realEstate.sellerType,
      category: widget.listing.realEstate.category,
      offeredPrice: _offeredPrice,
      askingPrice: widget.listing.askingPrice,
      patience: _sellerPatience,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _messages.add(
        ChatMessageModel(
          id: 'start_${DateTime.now().millisecondsSinceEpoch}',
          senderName: context.tr('real_estate_badge_table_opened'),
          role: ChatSenderRole.seller,
          message: '${context.tr('real_estate_badge_table_opened')} • ${widget.listing.sellerName} • ${CurrencyFormatter.format(widget.listing.askingPrice)}',
          timestamp: DateTime.now(),
          isFromPlayer: false,
          badgeText: context.tr('real_estate_badge_table_opened'),
        ),
      );
      if (_sellerDialogue != null && _sellerDialogue!.isNotEmpty) {
        _messages.add(
          ChatMessageModel(
            id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
            senderName: widget.listing.sellerName,
            role: ChatSenderRole.seller,
            message: _sellerDialogue!,
            timestamp: DateTime.now(),
            isFromPlayer: false,
          ),
        );
      }
    }
  }

  void _snapToDiscount(double discountPercent) {
    if (_isAccepted || _isWalkaway || _isProcessing || _isThinking) return;
    HapticFeedback.selectionClick();
    setState(() {
      _offeredPrice =
          (widget.listing.askingPrice * (1.0 - discountPercent)).roundToDouble();
    });
  }

  void _executeTactic(RealEstateTactic tactic) {
    if (_usedTacticIds.contains(tactic.id) || _isAccepted || _isProcessing || _isThinking) return;
    if (_isWalkaway && !tactic.isRescue) return;

    final game = ref.read(gameProvider);
    final outcome = RealEstateNegotiationEngine.executeTactic(
      tactic: tactic,
      listing: widget.listing,
      currentPatience: _sellerPatience,
      playerLevel: game.level,
    );

    setState(() {
      _usedTacticIds.add(tactic.id);
      _sellerPatience = (_sellerPatience + outcome.patienceChange).clamp(0, 100);
      _sellerDialogue = outcome.message;

      if (outcome.isSuccess) {
        _bonusChancePercent += tactic.baseBonusPercent;
        if (tactic.isRescue && _isWalkaway) {
          _isWalkaway = false;
        }
      } else if (outcome.isWalkaway) {
        _isWalkaway = true;
      }

      // Add tactic events to log
      _messages.add(
        ChatMessageModel(
          id: 'tactic_${DateTime.now().millisecondsSinceEpoch}',
          senderName: ref.read(gameProvider).playerName,
          role: ChatSenderRole.player,
          message: '${tactic.title} • ${tactic.description}',
          timestamp: DateTime.now(),
          isFromPlayer: true,
          badgeText: outcome.isSuccess
              ? context.tr('real_estate_badge_tactic_success')
              : context.tr('real_estate_badge_tactic_failed'),
        ),
      );
      _messages.add(
        ChatMessageModel(
          id: 'tactic_res_${DateTime.now().millisecondsSinceEpoch}',
          senderName: widget.listing.sellerName,
          role: ChatSenderRole.seller,
          message: outcome.message,
          timestamp: DateTime.now(),
          isFromPlayer: false,
        ),
      );
    });

    HapticFeedback.heavyImpact();
    if (outcome.isWalkaway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(context, outcome.message);
    } else if (outcome.isSuccess) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(
        context,
        '${tactic.title} • ${context.tr('real_estate_tactic_success_toast')}',
      );
    } else {
      GameSoundHapticService.playTapImpact();
      NotificationService.showWarning(
        context,
        '${tactic.title} • ${context.tr('real_estate_tactic_failed_toast')}',
      );
    }
  }

  Future<void> _submitOffer() async {
    if (_isAccepted || _isWalkaway || _isProcessing || _isThinking) return;

    setState(() {
      _isProcessing = true;
      _isThinking = true;
      _isCounterOfferPending = false;
      _counterOfferPrice = null;
      _messages.add(
        ChatMessageModel(
          id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
          senderName: ref.read(gameProvider).playerName,
          role: ChatSenderRole.player,
          message: '${context.tr('real_estate_msg_offer_placed')}: ${CurrencyFormatter.format(_offeredPrice)}',
          timestamp: DateTime.now(),
          isFromPlayer: true,
          badgeText: context.tr('real_estate_badge_offer'),
        ),
      );
    });
    HapticFeedback.mediumImpact();

    // Suspense Thinking steps (3 steps x ~700ms = 2.1s total)
    final steps = RealEstateNegotiationEngine.getThinkingSteps();
    for (int i = 0; i < steps.length; i++) {
      if (!mounted) return;
      setState(() {
        _thinkingText = context.tr(steps[i]);
      });
      HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 700));
    }

    if (!mounted) return;

    final game = ref.read(gameProvider);
    final outcome = RealEstateNegotiationEngine.evaluateOffer(
      listing: widget.listing,
      offeredPrice: _offeredPrice,
      currentPatience: _sellerPatience,
      playerLevel: game.level,
      extraBonusPercent: _bonusChancePercent / 100.0,
      personality: _personality,
    );

    setState(() {
      _isProcessing = false;
      _isThinking = false;
      _thinkingText = null;
      _sellerPatience = outcome.updatedPatience;
      _sellerDialogue = outcome.responseMessage;
      _isAccepted = outcome.isAccepted;
      _isWalkaway = outcome.isWalkaway;

      if (outcome.isAccepted) {
        _messages.add(
          ChatMessageModel(
            id: 'accept_${DateTime.now().millisecondsSinceEpoch}',
            senderName: widget.listing.sellerName,
            role: ChatSenderRole.seller,
            message: outcome.responseMessage,
            timestamp: DateTime.now(),
            isFromPlayer: false,
            badgeText: context.tr('real_estate_badge_accepted'),
          ),
        );
      } else if (outcome.isCounterOffer && outcome.counterOfferPrice != null) {
        _counterOfferPrice = outcome.counterOfferPrice;
        _isCounterOfferPending = true;
        _messages.add(
          ChatMessageModel(
            id: 'counter_${DateTime.now().millisecondsSinceEpoch}',
            senderName: widget.listing.sellerName,
            role: ChatSenderRole.seller,
            message: outcome.responseMessage,
            timestamp: DateTime.now(),
            isFromPlayer: false,
            badgeText: context.tr('real_estate_badge_counter_offer'),
          ),
        );
      } else if (outcome.isWalkaway) {
        _messages.add(
          ChatMessageModel(
            id: 'walk_${DateTime.now().millisecondsSinceEpoch}',
            senderName: widget.listing.sellerName,
            role: ChatSenderRole.seller,
            message: outcome.responseMessage,
            timestamp: DateTime.now(),
            isFromPlayer: false,
            badgeText: context.tr('real_estate_badge_walkaway'),
          ),
        );
      } else {
        // Rejection with reason
        final rejectText = outcome.rejectionReason != null
            ? '${outcome.responseMessage} • ${outcome.rejectionReason}'
            : outcome.responseMessage;
        _messages.add(
          ChatMessageModel(
            id: 'reject_${DateTime.now().millisecondsSinceEpoch}',
            senderName: widget.listing.sellerName,
            role: ChatSenderRole.seller,
            message: rejectText,
            timestamp: DateTime.now(),
            isFromPlayer: false,
            badgeText: context.tr('real_estate_badge_rejected'),
          ),
        );
      }
    });

    if (outcome.isAccepted) {
      GameSoundHapticService.playCashSuccess();
      _showClosingDeedDialog();
    } else if (outcome.isCounterOffer) {
      GameSoundHapticService.playTapImpact();
      HapticFeedback.heavyImpact();
    } else if (outcome.isWalkaway) {
      GameSoundHapticService.playWarningVibration();
      HapticFeedback.vibrate();
    } else {
      GameSoundHapticService.playWarningVibration();
      HapticFeedback.mediumImpact();
    }
  }

  void _acceptCounterOffer() {
    if (_counterOfferPrice == null || _isProcessing || _isThinking || _isAccepted) return;
    HapticFeedback.heavyImpact();
    final agreedPrice = _counterOfferPrice!;
    setState(() {
      _offeredPrice = agreedPrice;
      _isAccepted = true;
      _isCounterOfferPending = false;
      _messages.add(
        ChatMessageModel(
          id: 'acc_counter_${DateTime.now().millisecondsSinceEpoch}',
          senderName: ref.read(gameProvider).playerName,
          role: ChatSenderRole.player,
          message: '${context.tr('real_estate_msg_counter_accepted')}: ${CurrencyFormatter.format(agreedPrice)}',
          timestamp: DateTime.now(),
          isFromPlayer: true,
          badgeText: context.tr('real_estate_badge_accepted'),
        ),
      );
    });
    GameSoundHapticService.playCashSuccess();
    _showClosingDeedDialog();
  }

  void _continueNegotiation() {
    if (_isProcessing || _isThinking || _isAccepted) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (_counterOfferPrice != null) {
        _offeredPrice = ((_offeredPrice + _counterOfferPrice!) / 2).roundToDouble();
      }
      _isCounterOfferPending = false;
    });
  }

  void _showClosingDeedDialog() {
    final game = ref.read(gameProvider);
    final deedFee = (_offeredPrice * 0.04).roundToDouble();
    final commission = widget.listing.realEstate.sellerType == RealEstateSellerType.agency
        ? (_offeredPrice * 0.02).roundToDouble()
        : 0.0;

    TapuTransferDialog.show(
      context: context,
      realEstate: widget.listing.realEstate,
      buyerName: game.playerName,
      sellerName: widget.listing.sellerName,
      playerBalance: game.balance,
      agreedPrice: _offeredPrice,
      deedFee: deedFee,
      revolvingFundFee: RealEstateListingModel.revolvingFundFee,
      commission: commission,
      onComplete: () {
        final success = ref.read(gameProvider.notifier).purchaseRealEstate(
              listing: widget.listing,
              finalPrice: _offeredPrice,
              deedFee: deedFee,
              commission: commission,
            );

        if (success) {
          ref
              .read(realEstateMarketProvider.notifier)
              .removeListing(widget.listing.id);
          NotificationService.showSuccess(
            context,
            context.tr('real_estate_buy_success_toast'),
          );
          Navigator.of(context).pop();
        } else {
          NotificationService.showError(
            context,
            context.tr('real_estate_buy_error_insufficient_funds'),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = ref.watch(gameProvider);
    final askingPrice = widget.listing.askingPrice;

    final currentChance = RealEstateNegotiationEngine.calculateBuyerSuccessChance(
      askingPrice: askingPrice,
      offeredPrice: _offeredPrice,
      playerLevel: game.level,
      sellerType: widget.listing.realEstate.sellerType,
      extraBonusPercent: _bonusChancePercent / 100.0,
    );

    return Scaffold(
      appBar: NeoBrutalAppBar(
        title: context.tr('real_estate_negotiation_title'),
        subtitle: context.tr('real_estate_negotiation_subtitle'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Property Specifications Card
              _buildPropertySpecsCard(theme),
              const SizedBox(height: 12),

              // Seller & Patience Card
              _buildSellerCard(theme),
              const SizedBox(height: 12),

              // Real Estate Negotiation Log Box (Pazarlık Tutanağı)
              RealEstateNegotiationLogBox(
                messages: _messages,
                isThinking: _isThinking,
                thinkingText: _thinkingText,
                height: 220,
              ),
              const SizedBox(height: 14),

              // Counter-offer Banner (if pending)
              if (_isCounterOfferPending && _counterOfferPrice != null) ...[
                _buildCounterOfferBanner(theme),
                const SizedBox(height: 14),
              ],

              // Tactics Action Bar
              _buildTacticsSection(theme),
              const SizedBox(height: 14),

              // Discount Preset Buttons & Custom Slider
              _buildOfferControls(theme, currentChance),
              const SizedBox(height: 16),

              // Submit Offer Button
              _buildSubmitButton(currentChance),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySpecsCard(ThemeData theme) {
    final re = widget.listing.realEstate;
    return NeoBrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: re.category.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: re.category.accentColor, width: 2),
                ),
                child: Icon(re.category.icon, color: re.category.accentColor, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      re.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${re.city} • ${re.district}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Badges Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              NeoBrutalBadge(
                text: '${re.squareMeters} m²',
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              NeoBrutalBadge(
                text: re.roomCount,
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              NeoBrutalBadge(
                text: '${re.buildingAge} ${context.tr('real_estate_badge_years_old')}',
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              NeoBrutalBadge(
                text: context.tr(re.deedType.localizationKey),
                backgroundColor: re.deedType == DeedType.ownershipDeed
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEF3C7),
              ),
              if (widget.listing.isHotDeal)
                NeoBrutalBadge(
                  text: context.tr('real_estate_badge_hot_deal'),
                  backgroundColor: const Color(0xFFFEE2E2),
                ),
            ],
          ),

          // Discrepancy Note if present
          if (_discrepancy != null && _discrepancy!.hasDiscrepancy) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_discrepancy!.title} • ${_discrepancy!.description}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('real_estate_label_asking_price'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              Text(
                CurrencyFormatter.format(widget.listing.askingPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(ThemeData theme) {
    Color patienceColor = const Color(0xFF10B981);
    if (_sellerPatience < 25) {
      patienceColor = const Color(0xFFEF4444);
    } else if (_sellerPatience < 60) {
      patienceColor = const Color(0xFFF59E0B);
    }

    final isPatienceCritical = _sellerPatience < 25 && !_isWalkaway && !_isAccepted;

    return NeoBrutalCard(
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
                      widget.listing.sellerName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          context.tr(widget.listing.realEstate.sellerType.localizationKey),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        NeoBrutalBadge(
                          text: context.tr(_personality.localizationKey),
                          backgroundColor: _personality == RealEstateSellerPersonality.urgent
                              ? const Color(0xFFD1FAE5)
                              : (_personality == RealEstateSellerPersonality.stubborn
                                  ? const Color(0xFFFEE2E2)
                                  : const Color(0xFFE0E7FF)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              NeoBrutalBadge(
                text: '$_sellerPatience%',
                backgroundColor: patienceColor.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Patience Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _sellerPatience / 100.0,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(patienceColor),
            ),
          ),

          // Critical patience alert indicator
          if (isPatienceCritical) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.tr('real_estate_alert_patience_critical'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCounterOfferBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake_rounded, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('real_estate_label_counter_offer_alert'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
              NeoBrutalBadge(
                text: CurrencyFormatter.format(_counterOfferPrice!),
                backgroundColor: const Color(0xFFFDE68A),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: NeoBrutalButton(
                  label: context.tr('real_estate_btn_accept_counter'),
                  icon: Icons.check_circle_outline_rounded,
                  backgroundColor: const Color(0xFF10B981),
                  onPressed: (_isAccepted || _isProcessing || _isThinking) ? null : _acceptCounterOffer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NeoBrutalButton(
                  label: context.tr('real_estate_btn_continue_bargain'),
                  icon: Icons.refresh_rounded,
                  backgroundColor: const Color(0xFFE2E8F0),
                  onPressed: (_isAccepted || _isProcessing || _isThinking) ? null : _continueNegotiation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTacticsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('real_estate_tactics_header'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
            if (_bonusChancePercent > 0)
              Text(
                '+$_bonusChancePercent% ${context.tr('real_estate_label_bonus_chance')}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: RealEstateNegotiationEngine.allTactics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final tactic = RealEstateNegotiationEngine.allTactics[index];
              final isUsed = _usedTacticIds.contains(tactic.id);
              final isAgencyOnly = tactic.id == 'komisyonu_kir';
              final isSellerAgency =
                  widget.listing.realEstate.sellerType == RealEstateSellerType.agency;
              final isEnabled = !isUsed &&
                  !_isAccepted &&
                  !_isProcessing &&
                  (!isAgencyOnly || isSellerAgency) &&
                  (!_isWalkaway || tactic.isRescue);

              return Opacity(
                opacity: isEnabled ? 1.0 : 0.45,
                child: SizedBox(
                  width: 145,
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: InkWell(
                      onTap: isEnabled ? () => _executeTactic(tactic) : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: tactic.isRescue
                                      ? const Color(0xFFFDE047)
                                      : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              child: Icon(
                                  tactic.isRescue
                                      ? Icons.local_cafe_rounded
                                      : Icons.flash_on_rounded,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  tactic.badgeText,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tactic.title,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferControls(ThemeData theme, int currentChance) {
    final minPrice = (widget.listing.askingPrice * 0.70).roundToDouble();
    final maxPrice = widget.listing.askingPrice.toDouble();

    return NeoBrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('real_estate_label_your_offer'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              Text(
                '${context.tr('real_estate_label_success_chance')}: $currentChance%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: currentChance > 50
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Center(
            child: Text(
              CurrencyFormatter.format(_offeredPrice),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Preset Percentage Buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildPresetButton(context.tr('real_estate_btn_asking_price'), 0.0),
              _buildPresetButton('-%5', 0.05),
              _buildPresetButton('-%10', 0.10),
              _buildPresetButton('-%15', 0.15),
              _buildPresetButton('-%20', 0.20),
            ],
          ),
          const SizedBox(height: 10),

          // Interactive Offer Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFF59E0B),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: Colors.black,
              overlayColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _offeredPrice.clamp(minPrice, maxPrice),
              min: minPrice,
              max: maxPrice,
              onChanged: (_isAccepted || _isWalkaway || _isProcessing || _isThinking)
                  ? null
                  : (val) {
                      setState(() {
                        _offeredPrice = (val / 10000).round() * 10000.0;
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String label, double discount) {
    return OutlinedButton(
      onPressed: (_isAccepted || _isWalkaway || _isProcessing || _isThinking)
          ? null
          : () => _snapToDiscount(discount),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }

  Widget _buildSubmitButton(int currentChance) {
    if (_isAccepted) {
      return NeoBrutalButton(
        label: context.tr('tapu_btn_complete_transfer'),
        icon: Icons.verified_user_rounded,
        fullWidth: true,
        onPressed: _showClosingDeedDialog,
        backgroundColor: const Color(0xFF10B981),
      );
    }

    if (_isWalkaway) {
      final canRescue = !_usedTacticIds.contains('sozlesme_kahvesi');
      return NeoBrutalButton(
        label: canRescue
            ? context.tr('real_estate_btn_rescue_coffee')
            : context.tr('real_estate_btn_leave_table'),
        icon: canRescue ? Icons.coffee_rounded : Icons.exit_to_app_rounded,
        fullWidth: true,
        onPressed: () {
          final rescueTactic = RealEstateNegotiationEngine.allTactics
              .firstWhere((t) => t.isRescue);
          if (!_usedTacticIds.contains(rescueTactic.id)) {
            _executeTactic(rescueTactic);
          } else {
            Navigator.of(context).pop();
          }
        },
        backgroundColor: const Color(0xFFEF4444),
      );
    }

    return NeoBrutalButton(
      label: context.tr('real_estate_btn_submit_offer'),
      icon: Icons.handshake_rounded,
      fullWidth: true,
      isLoading: _isProcessing || _isThinking,
      onPressed: (_isProcessing || _isThinking) ? null : _submitOffer,
      backgroundColor: const Color(0xFFF59E0B),
    );
  }
}
