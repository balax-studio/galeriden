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
import '../../../domain/usecases/construction_timeline_engine.dart';
import '../../../domain/usecases/real_estate_chat_negotiation_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/chat_typing_indicator_bubble.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class SubcontractorNegotiationChatScreen extends ConsumerStatefulWidget {
  final String landId;

  const SubcontractorNegotiationChatScreen({
    super.key,
    required this.landId,
  });

  @override
  ConsumerState<SubcontractorNegotiationChatScreen> createState() =>
      _SubcontractorNegotiationChatScreenState();
}

class _SubcontractorNegotiationChatScreenState
    extends ConsumerState<SubcontractorNegotiationChatScreen> {
  int _selectedStage = 1;
  SubcontractorProfile? _activeSubcontractor;
  ChatNegotiationState? _chatState;
  bool _isApplying = false;
  bool _isOpponentTyping = false;
  bool _isTypingPaused = false;
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final list = ref.read(gameProvider).ownedRealEstates;
      final idx = list.indexWhere((r) => r.id == widget.landId);
      if (idx != -1 && mounted) {
        setState(() {
          _selectedStage = list[idx].constructionStage.clamp(1, 8);
        });
      }
    });
  }

  void _startChatWithSubcontractor(SubcontractorProfile sub, double stageCost) {
    final land = ref.read(gameProvider).ownedRealEstates.firstWhere(
          (r) => r.id == widget.landId,
          orElse: () => RealEstateModel(
            id: widget.landId,
            title: 'Arsa Parseli',
            category: RealEstateCategory.land,
            city: 'İstanbul',
            district: 'Ataşehir',
            squareMeters: 1000,
            roomCount: 'İmarlı Arsa',
            buildingAge: 0,
            deedType: DeedType.ownershipDeed,
            sellerType: RealEstateSellerType.individual,
            baseMarketValue: 8000000.0,
            currentPurchasePrice: 8000000.0,
          ),
        );

    final modeString = sub.tier == SubcontractorTier.speed
        ? context.tr('subcontractor_mode_speed')
        : sub.tier == SubcontractorTier.budget
            ? context.tr('subcontractor_mode_budget')
            : context.tr('subcontractor_mode_meticulous');

    setState(() {
      _activeSubcontractor = sub;
      _isApplying = false;
      _isOpponentTyping = false;
      _isTypingPaused = false;
      _chatState = ChatNegotiationState(
        targetId: '${widget.landId}_stage_$_selectedStage',
        counterpartyName: sub.name,
        counterpartyRole: ChatSenderRole.subcontractor,
        patience: 100,
        satisfaction: 60,
        currentPrice: stageCost * sub.costMultiplier,
        minPrice: (stageCost * sub.costMultiplier * 0.75).roundToDouble(),
        messages: [
          ChatMessageModel(
            id: 'msg_0',
            senderName: sub.name,
            role: ChatSenderRole.subcontractor,
            message: context.tr('subcontractor_msg_initial', {
              'mode': modeString,
              'cost': CurrencyFormatter.format(stageCost * sub.costMultiplier),
              'days': ConstructionTimelineEngine.calculateStageDays(
                stageNumber: _selectedStage,
                parcelSquareMeters: land.squareMeters.toDouble(),
                tier: sub.tier,
              ),
            }),
            timestamp: DateTime.now(),
            isFromPlayer: false,
            badgeText: context.tr('subcontractor_badge_initial_offer'),
          ),
        ],
      );
    });
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

  Future<void> _applyTactic(ChatTacticType tactic, String playerMessage) async {
    if (_chatState == null || _isApplying || _isOpponentTyping || _chatState!.isAgreed || _chatState!.isWalkedAway) return;
    _isApplying = true;
    HapticFeedback.mediumImpact();

    final plan = RealEstateChatNegotiationEngine.evaluateTacticPlan(
      state: _chatState!,
      tactic: tactic,
      playerMessageText: playerMessage,
      random: _random,
    );
    if (plan == null) {
      _isApplying = false;
      return;
    }

    // 1. Oyuncu mesajını hemen ekrana ekle
    setState(() {
      _chatState = plan.stateWithPlayerMessageOnly;
      _isOpponentTyping = true;
      _isTypingPaused = false;
    });
    _scrollToBottom();

    // 2. Asama 1: Yaziyor animasyonu (1100ms - 1700ms)
    final stage1Ms = 1100 + _random.nextInt(600);
    await Future.delayed(Duration(milliseconds: stage1Ms));
    if (!mounted) return;

    // 3. Asama 2: Duraksama / Kaybolma (Dusunme gerilimi: 600ms - 1100ms)
    setState(() {
      _isTypingPaused = true;
    });
    final pauseMs = 600 + _random.nextInt(500);
    await Future.delayed(Duration(milliseconds: pauseMs));
    if (!mounted) return;

    // 4. Asama 3: Tekrar yaziyor (1000ms - 1600ms)
    setState(() {
      _isTypingPaused = false;
    });
    final stage3Ms = 1000 + _random.nextInt(600);
    await Future.delayed(Duration(milliseconds: stage3Ms));
    if (!mounted) return;

    // 5. Asama 4: Karsi tarafin cevabini teslim et
    setState(() {
      _chatState = plan.finalState;
      _isOpponentTyping = false;
      _isTypingPaused = false;
      _isApplying = false;
    });
    _scrollToBottom();

    if (_chatState!.isAgreed) {
      _confirmStageStart();
    } else if (_chatState!.isWalkedAway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(
        context,
        context.tr('subcontractor_toast_walkaway'),
      );
    }
  }

  void _confirmStageStart() {
    final properties = ref.read(gameProvider).ownedRealEstates;
    final idx = properties.indexWhere((r) => r.id == widget.landId);
    if (idx == -1) {
      NotificationService.showError(context, context.tr('real_estate_not_found'));
      context.pop();
      return;
    }
    final land = properties[idx];

    final success = ref.read(gameProvider.notifier).startSelfBuildStage(
          land.id,
          subcontractor: _activeSubcontractor,
          customStageCost: _chatState?.currentPrice,
        );

    if (!success) {
      NotificationService.showError(
        context,
        context.tr('subcontractor_stage_start_failed'),
      );
      return;
    }

    GameSoundHapticService.playCashSuccess();
    NotificationService.showSuccess(
      context,
      context.tr('subcontractor_toast_agreed'),
    );

    setState(() {
      _activeSubcontractor = null;
      _chatState = null;
    });

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final land = game.ownedRealEstates.firstWhere(
      (r) => r.id == widget.landId,
      orElse: () => RealEstateModel(
        id: widget.landId,
        title: 'Arsa Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Ataşehir',
        squareMeters: 1000,
        roomCount: 'İmarlı Arsa',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 8000000.0,
        currentPurchasePrice: 8000000.0,
      ),
    );

    final totalBudget = (land.baseMarketValue * 0.75).roundToDouble();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: _chatState != null
            ? _chatState!.counterpartyName
            : context.tr('subcontractor_screen_title'),
        subtitle: _chatState != null
            ? ((_isOpponentTyping && !_isTypingPaused)
                ? context.tr('chat_status_typing')
                : context.tr('chat_status_online'))
            : null,
        onLeadingPressed: () {
          if (_chatState != null) {
            setState(() {
              _chatState = null;
              _activeSubcontractor = null;
            });
          } else {
            context.pop();
          }
        },
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NeoBrutalBadge(
              text: _activeSubcontractor != null
                  ? context.tr(_activeSubcontractor!.tier.badgeKey)
                  : context.tr('subcontractor_badge_total_days'),
              backgroundColor: const Color(0xFFE0E7FF),
              textColor: const Color(0xFF3730A3),
            ),
          ),
        ],
      ),
      body: _chatState != null
          ? _buildChatView(isDark)
          : _buildTimelineStageView(land, totalBudget, isDark),
    );
  }

  Widget _buildTimelineStageView(
      RealEstateModel land, double totalBudget, bool isDark) {
    final stages = ConstructionTimelineEngine.stages;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          NeoBrutalCard(
            backgroundColor:
                isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            padding: const EdgeInsets.all(14),
            borderColor: const Color(0xFF2563EB),
            child: Row(
              children: [
                const Icon(Icons.engineering_rounded,
                    color: Color(0xFF2563EB), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('subcontractor_banner_title'),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E40AF)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('subcontractor_banner_desc'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4 Stages List
          ...stages.map((stage) {
            final stageCost = (land.baseMarketValue * stage.costPercentage).roundToDouble();
            final isCompleted = land.constructionStage > stage.stageNumber;
            final isCurrent = land.constructionStage == stage.stageNumber;
            final isWorking = isCurrent &&
                land.isConstructionWorking &&
                land.constructionDaysRemaining > 0;
            final isReadyForHandover = isCurrent &&
                land.isConstructionWorking &&
                land.constructionDaysRemaining == 0;
            final isUnstarted = isCurrent && !land.isConstructionWorking;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : (isCompleted
                        ? const Color(0xFFF0FDF4)
                        : (isCurrent ? Colors.white : const Color(0xFFF8FAFC))),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : (isCurrent
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${stage.stageNumber}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr(stage.titleKey),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        NeoBrutalBadge(
                          text: context.tr('subcontractor_badge_days',
                              {'days': stage.baseDays}),
                          backgroundColor: const Color(0xFFFEF3C7),
                          textColor: const Color(0xFF92400E),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr(stage.descriptionKey),
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    if (isCurrent &&
                        land.isConstructionWorking &&
                        land.activeSubcontractorName != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.handyman_rounded,
                              size: 14, color: Color(0xFF2563EB)),
                          const SizedBox(width: 4),
                          Text(
                            '${land.activeSubcontractorName} • ${land.constructionDaysRemaining} ${context.tr('subcontractor_days_suffix')}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('subcontractor_estimated_budget', {
                            'budget': CurrencyFormatter.format(stageCost),
                          }),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (isCompleted)
                          NeoBrutalBadge(
                            text: context.tr('subcontractor_badge_completed'),
                            backgroundColor: const Color(0xFFD1FAE5),
                            textColor: const Color(0xFF065F46),
                          )
                        else if (isWorking)
                          NeoBrutalBadge(
                            text:
                                '${context.tr('subcontractor_badge_working')} • ${land.constructionDaysRemaining} ${context.tr('subcontractor_days_suffix')}',
                            backgroundColor: const Color(0xFFFEF3C7),
                            textColor: const Color(0xFF92400E),
                          )
                        else if (isReadyForHandover)
                          NeoBrutalButton(
                            text: context.tr('real_estate_stage_btn_handover'),
                            backgroundColor: const Color(0xFF10B981),
                            textColor: Colors.white,
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .completeSelfBuildStage(land.id);
                              if (success) {
                                GameSoundHapticService.playCashSuccess();
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('real_estate_advance_success_toast'),
                                );
                              }
                            },
                          )
                        else if (isUnstarted)
                          NeoBrutalButton(
                            text: context.tr('subcontractor_btn_select_and_negotiate'),
                            backgroundColor: const Color(0xFF2563EB),
                            textColor: Colors.white,
                            onPressed: () => _openSubcontractorSelector(
                                stage.stageNumber, stageCost),
                          )
                        else
                          NeoBrutalBadge(
                            text: context.tr('subcontractor_badge_locked'),
                            backgroundColor: const Color(0xFFE2E8F0),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _openSubcontractorSelector(int stageNumber, double stageCost) {
    _selectedStage = stageNumber;
    final land = ref.read(gameProvider).ownedRealEstates.firstWhere(
          (r) => r.id == widget.landId,
        );
    final subs =
        ConstructionTimelineEngine.getSubcontractorsForStage(stageNumber);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(top: BorderSide(color: Colors.black, width: 2.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('subcontractor_modal_title'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              ...subs.map((sub) {
                final cost = stageCost * sub.costMultiplier;
                final duration = ConstructionTimelineEngine.calculateStageDays(
                  stageNumber: stageNumber,
                  parcelSquareMeters: land.squareMeters.toDouble(),
                  tier: sub.tier,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sub.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            NeoBrutalBadge(
                              text: '$duration ${context.tr('subcontractor_days_suffix')}',
                              backgroundColor: const Color(0xFFFEF3C7),
                              textColor: const Color(0xFF92400E),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${CurrencyFormatter.format(cost)} • ${context.tr(sub.tier.badgeKey)}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: NeoBrutalButton(
                                text: context.tr('subcontractor_btn_negotiate'),
                                backgroundColor: const Color(0xFF2563EB),
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _startChatWithSubcontractor(sub, stageCost);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: NeoBrutalButton(
                                text: context.tr('subcontractor_btn_direct_hire'),
                                backgroundColor: const Color(0xFF10B981),
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  final success = ref
                                      .read(gameProvider.notifier)
                                      .startSelfBuildStage(
                                        widget.landId,
                                        subcontractor: sub,
                                        customStageCost: cost,
                                      );
                                  if (success) {
                                    GameSoundHapticService.playCashSuccess();
                                    NotificationService.showSuccess(
                                      context,
                                      context.tr('subcontractor_toast_hired', {
                                        'name': sub.name,
                                      }),
                                    );
                                    context.pop();
                                  } else {
                                    NotificationService.showError(
                                      context,
                                      context.tr('real_estate_expand_slots_error_funds'),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatView(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _chatState!.messages.length +
                (_isOpponentTyping && !_isTypingPaused ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _chatState!.messages.length) {
                return ChatTypingIndicatorBubble(
                  senderName: _chatState!.counterpartyName,
                  role: ChatSenderRole.subcontractor,
                  isDark: isDark,
                );
              }
              final msg = _chatState!.messages[index];
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
                          color: Color(0xFF64748B)),
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
                              : const Color(0xFFCBD5E1),
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

        // Action Panel
        if (!_chatState!.isAgreed && !_chatState!.isWalkedAway)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border:
                  const Border(top: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTacticChip(
                      label: context.tr('subcontractor_tactic_discount_label'),
                      isEnabled: !_isApplying,
                      onTap: () => _applyTactic(
                        ChatTacticType.counterPrice,
                        context.tr('subcontractor_tactic_discount_msg'),
                      ),
                    ),
                    _buildTacticChip(
                      label: context.tr('subcontractor_tactic_double_shift_label'),
                      isEnabled: !_isApplying,
                      onTap: () => _applyTactic(
                        ChatTacticType.demandDoubleShift,
                        context.tr('subcontractor_tactic_double_shift_msg'),
                      ),
                    ),
                    _buildTacticChip(
                      label: context.tr('subcontractor_tactic_cash_materials_label'),
                      isEnabled: !_isApplying,
                      onTap: () => _applyTactic(
                        ChatTacticType.demandCashMaterials,
                        context.tr('subcontractor_tactic_cash_materials_msg'),
                      ),
                    ),
                    _buildTacticChip(
                      label: context.tr('subcontractor_tactic_penalty_clause_label'),
                      isEnabled: !_isApplying,
                      onTap: () => _applyTactic(
                        ChatTacticType.demandPenaltyClause,
                        context.tr('subcontractor_tactic_penalty_clause_msg'),
                      ),
                    ),
                    _buildTacticChip(
                      label: context.tr('subcontractor_tactic_guarantee_label'),
                      isEnabled: !_isApplying,
                      onTap: () => _applyTactic(
                        ChatTacticType.demandPrimeFloors,
                        context.tr('subcontractor_tactic_guarantee_msg'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        text: context.tr('subcontractor_btn_agree_cost', {
                          'cost': CurrencyFormatter.format(_chatState!.currentPrice),
                        }),
                        backgroundColor: const Color(0xFF10B981),
                        textColor: Colors.white,
                        onPressed: _isApplying
                            ? null
                            : () => _applyTactic(
                                  ChatTacticType.acceptAgreement,
                                  context.tr('subcontractor_msg_agree_cost'),
                                ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeoBrutalButton(
                      text: context.tr('subcontractor_btn_end_chat'),
                      backgroundColor: const Color(0xFFEF4444),
                      textColor: Colors.white,
                      onPressed: _isApplying
                          ? null
                          : () => _applyTactic(
                                ChatTacticType.walkAway,
                                context.tr('subcontractor_msg_end_chat'),
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTacticChip({
    required String label,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
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
      ),
    );
  }
}
