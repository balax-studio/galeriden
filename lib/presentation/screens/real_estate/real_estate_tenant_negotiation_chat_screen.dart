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
import '../../../data/models/tenant_model.dart';
import '../../../domain/usecases/real_estate_chat_negotiation_engine.dart';
import '../../../domain/usecases/real_estate_tenant_negotiation_expansion.dart';
import '../../providers/game_provider.dart';
import '../../widgets/chat_typing_indicator_bubble.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_button.dart';

class RealEstateTenantNegotiationChatScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String candidateId;
  final TenantModel? candidate;

  const RealEstateTenantNegotiationChatScreen({
    super.key,
    required this.propertyId,
    required this.candidateId,
    this.candidate,
  });

  @override
  ConsumerState<RealEstateTenantNegotiationChatScreen> createState() =>
      _RealEstateTenantNegotiationChatScreenState();
}

class _RealEstateTenantNegotiationChatScreenState
    extends ConsumerState<RealEstateTenantNegotiationChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  late TenantModel _currentTenant;
  late TenantArchetype _archetype;
  late double _negotiatedRent;
  late double _negotiatedDeposit;
  int _patience = 100;
  int _satisfaction = 50;
  bool _isAgreed = false;
  bool _isWalkedAway = false;
  bool _isApplying = false;
  bool _isOpponentTyping = false;
  bool _isTypingPaused = false;

  final List<ChatMessageModel> _messages = [];
  final Map<TenantTacticType, int> _tacticUseCounts = {};

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  void _initSession() {
    final game = ref.read(gameProvider);
    final prop = game.ownedRealEstates.firstWhere(
      (r) => r.id == widget.propertyId,
      orElse: () => RealEstateModel(
        id: widget.propertyId,
        title: 'Kiralık Mülk',
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

    if (widget.candidate != null) {
      _currentTenant = widget.candidate!;
    } else {
      final baseMonthly = (prop.estimatedRealValue *
              prop.category.dailyRentYieldRate *
              30)
          .roundToDouble();
      final candidates = TenantModel.generateCandidates(
        baseMonthlyRent: baseMonthly > 0 ? baseMonthly : 15000.0,
        count: 1,
      );
      _currentTenant = candidates.first;
    }

    _archetype = RealEstateTenantNegotiationExpansion.detectTenantArchetype(
      _currentTenant.profession,
      _currentTenant.name,
    );

    _negotiatedRent = _currentTenant.monthlyRent;
    _negotiatedDeposit = _currentTenant.depositAmount;

    // Initial opening thought / greeting message
    final openingText = _currentTenant.evaluationThought.isNotEmpty
        ? _currentTenant.evaluationThought
        : 'İlanınızı inceledim • Şartlarda uzlaşırsak uzun vadeli ve düzenli bir kiracı olmak isterim.';

    _messages.add(
      ChatMessageModel(
        id: 'msg_tenant_0',
        senderName: _currentTenant.name,
        role: ChatSenderRole.tenant,
        message: openingText,
        timestamp: DateTime.now(),
        isFromPlayer: false,
        badgeText: 'KİRA TEKLİFİ • ${CurrencyFormatter.format(_negotiatedRent)}',
      ),
    );
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
    required TenantTacticType tactic,
    required String playerMessage,
  }) async {
    if (_isApplying || _isOpponentTyping || _isAgreed || _isWalkedAway) return;
    _isApplying = true;
    HapticFeedback.mediumImpact();

    final count = _tacticUseCounts[tactic] ?? 0;
    _tacticUseCounts[tactic] = count + 1;

    // 1. Add player message immediately
    setState(() {
      _messages.add(
        ChatMessageModel(
          id: 'msg_player_${DateTime.now().millisecondsSinceEpoch}',
          senderName: context.tr('tenant_chat_player_role_tag'),
          role: ChatSenderRole.player,
          message: playerMessage,
          timestamp: DateTime.now(),
          isFromPlayer: true,
        ),
      );
      _isOpponentTyping = true;
      _isTypingPaused = false;
    });
    _scrollToBottom();

    // 2. Evaluate tactic outcome
    final outcome = RealEstateTenantNegotiationExpansion.evaluateTactic(
      tactic: tactic,
      currentRent: _negotiatedRent,
      currentDeposit: _negotiatedDeposit,
      patience: _patience,
      satisfaction: _satisfaction,
      archetype: _archetype,
      useCount: count,
      random: _random,
    );

    // 3. Stage 1: Typing animation (1100ms - 1700ms)
    final stage1Ms = 1100 + _random.nextInt(600);
    await Future.delayed(Duration(milliseconds: stage1Ms));
    if (!mounted) return;

    // 4. Stage 2: Pause / Kaybolma (Düşünme gerilimi: 600ms - 1100ms)
    setState(() {
      _isTypingPaused = true;
    });
    final pauseMs = 600 + _random.nextInt(500);
    await Future.delayed(Duration(milliseconds: pauseMs));
    if (!mounted) return;

    // 5. Stage 3: Typing resumes (1000ms - 1600ms)
    setState(() {
      _isTypingPaused = false;
    });
    final stage3Ms = 1000 + _random.nextInt(600);
    await Future.delayed(Duration(milliseconds: stage3Ms));
    if (!mounted) return;

    // 6. Stage 4: Deliver counterparty message & update numbers
    setState(() {
      _patience = (_patience + outcome.patienceDelta).clamp(0, 100);
      _satisfaction = (_satisfaction + outcome.satisfactionDelta).clamp(0, 100);
      _negotiatedRent = outcome.nextRent;
      _negotiatedDeposit = outcome.nextDeposit;
      _isAgreed = outcome.isAgreed;
      _isWalkedAway = outcome.isWalkedAway;

      if (_patience <= 0 && !_isAgreed) {
        _isWalkedAway = true;
      }

      String finalReply = outcome.replyText;
      String? finalBadge = outcome.replyBadge;
      if (_isWalkedAway && !outcome.isWalkedAway) {
        finalReply =
            'Görüşmelerde ortak bir noktada buluşamadık ve sabrım tükendi • Masadan kalkıyorum, iyi günler dilerim.';
        finalBadge = 'MASADAN KALKILDI';
      }

      _messages.add(
        ChatMessageModel(
          id: 'msg_tenant_${DateTime.now().millisecondsSinceEpoch}',
          senderName: _currentTenant.name,
          role: ChatSenderRole.tenant,
          message: finalReply,
          timestamp: DateTime.now(),
          isFromPlayer: false,
          badgeText: finalBadge,
        ),
      );

      _isOpponentTyping = false;
      _isTypingPaused = false;
      _isApplying = false;
    });
    _scrollToBottom();

    if (_isAgreed) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(
        context,
        context.tr('tenant_chat_agreed_toast'),
      );
      _finalizeLease();
    } else if (_isWalkedAway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(
        context,
        context.tr('tenant_chat_walkaway_toast'),
      );
      ref.read(gameProvider.notifier).rejectTenantCandidate(
            propertyId: widget.propertyId,
            candidateId: widget.candidateId,
          );
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) context.pop();
      });
    }
  }

  void _finalizeLease() {
    final updatedTenant = _currentTenant.copyWith(
      monthlyRent: _negotiatedRent,
      depositAmount: _negotiatedDeposit,
    );
    ref.read(gameProvider.notifier).leaseRealEstateToTenant(
          realEstateId: widget.propertyId,
          tenant: updatedTenant,
          force: true,
        );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) context.pop(true);
    });
  }

  String _resolvePatienceLabel(BuildContext context, int patience) {
    if (patience > 50) {
      return context.tr('tenant_chat_patience_normal');
    }
    if (patience > 20) {
      return context.tr('tenant_chat_patience_tense');
    }
    return context.tr('tenant_chat_patience_critical');
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
        title: 'Kiralık Mülk',
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

    final patienceText = _resolvePatienceLabel(context, _patience);
    final isPatienceCalm = _patience > 50;
    final isPatienceTense = _patience > 20 && !isPatienceCalm;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: _currentTenant.name,
        subtitle: (_isOpponentTyping && !_isTypingPaused)
            ? '${context.tr(_archetype.titleKey)} • ${context.tr('chat_status_typing')}'
            : '${context.tr(_archetype.titleKey)} • ${context.tr('chat_status_online')}',
        onLeadingPressed: () => context.pop(),
        showHazardUnderline: true,
        headerAnimation: NeoBrutalHeaderAnimation.none,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Patience Indicator Badge
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
                        '%$_patience • $patienceText',
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

                // Agreed Rent Badge
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
                    CurrencyFormatter.formatShort(_negotiatedRent),
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
          // Property Overview Header Strip
          _buildPropertyBanner(
            context: context,
            prop: prop,
            archetype: _archetype,
            isDark: isDark,
          ),

          // Main Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
              itemCount: _messages.length +
                  (_isOpponentTyping && !_isTypingPaused ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return ChatTypingIndicatorBubble(
                    senderName: _currentTenant.name,
                    role: ChatSenderRole.tenant,
                    isDark: isDark,
                  );
                }
                final msg = _messages[index];
                return _buildMessageBubble(
                  context: context,
                  msg: msg,
                  archetype: _archetype,
                  isDark: isDark,
                );
              },
            ),
          ),

          // Agreement or Walkaway Banner
          if (_isAgreed)
            _buildAgreementBanner(context)
          else if (_isWalkedAway)
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
    required TenantArchetype archetype,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
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
                  fontSize: 11,
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
              Text(
                'Depozito: ${CurrencyFormatter.formatShort(_negotiatedDeposit)}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                ),
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
    required TenantArchetype archetype,
    required bool isDark,
  }) {
    final isPlayer = msg.isFromPlayer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Header Tag
          if (isPlayer)
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('tenant_chat_player_role_tag'),
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
                    Icons.home_work_rounded,
                    size: 13,
                    color: Color(0xFF10B981),
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

          // Speech Bubble Card
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isPlayer
                  ? const Color(0xFF10B981)
                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
                bottomLeft: Radius.circular(isPlayer ? 10 : 2),
                bottomRight: Radius.circular(isPlayer ? 2 : 10),
              ),
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
              crossAxisAlignment:
                  isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (msg.badgeText != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPlayer
                          ? Colors.black
                          : archetype.themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isPlayer ? Colors.white70 : Colors.black,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      msg.badgeText!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isPlayer ? Colors.white : Colors.black,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
                Text(
                  msg.message,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isPlayer
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementBanner(BuildContext context) {
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
              '${context.tr('tenant_chat_agreed_toast')} • ${CurrencyFormatter.format(_negotiatedRent)} / ay',
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
            context.tr('tenant_chat_walkaway_toast'),
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
    final availableDeck =
        RealEstateTenantNegotiationExpansion.getAvailableDeck(_tacticUseCounts);

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
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFEAB308)),
              const SizedBox(width: 4),
              Text(
                context.tr('tenant_chat_tactics_title'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dynamic Cycling Tactic Cards Strip
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: availableDeck.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final card = availableDeck[i];
                return _buildDynamicTacticCard(
                  context: context,
                  card: card,
                  isDark: isDark,
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Direct Accept / Reject Action Bar
          Row(
            children: [
              Expanded(
                flex: 3,
                child: NeoBrutalButton(
                  label:
                      '${context.tr('tenant_btn_sign_lease')} • ${CurrencyFormatter.format(_negotiatedRent)}',
                  icon: Icons.drive_file_rename_outline_rounded,
                  backgroundColor: const Color(0xFF10B981),
                  textColor: Colors.white,
                  borderWidth: 2.5,
                  borderRadius: 8,
                  shadowOffset: const Offset(3.5, 3.5),
                  fontSize: 12,
                  minHeight: 48,
                  onPressed: _isApplying
                      ? null
                      : () => _applyTactic(
                            tactic: TenantTacticType.acceptLease,
                            playerMessage:
                                'Tüm şartlar üzerinde anlaştık • Kira kontratını imzalıyoruz, mülkünüz hayırlı olsun!',
                          ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: NeoBrutalButton(
                  label: context.tr('tenant_btn_walk_away'),
                  icon: Icons.close_rounded,
                  backgroundColor: const Color(0xFFEF4444),
                  textColor: Colors.white,
                  borderWidth: 2.5,
                  borderRadius: 8,
                  shadowOffset: const Offset(3.5, 3.5),
                  fontSize: 12,
                  minHeight: 48,
                  onPressed: _isApplying
                      ? null
                      : () => _applyTactic(
                            tactic: TenantTacticType.walkAway,
                            playerMessage:
                                'Şartlarımız uyuşmuyor • Bu koşullarda kiralama yapamayız, iyi günler.',
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
    required TenantTacticCard card,
    required bool isDark,
  }) {
    final count = _tacticUseCounts[card.type] ?? 0;
    final label = context.tr(card.labelKey);

    String message;
    if (card.type == TenantTacticType.offerRentDiscount) {
      final discountStr =
          CurrencyFormatter.format((_negotiatedRent * 0.05).roundToDouble());
      message = context.tr(card.messageKey, {'discount': discountStr});
    } else {
      message = context.tr(card.messageKey);
    }

    final patienceBadge = card.patienceCost <= 0
        ? '+%22'
        : '-%${card.patienceCost}';

    return InkWell(
      onTap: _isApplying
          ? null
          : () => _applyTactic(
                tactic: card.type,
                playerMessage: message,
              ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 175,
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
                    color: card.accentColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Icon(card.icon, size: 13, color: Colors.black),
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
                    card.patienceCost <= 0
                        ? patienceBadge
                        : '#${count + 1} • $patienceBadge',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: card.patienceCost <= 0
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
    );
  }
}
