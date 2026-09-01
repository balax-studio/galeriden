import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/notification_service.dart';
import '../../data/models/dramatic_card_model.dart';
import '../../domain/usecases/dramatic_card_engine.dart';
import '../providers/game_provider.dart';
import 'app_vector_icons.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';

class NeoBrutalDramaticDialog extends ConsumerStatefulWidget {
  final DramaticCardModel card;

  const NeoBrutalDramaticDialog({
    super.key,
    required this.card,
  });

  static Future<void> show(BuildContext context, DramaticCardModel card) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NeoBrutalDramaticDialog(card: card),
    );
  }

  @override
  ConsumerState<NeoBrutalDramaticDialog> createState() =>
      _NeoBrutalDramaticDialogState();
}

class _NeoBrutalDramaticDialogState
    extends ConsumerState<NeoBrutalDramaticDialog> {
  DramaticResolutionResult? _resolutionResult;
  bool _isProcessing = false;

  Color _getCategoryColor(DramaticCategory category) {
    switch (category) {
      case DramaticCategory.comedy:
        return const Color(0xFFFFB703); // Electric Amber
      case DramaticCategory.opportunity:
        return const Color(0xFF00E575); // Mint Emerald
      case DramaticCategory.loss:
        return const Color(0xFFEA580C); // Warm Rust Orange
      case DramaticCategory.betrayal:
        return const Color(0xFFDC2626); // Crimson Red
      case DramaticCategory.conscience:
        return const Color(0xFF0284C7); // Trust Sky Blue
      case DramaticCategory.legacy:
        return const Color(0xFF9333EA); // Neon Purple
      case DramaticCategory.gamble:
        return const Color(0xFFF43F5E); // Bold Rose
    }
  }

  Color _getCategoryTextColor(DramaticCategory category) {
    switch (category) {
      case DramaticCategory.comedy:
      case DramaticCategory.opportunity:
        return const Color(0xFF0F172A);
      default:
        return Colors.white;
    }
  }

  String _getCategoryLabel(DramaticCategory category) {
    switch (category) {
      case DramaticCategory.comedy:
        return context.tr('category_comedy');
      case DramaticCategory.opportunity:
        return context.tr('category_opportunity');
      case DramaticCategory.loss:
        return context.tr('category_loss');
      case DramaticCategory.betrayal:
        return context.tr('category_betrayal');
      case DramaticCategory.conscience:
        return context.tr('category_conscience');
      case DramaticCategory.legacy:
        return context.tr('category_legacy');
      case DramaticCategory.gamble:
        return context.tr('category_gamble');
    }
  }

  String _getSeverityLabel(DramaticSeverity severity) {
    switch (severity) {
      case DramaticSeverity.low:
        return context.tr('severity_low');
      case DramaticSeverity.medium:
        return context.tr('severity_medium');
      case DramaticSeverity.high:
        return context.tr('severity_high');
      case DramaticSeverity.extreme:
        return context.tr('severity_extreme');
    }
  }

  void _onChoiceSelected(DramaticChoiceModel choice) {
    final state = ref.read(gameProvider);
    if (choice.upfrontCost > 0 && state.balance < choice.upfrontCost) {
      NotificationService.showError(
        context,
        context.tr('err_insufficient_cash_choice',
            {'amount': choice.upfrontCost.toStringAsFixed(0)}),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = ref.read(gameProvider.notifier).resolveDramaticCardChoice(
          card: widget.card,
          choice: choice,
        );

    setState(() {
      _resolutionResult = result;
      _isProcessing = false;
    });

    if (result.outcome.isSuccess) {
      NotificationService.showSuccess(
        context,
        result.outcome.message,
      );
    } else {
      NotificationService.showWarning(
        context,
        result.outcome.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = _getCategoryColor(widget.card.category);
    final catTextColor = _getCategoryTextColor(widget.card.category);
    final gameState = ref.watch(gameProvider);
    final currentBalance = gameState.balance;
    final currentDay = widget.card.dayNumber ?? gameState.currentDay;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: screenHeight > 100 ? screenHeight * 0.90 : 700,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black : const Color(0xFF0F172A),
                offset: const Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: _resolutionResult == null
                  ? _buildDilemmaView(
                      isDark, catColor, catTextColor, currentBalance, currentDay)
                  : _buildOutcomeView(isDark, catColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDilemmaView(
    bool isDark,
    Color catColor,
    Color catTextColor,
    double currentBalance,
    int currentDay,
  ) {
    return Column(
      key: const ValueKey('dilemma_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Top Badges Strip
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
                child: Text(
                  context.tr('daily_dilemma_badge', {'day': currentDay.toString()}),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            NeoBrutalBadge(
              text: _getSeverityLabel(widget.card.severity),
              backgroundColor:
                  isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
              textColor: isDark ? Colors.white70 : const Color(0xFF334155),
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              borderWidth: 2.0,
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 2. Category Indicator Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: catColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black54 : const Color(0xFF0F172A),
                offset: const Offset(2.5, 2.5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 16,
                color: catTextColor,
              ),
              const SizedBox(width: 6),
              Text(
                _getCategoryLabel(widget.card.category),
                style: TextStyle(
                  color: catTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Character & Event Title Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFF0F172A),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black54 : const Color(0xFF0F172A),
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AvatarIconWidget(
                avatar: widget.card.characterAvatar,
                size: 30,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.card.title,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${widget.card.characterName} • ${widget.card.characterRole}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 4. Dialogue Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                offset: const Offset(2.5, 2.5),
              ),
            ],
          ),
          child: Text(
            widget.card.dialogue,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 5. Foreshadowing / Intuition Note
        if (widget.card.foreshadowHint.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: catColor,
                width: 2.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.card.foreshadowHint,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // 6. Choices List Prompt
        Text(
          context.tr('daily_dilemma_action_prompt'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        ...widget.card.choices.map((choice) {
          final bool canAfford =
              choice.upfrontCost <= 0 || currentBalance >= choice.upfrontCost;
          final bool isPrimary = choice == widget.card.choices.first;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: _isProcessing || !canAfford
                  ? null
                  : () => _onChoiceSelected(choice),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: !canAfford
                      ? (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9))
                      : (isPrimary
                          ? catColor.withValues(alpha: isDark ? 0.25 : 0.16)
                          : (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFFFFFFF))),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !canAfford
                        ? (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1))
                        : (isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFF0F172A)),
                    width: 2.4,
                  ),
                  boxShadow: canAfford
                      ? [
                          BoxShadow(
                            color: isDark
                                ? Colors.black54
                                : const Color(0xFF0F172A),
                            offset: const Offset(3.5, 3.5),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            choice.label,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: !canAfford
                                  ? (isDark
                                      ? Colors.white38
                                      : const Color(0xFF94A3B8))
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A)),
                            ),
                          ),
                        ),
                        if (choice.upfrontCost > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: !canAfford
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark
                                    ? Colors.black
                                    : const Color(0xFF0F172A),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '-₺${choice.upfrontCost.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      choice.shortDescription,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? (canAfford ? Colors.white70 : Colors.white30)
                            : (canAfford
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOutcomeView(bool isDark, Color catColor) {
    final result = _resolutionResult!;
    final outcome = result.outcome;

    return Column(
      key: const ValueKey('outcome_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Slam Stamp Badge Header
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: outcome.isSuccess
                  ? const Color(0xFF00E575)
                  : const Color(0xFFFF3366),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black : const Color(0xFF0F172A),
                  offset: const Offset(3.5, 3.5),
                ),
              ],
            ),
            child: Text(
              context.tr('daily_dilemma_sealed'),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 2. Status Icon & Outcome Title
        Center(
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: outcome.isSuccess
                  ? const Color(0xFF00E575).withValues(alpha: 0.2)
                  : const Color(0xFFFF3366).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: outcome.isSuccess
                    ? const Color(0xFF00E575)
                    : const Color(0xFFFF3366),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black54 : const Color(0xFF0F172A),
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              outcome.isSuccess
                  ? Icons.check_circle_outline_rounded
                  : Icons.warning_amber_rounded,
              color: outcome.isSuccess
                  ? const Color(0xFF00E575)
                  : const Color(0xFFFF3366),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Text(
          outcome.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // 3. Story Resolution Narrative Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                offset: const Offset(2.5, 2.5),
              ),
            ],
          ),
          child: Text(
            outcome.message,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 4. Impact Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            if (outcome.moneyDelta != 0)
              NeoBrutalBadge(
                text:
                    '${outcome.moneyDelta > 0 ? '+' : ''}₺${outcome.moneyDelta.toStringAsFixed(0)}',
                backgroundColor: outcome.moneyDelta > 0
                    ? const Color(0xFF00E575)
                    : const Color(0xFFEF4444),
                textColor: outcome.moneyDelta > 0
                    ? const Color(0xFF0F172A)
                    : Colors.white,
                fontWeight: FontWeight.w900,
                borderWidth: 2.0,
              ),
            if (outcome.reputationDelta != 0)
              NeoBrutalBadge(
                text:
                    '${outcome.reputationDelta > 0 ? '+' : ''}${context.tr('badge_reputation_pts', {
                      'val': outcome.reputationDelta.toString()
                    })}',
                backgroundColor: outcome.reputationDelta > 0
                    ? const Color(0xFF00D4FF)
                    : const Color(0xFFF43F5E),
                textColor: outcome.reputationDelta > 0
                    ? const Color(0xFF0F172A)
                    : Colors.white,
                fontWeight: FontWeight.w900,
                borderWidth: 2.0,
              ),
            if (outcome.xpReward > 0)
              NeoBrutalBadge(
                text: '+${outcome.xpReward} XP',
                backgroundColor: const Color(0xFF9333EA),
                textColor: Colors.white,
                fontWeight: FontWeight.w900,
                borderWidth: 2.0,
              ),
            if (outcome.loseTargetCar)
              NeoBrutalBadge(
                text: context.tr('badge_car_lost'),
                backgroundColor: const Color(0xFF991B1B),
                textColor: Colors.white,
                fontWeight: FontWeight.w900,
                borderWidth: 2.0,
              ),
            if (outcome.makeFamilyHeirloom)
              NeoBrutalBadge(
                text: context.tr('badge_heirloom_registered'),
                backgroundColor: const Color(0xFFD97706),
                textColor: Colors.white,
                fontWeight: FontWeight.w900,
                borderWidth: 2.0,
              ),
          ],
        ),
        const SizedBox(height: 18),

        // 5. Continue Button
        NeoBrutalButton(
          label: context.tr('btn_continue'),
          fullWidth: true,
          backgroundColor: const Color(0xFF00E575),
          textColor: const Color(0xFF0F172A),
          borderRadius: 12,
          borderWidth: 2.5,
          fontWeight: FontWeight.w900,
          onPressed: () {
            ref.read(gameProvider.notifier).dismissPendingDramaticCard();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
