import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../domain/usecases/real_estate_chat_negotiation_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';

class RealEstateBuyerNegotiationChatScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String offerId;

  const RealEstateBuyerNegotiationChatScreen({
    super.key,
    required this.propertyId,
    required this.offerId,
  });

  @override
  ConsumerState<RealEstateBuyerNegotiationChatScreen> createState() =>
      _RealEstateBuyerNegotiationChatScreenState();
}

class _RealEstateBuyerNegotiationChatScreenState
    extends ConsumerState<RealEstateBuyerNegotiationChatScreen> {
  late ChatNegotiationState _chatState;
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final game = ref.read(gameProvider);
      final prop = game.ownedRealEstates.firstWhere(
        (r) => r.id == widget.propertyId,
      );
      final offer = prop.activeOffers.firstWhere(
        (o) => o.id == widget.offerId,
        orElse: () => prop.activeOffers.isNotEmpty
            ? prop.activeOffers.first
            : throw StateError('Offer not found'),
      );

      _chatState = RealEstateChatNegotiationEngine.createBuyerSession(
        propertyId: prop.id,
        buyerName: offer.buyerName,
        offeredPrice: offer.offeredAmount,
        buyerNote: offer.buyerNote,
        isRental: prop.isRented,
      );
      _isInitialized = true;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _applyTactic(ChatTacticType tactic, String playerMessage) {
    HapticFeedback.mediumImpact();
    setState(() {
      _chatState = RealEstateChatNegotiationEngine.executeTactic(
        state: _chatState,
        tactic: tactic,
        playerMessageText: playerMessage,
        random: _random,
      );
    });
    _scrollToBottom();

    if (_chatState.isAgreed) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(
        context,
        context.tr('buyer_chat_agreed_toast'),
      );
      _finalizeSale();
    } else if (_chatState.isWalkedAway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(
        context,
        context.tr('buyer_chat_walkaway_toast'),
      );
      ref.read(gameProvider.notifier).rejectRealEstateOffer(
            realEstateId: widget.propertyId,
            offerId: widget.offerId,
          );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) context.pop();
      });
    }
  }

  void _finalizeSale() {
    ref.read(gameProvider.notifier).acceptRealEstateOffer(
          realEstateId: widget.propertyId,
          offerId: widget.offerId,
          customAgreedPrice: _chatState.currentPrice,
        );
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final prop = game.ownedRealEstates.firstWhere(
      (r) => r.id == widget.propertyId,
      orElse: () => RealEstateModel(
        id: widget.propertyId,
        title: 'Gayrimenkul',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 100,
        roomCount: '2+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 4000000.0,
        currentPurchasePrice: 4000000.0,
      ),
    );

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: _chatState.counterpartyName,
        onLeadingPressed: () => context.pop(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Text(
                  '${context.tr('vasita_label_patience')}: %${_chatState.patience}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _chatState.patience > 40
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 8),
                NeoBrutalBadge(
                  text: CurrencyFormatter.formatShort(_chatState.currentPrice),
                  backgroundColor: const Color(0xFFD1FAE5),
                  textColor: const Color(0xFF065F46),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Property summary banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              border: const Border(
                bottom: BorderSide(color: Colors.black12, width: 1.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${prop.title} • ${prop.squareMeters} m²',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                Text(
                  '${context.tr('real_estate_showcase_btn_market_val')}: ${CurrencyFormatter.format(prop.estimatedRealValue)}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = _chatState.messages[index];
                final isPlayer = msg.isFromPlayer;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: isPlayer
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.senderName,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPlayer
                              ? const Color(0xFF2563EB)
                              : (isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPlayer
                                ? const Color(0xFF1D4ED8)
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1)),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.message,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isPlayer
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            if (msg.badgeText != null) ...[
                              const SizedBox(height: 6),
                              NeoBrutalBadge(
                                text: msg.badgeText!,
                                backgroundColor: const Color(0xFFFEF3C7),
                                textColor: const Color(0xFF92400E),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Tactical action panel
          if (!_chatState.isAgreed && !_chatState.isWalkedAway)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: const Border(
                    top: BorderSide(color: Colors.black, width: 2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTacticChip(
                        label: context.tr('buyer_tactic_counter_label'),
                        onTap: () => _applyTactic(
                          ChatTacticType.counterPrice,
                          context.tr('buyer_tactic_counter_msg', {
                            'price': CurrencyFormatter.format((_chatState.currentPrice * 1.05).roundToDouble()),
                          }),
                        ),
                      ),
                      _buildTacticChip(
                        label: context.tr('buyer_tactic_deed_cost_label'),
                        onTap: () => _applyTactic(
                          ChatTacticType.transferDeedCosts,
                          context.tr('buyer_tactic_deed_cost_msg'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: NeoBrutalButton(
                          label:
                              '${context.tr('real_estate_offer_btn_accept')} • ${CurrencyFormatter.format(_chatState.currentPrice)}',
                          backgroundColor: const Color(0xFF10B981),
                          textColor: Colors.white,
                          onPressed: () => _applyTactic(
                            ChatTacticType.acceptAgreement,
                            context.tr('buyer_msg_accept'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      NeoBrutalButton(
                        label: context.tr('real_estate_offer_btn_reject'),
                        backgroundColor: const Color(0xFFEF4444),
                        textColor: Colors.white,
                        onPressed: () => _applyTactic(
                          ChatTacticType.walkAway,
                          context.tr('buyer_msg_reject'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTacticChip(
      {required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
