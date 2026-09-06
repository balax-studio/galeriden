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
import '../../../domain/usecases/real_estate_buyer_negotiation_expansion.dart';
import '../../../domain/usecases/real_estate_chat_negotiation_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/chat_typing_indicator_bubble.dart';
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
  bool _isApplying = false;
  bool _isOpponentTyping = false;
  bool _isTypingPaused = false;
  final Map<ChatTacticType, int> _tacticUseCounts = {};

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _applyTactic({
    required ChatTacticType tactic,
    required String playerMessage,
    required RealEstateCategory category,
  }) async {
    if (_isApplying || _isOpponentTyping || _chatState.isAgreed || _chatState.isWalkedAway) return;
    _isApplying = true;
    HapticFeedback.mediumImpact();

    final plan = RealEstateChatNegotiationEngine.evaluateTacticPlan(
      state: _chatState,
      tactic: tactic,
      playerMessageText: playerMessage,
      random: _random,
      propertyCategory: category,
    );
    if (plan == null) {
      _isApplying = false;
      return;
    }

    _tacticUseCounts[tactic] = (_tacticUseCounts[tactic] ?? 0) + 1;

    // 1. Oyuncu mesajını hemen ekrana ekle
    setState(() {
      _chatState = plan.stateWithPlayerMessageOnly;
      _isOpponentTyping = true;
      _isTypingPaused = false;
    });
    _scrollToBottom();

    // 2. Aşama 1: Karşı taraf yazıyor... (1100ms - 1700ms)
    final stage1Ms = 1100 + _random.nextInt(600);
    await Future.delayed(Duration(milliseconds: stage1Ms));
    if (!mounted) return;

    // 3. Aşama 2: Duraksama / Kaybolma (Düşünme gerilimi: 600ms - 1100ms)
    setState(() {
      _isTypingPaused = true;
    });
    final pauseMs = 600 + _random.nextInt(500);
    await Future.delayed(Duration(milliseconds: pauseMs));
    if (!mounted) return;

    // 4. Aşama 3: Tekrar yazıyor (1000ms - 1600ms)
    setState(() {
      _isTypingPaused = false;
    });
    final stage3Ms = 1000 + _random.nextInt(600);
    await Future.delayed(Duration(milliseconds: stage3Ms));
    if (!mounted) return;

    // 5. Aşama 4: Cevap ekrana düşer
    setState(() {
      _chatState = plan.finalState;
      _isOpponentTyping = false;
      _isTypingPaused = false;
      _isApplying = false;
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
      Future.delayed(const Duration(milliseconds: 700), () {
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
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) context.pop();
    });
  }

  String _resolvePatienceLabel(BuildContext context, int patience) {
    if (patience > 50) {
      return context.tr('buyer_chat_patience_normal');
    }
    if (patience > 20) {
      return context.tr('buyer_chat_patience_tense');
    }
    return context.tr('buyer_chat_patience_critical');
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

    final archetype = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
      _chatState.counterpartyName,
      prop.category,
    );

    final patienceText = _resolvePatienceLabel(context, _chatState.patience);
    final isPatienceCalm = _chatState.patience > 50;
    final isPatienceTense = _chatState.patience > 20 && !isPatienceCalm;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: _chatState.counterpartyName,
        subtitle: (_isOpponentTyping && !_isTypingPaused)
            ? '${context.tr(archetype.titleKey)} • ${context.tr('chat_status_typing')}'
            : '${context.tr(archetype.titleKey)} • ${context.tr('chat_status_online')}',
        onLeadingPressed: () => context.pop(),
        showHazardUnderline: true,
        headerAnimation: NeoBrutalHeaderAnimation.none,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Industrial Patience Plaque
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: isPatienceCalm
                        ? const Color(0xFFD1FAE5)
                        : (isPatienceTense
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFFEE2E2)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPatienceCalm
                            ? Icons.sentiment_satisfied_alt_rounded
                            : (isPatienceTense
                                ? Icons.sentiment_neutral_rounded
                                : Icons.warning_amber_rounded),
                        size: 13,
                        color: isPatienceCalm
                            ? const Color(0xFF065F46)
                            : (isPatienceTense
                                ? const Color(0xFF92400E)
                                : const Color(0xFF991B1B)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '%${_chatState.patience} • $patienceText',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: isPatienceCalm
                              ? const Color(0xFF065F46)
                              : (isPatienceTense
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF991B1B)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Glowing Mint Current Price Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    CurrencyFormatter.formatShort(_chatState.currentPrice),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tactical Property Placard Banner
          _buildPropertyBanner(
            context: context,
            prop: prop,
            archetype: archetype,
            isDark: isDark,
          ),

          // Negotiation Dialogue Scroll Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: _chatState.messages.length +
                  (_isOpponentTyping && !_isTypingPaused ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _chatState.messages.length) {
                  return ChatTypingIndicatorBubble(
                    senderName: _chatState.counterpartyName,
                    role: _chatState.counterpartyRole,
                    isDark: isDark,
                  );
                }
                final msg = _chatState.messages[index];
                return _buildMessageBubble(
                  context: context,
                  msg: msg,
                  archetype: archetype,
                  isDark: isDark,
                );
              },
            ),
          ),

          // Status Placard or Tactical Deck
          if (_chatState.isAgreed)
            _buildAgreedBanner(context)
          else if (_chatState.isWalkedAway)
            _buildWalkAwayBanner(context)
          else
            _buildTacticalDeck(
              context: context,
              prop: prop,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildPropertyBanner({
    required BuildContext context,
    required RealEstateModel prop,
    required BuyerArchetype archetype,
    required bool isDark,
  }) {
    final diff = prop.estimatedRealValue > 0
        ? ((_chatState.currentPrice - prop.estimatedRealValue) /
                prop.estimatedRealValue) *
            100
        : 0.0;
    final diffPrefix = diff >= 0 ? '+' : '';
    final diffText = '$diffPrefix${diff.toStringAsFixed(1)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Archetype Line
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: archetype.themeColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Icon(archetype.avatarIcon, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Text(
                context.tr(archetype.titleKey),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.tr(archetype.subtitleKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Property Title & Valuation Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${prop.title} • ${prop.district} • ${prop.squareMeters} m²',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Text(
                    '${context.tr('real_estate_showcase_btn_market_val')}: ${CurrencyFormatter.formatShort(prop.estimatedRealValue)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: diff >= 0
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: Text(
                      diffText,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: diff >= 0
                            ? const Color(0xFF065F46)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required BuildContext context,
    required ChatMessageModel msg,
    required BuyerArchetype archetype,
    required bool isDark,
  }) {
    final isPlayer = msg.isFromPlayer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender Header Tag
          if (isPlayer)
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('buyer_chat_player_role_tag'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.person_pin_rounded,
                    size: 13,
                    color: Color(0xFFEAB308),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    archetype.avatarIcon,
                    size: 13,
                    color: archetype.themeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${msg.senderName} • ${context.tr(archetype.titleKey)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

          // Dialogue Bubble Container
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isPlayer
                  ? const Color(0xFFFFDE59) // High-voltage Electric Yellow
                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: isPlayer
                      ? const Offset(-3.5, 3.5)
                      : const Offset(3.5, 3.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isPlayer ? FontWeight.w900 : FontWeight.w800,
                    color: isPlayer
                        ? Colors.black
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    height: 1.35,
                  ),
                ),
                if (msg.badgeText != null) ...[
                  const SizedBox(height: 8),
                  NeoBrutalBadge(
                    text: msg.badgeText!,
                    backgroundColor:
                        isPlayer ? Colors.black : const Color(0xFFFEF3C7),
                    textColor: isPlayer
                        ? const Color(0xFFFFDE59)
                        : const Color(0xFF92400E),
                    borderColor: Colors.black,
                    borderWidth: 1.5,
                    showHardShadow: !isPlayer,
                    shadowOffset: const Offset(1.5, 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreedBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3.5, 3.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${context.tr('buyer_chat_agreed_toast')} • ${CurrencyFormatter.format(_chatState.currentPrice)}',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalkAwayBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(3.5, 3.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(
            context.tr('buyer_chat_walkaway_toast'),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTacticalDeck({
    required BuildContext context,
    required RealEstateModel prop,
    required bool isDark,
  }) {
    final availableTactics = [
      (
        tactic: ChatTacticType.counterPrice,
        icon: Icons.trending_up_rounded,
        accentColor: const Color(0xFFFACC15),
      ),
      (
        tactic: ChatTacticType.transferDeedCosts,
        icon: Icons.description_rounded,
        accentColor: const Color(0xFF38BDF8),
      ),
      (
        tactic: ChatTacticType.demandCashDiscount,
        icon: Icons.account_balance_wallet_rounded,
        accentColor: const Color(0xFF4ADE80),
      ),
      (
        tactic: ChatTacticType.demandPrimeFloors,
        icon: Icons.location_city_rounded,
        accentColor: const Color(0xFFC084FC),
      ),
      (
        tactic: ChatTacticType.demandQualityUpgrade,
        icon: Icons.handshake_rounded,
        accentColor: const Color(0xFFFB923C),
      ),
      (
        tactic: ChatTacticType.askJokeOrChat,
        icon: Icons.coffee_rounded,
        accentColor: const Color(0xFFE0E7FF),
      ),
    ];

    final activeTactics = availableTactics.where((item) {
      final count = _tacticUseCounts[item.tactic] ?? 0;
      return !RealEstateBuyerNegotiationExpansion.isTacticExhausted(
        item.tactic,
        count,
      );
    }).toList();

    final isBlocked = _isApplying || _isOpponentTyping;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: const Border(
          top: BorderSide(color: Colors.black, width: 3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tactical Header Strip
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFEAB308)),
              const SizedBox(width: 4),
              Text(
                context.tr('buyer_chat_tactics_title'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Text(
                  context.tr('buyer_chat_patience_tense'),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dynamic Cycling Tactic Cards Strip or Exhaustion Notice
          if (activeTactics.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: Colors.black),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('buyer_tactics_exhausted_banner'),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: activeTactics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final item = activeTactics[i];
                  return _buildDynamicTacticCard(
                    context: context,
                    tactic: item.tactic,
                    icon: item.icon,
                    accentColor: item.accentColor,
                    category: prop.category,
                    isDark: isDark,
                  );
                },
              ),
            ),
          const SizedBox(height: 12),

          // Primary Accept / Reject Action Bar
          Row(
            children: [
              Expanded(
                flex: 3,
                child: NeoBrutalButton(
                  label:
                      '${context.tr('real_estate_offer_btn_accept')} • ${CurrencyFormatter.format(_chatState.currentPrice)}',
                  icon: Icons.check_circle_rounded,
                  backgroundColor: const Color(0xFF10B981),
                  textColor: Colors.white,
                  borderWidth: 2.5,
                  borderRadius: 8,
                  shadowOffset: const Offset(3.5, 3.5),
                  fontSize: 12.5,
                  minHeight: 50,
                  onPressed: isBlocked
                      ? null
                      : () => _applyTactic(
                            tactic: ChatTacticType.acceptAgreement,
                            playerMessage: context.tr('buyer_msg_accept'),
                            category: prop.category,
                          ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: NeoBrutalButton(
                  label: context.tr('real_estate_offer_btn_reject'),
                  icon: Icons.close_rounded,
                  backgroundColor: const Color(0xFFEF4444),
                  textColor: Colors.white,
                  borderWidth: 2.5,
                  borderRadius: 8,
                  shadowOffset: const Offset(3.5, 3.5),
                  fontSize: 12.5,
                  minHeight: 50,
                  onPressed: isBlocked
                      ? null
                      : () => _applyTactic(
                            tactic: ChatTacticType.walkAway,
                            playerMessage: context.tr('buyer_msg_reject'),
                            category: prop.category,
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicTacticCard({
    required BuildContext context,
    required ChatTacticType tactic,
    required IconData icon,
    required Color accentColor,
    required RealEstateCategory category,
    required bool isDark,
  }) {
    final count = _tacticUseCounts[tactic] ?? 0;
    String label;
    String message;
    int patienceImpact;

    if (tactic == ChatTacticType.askJokeOrChat) {
      label = context.tr('buyer_tactic_coffee_label');
      message = context.tr('buyer_tactic_coffee_msg');
      patienceImpact = -22; // negative delta means gain in evaluation
    } else {
      final step =
          RealEstateBuyerNegotiationExpansion.getTacticStep(tactic, count);
      label = context.tr(step.labelKey);
      message = tactic == ChatTacticType.counterPrice
          ? context.tr(step.messageKey, {
              'price': CurrencyFormatter.format(
                (_chatState.currentPrice * 1.05).roundToDouble(),
              ),
            })
          : context.tr(step.messageKey);
      patienceImpact = step.patienceCost;
    }

    final patienceBadgeText = tactic == ChatTacticType.askJokeOrChat
        ? '+%22'
        : '-%$patienceImpact';

    final isBlocked = _isApplying || _isOpponentTyping;

    return Opacity(
      opacity: isBlocked ? 0.5 : 1.0,
      child: InkWell(
        onTap: isBlocked
            ? null
            : () => _applyTactic(
                  tactic: tactic,
                  playerMessage: message,
                  category: category,
                ),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 172,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(2.5, 2.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Icon(icon, size: 13, color: Colors.black),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black54, width: 1),
                    ),
                    child: Text(
                      tactic == ChatTacticType.askJokeOrChat
                          ? patienceBadgeText
                          : '#${count + 1} • $patienceBadgeText',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: tactic == ChatTacticType.askJokeOrChat
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white70 : const Color(0xFF334155)),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
