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
import '../../../domain/usecases/contractor_negotiation_expansion.dart';
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
  late RealEstateModel _land;
  late ContractorNegotiationProfile _currentContractor;
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final game = ref.read(gameProvider);
      _land = game.ownedRealEstates.firstWhere(
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
        parcelSquareMeters: _land.squareMeters.toDouble(),
        baseMarketValue: _land.baseMarketValue,
      );

      _currentContractor = ContractorNegotiationExpansion.contractors.first;

      _chatState = RealEstateChatNegotiationEngine.createContractorSession(
        landId: _land.id,
        totalUnits: _plan.totalUnits,
        baseMarketValue: _land.baseMarketValue,
        profile: _currentContractor,
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

  void _switchContractor(ContractorNegotiationProfile contractor) {
    if (_currentContractor.id == contractor.id) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentContractor = contractor;
      _chatState = RealEstateChatNegotiationEngine.createContractorSession(
        landId: _land.id,
        totalUnits: _plan.totalUnits,
        baseMarketValue: _land.baseMarketValue,
        profile: contractor,
      );
    });
    _scrollToBottom();
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
        title: _currentContractor.defaultName,
        onLeadingPressed: () => context.pop(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                NeoBrutalBadge(
                  text: context.tr('contractor_chat_share_badge', {
                    'percent': _chatState.currentSharePercent,
                  }),
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
          // 1. CONTRACTOR SELECTION TABS
          _buildContractorSelector(isDark),

          // 2. ACTIVE CONTRACTOR PROFILE & PATIENCE GAUGE
          _buildContractorHeaderCard(isDark),

          // 3. ARCHITECTURAL BLUEPRINT INFO BANNER
          _buildBlueprintBanner(isDark),

          // 4. CHAT MESSAGE LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: _chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = _chatState.messages[index];
                return _buildChatBubble(msg, isDark);
              },
            ),
          ),

          // 5. TACTICAL RESPONSE SHEET
          if (!_chatState.isAgreed && !_chatState.isWalkedAway)
            _buildActionPanel(isDark),
        ],
      ),
    );
  }

  Widget _buildContractorSelector(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: ContractorNegotiationExpansion.contractors.length,
        itemBuilder: (context, index) {
          final contractor = ContractorNegotiationExpansion.contractors[index];
          final isSelected = contractor.id == _currentContractor.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => _switchContractor(contractor),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? contractor.themeColor.withValues(alpha: 0.18)
                      : (isDark
                          ? const Color(0xFF0F172A)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.black38,
                    width: isSelected ? 2.2 : 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          const BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      contractor.avatarIcon,
                      size: 14,
                      color: contractor.themeColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      contractor.defaultName.split(' ').first,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: contractor.themeColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '%${contractor.initialOfferPercent}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContractorHeaderCard(bool isDark) {
    final patienceRatio =
        (_chatState.patience / _chatState.maxPatience).clamp(0.0, 1.0);
    final Color patienceColor = _chatState.patience > 50
        ? const Color(0xFF10B981)
        : (_chatState.patience > 25
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar Box
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _currentContractor.themeColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2.2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
                child: Icon(
                  _currentContractor.avatarIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Name, Subtitle and Star Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentContractor.defaultName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentContractor.defaultCompanyType,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${_currentContractor.reputationScore} / 5.0',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•  Maksimum Tavan: %${_currentContractor.maxCapPercent}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Patience Bar with Neo-Brutalist Frame
          Row(
            children: [
              Text(
                context.tr('contractor_patience_ratio', {
                  'cur': _chatState.patience,
                  'max': _chatState.maxPatience,
                }),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: patienceColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: patienceRatio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: patienceColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlueprintBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
              const Icon(
                Icons.architecture_rounded,
                size: 15,
                color: Color(0xFF2563EB),
              ),
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
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessageModel msg, bool isDark) {
    final isPlayer = msg.isFromPlayer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isPlayer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isPlayer) ...[
                Icon(
                  _currentContractor.avatarIcon,
                  size: 13,
                  color: _currentContractor.themeColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                msg.senderName,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPlayer
                  ? const Color(0xFF2563EB)
                  : (isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.black,
                width: 2.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2.5, 2.5),
                ),
              ],
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
                    height: 1.38,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: const Border(
          top: BorderSide(color: Colors.black, width: 2.5),
        ),
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
            spacing: 7,
            runSpacing: 7,
            children: [
              _buildTacticChip(
                icon: Icons.trending_up_rounded,
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
                icon: Icons.view_day_rounded,
                label: context.tr('contractor_tactic_prime_floors_label'),
                onTap: () => _applyTactic(
                  ChatTacticType.demandPrimeFloors,
                  context.tr('contractor_tactic_prime_floors_msg'),
                ),
                color: const Color(0xFFF3E8FF),
              ),
              _buildTacticChip(
                icon: Icons.verified_rounded,
                label: context.tr('contractor_tactic_quality_upgrade_label'),
                onTap: () => _applyTactic(
                  ChatTacticType.demandQualityUpgrade,
                  context.tr('contractor_tactic_quality_upgrade_msg'),
                ),
                color: const Color(0xFFFEF3C7),
              ),
              _buildTacticChip(
                icon: Icons.payments_rounded,
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
              _buildTacticChip(
                icon: Icons.security_rounded,
                label: context.tr('contractor_tactic_bank_guarantee_label'),
                onTap: () => _applyTactic(
                  ChatTacticType.demandBankGuarantee,
                  context.tr('contractor_tactic_bank_guarantee_msg'),
                ),
                color: const Color(0xFFE0E7FF),
              ),
              _buildTacticChip(
                icon: Icons.local_cafe_rounded,
                label: context.tr('contractor_tactic_tea_joke_label'),
                onTap: () => _applyTactic(
                  ChatTacticType.askJokeOrChat,
                  context.tr('contractor_tactic_tea_joke_msg'),
                ),
                color: const Color(0xFFD1FAE5),
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
    required IconData icon,
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
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.black87),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

