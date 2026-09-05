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
import '../../../domain/usecases/architectural_yield_engine.dart';
import '../../../domain/usecases/real_estate_chat_negotiation_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';

class ContractorNegotiationChatScreen extends ConsumerStatefulWidget {
  final String landId;

  const ContractorNegotiationChatScreen({
    super.key,
    required this.landId,
  });

  @override
  ConsumerState<ContractorNegotiationChatScreen> createState() =>
      _ContractorNegotiationChatScreenState();
}

class _ContractorNegotiationChatScreenState
    extends ConsumerState<ContractorNegotiationChatScreen> {
  late ChatNegotiationState _chatState;
  late ArchitecturalProjectPlan _plan;
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final game = ref.read(gameProvider);
      final land = game.ownedRealEstates.firstWhere(
        (r) => r.id == widget.landId,
        orElse: () => RealEstateModel(
          id: widget.landId,
          title: 'Arsa Parseli',
          category: RealEstateCategory.land,
          city: 'İstanbul',
          district: 'Kadıköy',
          squareMeters: 800,
          roomCount: 'İmarlı Arsa',
          buildingAge: 0,
          deedType: DeedType.ownershipDeed,
          sellerType: RealEstateSellerType.individual,
          baseMarketValue: 6000000.0,
          currentPurchasePrice: 6000000.0,
        ),
      );

      _plan = ArchitecturalYieldEngine.generatePlan(
        parcelSquareMeters: land.squareMeters.toDouble(),
        baseMarketValue: land.baseMarketValue,
      );

      _chatState = RealEstateChatNegotiationEngine.createContractorSession(
        landId: land.id,
        contractorName: 'Metropol Yapı Mimarlık',
        totalUnits: _plan.totalUnits,
        baseMarketValue: land.baseMarketValue,
      );
      _isInitialized = true;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
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
        context.tr('contractor_chat_agreed_toast'),
      );
      _finalizeContract();
    } else if (_chatState.isWalkedAway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(
        context,
        context.tr('contractor_chat_walkaway_toast'),
      );
    }
  }

  void _finalizeContract() {
    final land = ref.read(gameProvider).ownedRealEstates.firstWhere(
          (r) => r.id == widget.landId,
        );

    ref.read(gameProvider.notifier).startContractorConstruction(
          land.id,
          sharePercent: _chatState.currentSharePercent,
        );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  context.tr('contractor_chat_patience_label', {'percent': _chatState.patience}),
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
                  text: context.tr('contractor_chat_share_badge', {'percent': _chatState.currentSharePercent}),
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
          // 1. ARCHITECTURAL BLUEPRINT INFO BANNER
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
                Row(
                  children: [
                    const Icon(Icons.architecture_rounded,
                        size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(
                      'KAKS ${_plan.kaks.toStringAsFixed(2)} • ${_plan.calculatedFloors} Kat • ${_plan.totalUnits} Daire',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
                Text(
                  _plan.summaryText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // 2. CHAT MESSAGE LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = _chatState.messages[index];
                return _buildChatBubble(msg, isDark);
              },
            ),
          ),

          // 3. TACTICAL RESPONSE SHEET
          if (!_chatState.isAgreed && !_chatState.isWalkedAway)
            _buildActionPanel(isDark),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel msg, bool isDark) {
    final isPlayer = msg.isFromPlayer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isPlayer ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(
                msg.senderName,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
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
                    height: 1.35,
                  ),
                ),
                if (msg.badgeText != null) ...[
                  const SizedBox(height: 8),
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
  }

  Widget _buildActionPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: const Border(top: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('contractor_chat_tactics_title'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTacticChip(
                label: context.tr('contractor_tactic_higher_share_label', {
                  'percent': _chatState.currentSharePercent + 3,
                }),
                onTap: () => _applyTactic(
                  ChatTacticType.demandHigherShare,
                  context.tr('contractor_tactic_higher_share_msg', {
                    'cur': _chatState.currentSharePercent,
                    'req': _chatState.currentSharePercent + 3,
                  }),
                ),
                color: const Color(0xFFEFF6FF),
              ),
              _buildTacticChip(
                label: context.tr('contractor_tactic_prime_floors_label'),
                onTap: () => _applyTactic(
                  ChatTacticType.demandPrimeFloors,
                  context.tr('contractor_tactic_prime_floors_msg'),
                ),
                color: const Color(0xFFF3E8FF),
              ),
              _buildTacticChip(
                label: context.tr('contractor_tactic_quality_upgrade_label'),
                onTap: () => _applyTactic(
                  ChatTacticType.demandQualityUpgrade,
                  context.tr('contractor_tactic_quality_upgrade_msg'),
                ),
                color: const Color(0xFFFEF3C7),
              ),
              _buildTacticChip(
                label: context.tr('contractor_tactic_advance_deposit_label', {
                  'amount': CurrencyFormatter.format(350000),
                }),
                onTap: () => _applyTactic(
                  ChatTacticType.demandAdvanceDeposit,
                  context.tr('contractor_tactic_advance_deposit_msg', {
                    'amount': CurrencyFormatter.format(350000),
                  }),
                ),
                color: const Color(0xFFFEE2E2),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: NeoBrutalButton(
                  text: context.tr('contractor_btn_sign_contract', {
                    'percent': _chatState.currentSharePercent,
                  }),
                  backgroundColor: const Color(0xFF10B981),
                  textColor: Colors.white,
                  onPressed: () => _applyTactic(
                    ChatTacticType.acceptAgreement,
                    context.tr('contractor_msg_accept'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              NeoBrutalButton(
                text: context.tr('contractor_btn_walk_away'),
                backgroundColor: const Color(0xFFEF4444),
                textColor: Colors.white,
                onPressed: () => _applyTactic(
                  ChatTacticType.walkAway,
                  context.tr('contractor_msg_walk_away'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTacticChip({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
