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
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();

  void _startChatWithSubcontractor(SubcontractorProfile sub, double stageCost) {
    setState(() {
      _activeSubcontractor = sub;
      _chatState = ChatNegotiationState(
        targetId: '${widget.landId}_stage_$_selectedStage',
        counterpartyName: sub.name,
        counterpartyRole: ChatSenderRole.subcontractor,
        patience: 100,
        satisfaction: 60,
        currentPrice: stageCost * sub.costMultiplier,
        messages: [
          ChatMessageModel(
            id: 'msg_0',
            senderName: sub.name,
            role: ChatSenderRole.subcontractor,
            message: context.tr('subcontractor_msg_initial', {
              'mode': sub.tier == SubcontractorTier.speed
                  ? context.tr('subcontractor_mode_speed')
                  : context.tr('subcontractor_mode_meticulous'),
              'cost': CurrencyFormatter.format(stageCost * sub.costMultiplier),
              'days': ConstructionTimelineEngine.calculateStageDays(
                stageNumber: _selectedStage,
                parcelSquareMeters: 1000,
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

  void _applyTactic(ChatTacticType tactic, String playerMessage) {
    if (_chatState == null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _chatState = RealEstateChatNegotiationEngine.executeTactic(
        state: _chatState!,
        tactic: tactic,
        playerMessageText: playerMessage,
        random: _random,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    if (_chatState!.isAgreed) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(
        context,
        context.tr('subcontractor_toast_agreed'),
      );
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
    final land = ref.read(gameProvider).ownedRealEstates.firstWhere(
          (r) => r.id == widget.landId,
        );

    ref.read(gameProvider.notifier).advanceSelfBuildStage(
          land.id,
          customStageCost: _chatState?.currentPrice,
        );

    setState(() {
      _activeSubcontractor = null;
      _chatState = null;
    });
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

    final totalBudget = land.baseMarketValue * 0.45;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: _chatState != null
            ? _chatState!.counterpartyName
            : context.tr('subcontractor_screen_title'),
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

          // 6 Stages List
          ...stages.map((stage) {
            final stageCost = totalBudget * stage.costPercentage;
            final isCompleted = land.constructionStage > stage.stageNumber;
            final isCurrent = land.constructionStage == stage.stageNumber - 1;

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
                          text: context.tr('subcontractor_badge_days', {'days': stage.baseDays}),
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
                        else if (isCurrent)
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${CurrencyFormatter.format(cost)} • ${context.tr('subcontractor_speed_prefix', {'speed': (1.0 / sub.durationMultiplier).toStringAsFixed(1)})}',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        NeoBrutalButton(
                          text: context.tr('subcontractor_btn_negotiate'),
                          backgroundColor: const Color(0xFF10B981),
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.pop(ctx);
                            _startChatWithSubcontractor(sub, stageCost);
                          },
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
            itemCount: _chatState!.messages.length,
            itemBuilder: (context, index) {
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
                    onTap: () => _applyTactic(
                      ChatTacticType.counterPrice,
                      context.tr('subcontractor_tactic_discount_msg'),
                    ),
                  ),
                  _buildTacticChip(
                    label: context.tr('subcontractor_tactic_guarantee_label'),
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
                      onPressed: () => _applyTactic(
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
                    onPressed: () => _applyTactic(
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
