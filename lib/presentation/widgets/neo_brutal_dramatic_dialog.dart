import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/notification_service.dart';
import '../../data/models/dramatic_card_model.dart';
import '../../domain/usecases/dramatic_card_engine.dart';
import '../providers/game_provider.dart';
import 'app_vector_icons.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';

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
  ConsumerState<NeoBrutalDramaticDialog> createState() => _NeoBrutalDramaticDialogState();
}

class _NeoBrutalDramaticDialogState extends ConsumerState<NeoBrutalDramaticDialog> {
  DramaticResolutionResult? _resolutionResult;
  bool _isProcessing = false;

  Color _getCategoryColor(DramaticCategory category) {
    switch (category) {
      case DramaticCategory.loss:
        return const Color(0xFFEA580C); // Warm Rust Orange
      case DramaticCategory.betrayal:
        return const Color(0xFFDC2626); // Crimson Red
      case DramaticCategory.conscience:
        return const Color(0xFF0284C7); // Trust Sky Blue
      case DramaticCategory.legacy:
        return const Color(0xFFD97706); // Heritage Gold
      case DramaticCategory.gamble:
        return const Color(0xFF9333EA); // Neon Purple
    }
  }

  String _getCategoryLabel(DramaticCategory category) {
    switch (category) {
      case DramaticCategory.loss:
        return 'KAYIP & RİSK';
      case DramaticCategory.betrayal:
        return 'İHANET & TEHLİKE';
      case DramaticCategory.conscience:
        return 'VİCDAN İKİLEMİ';
      case DramaticCategory.legacy:
        return 'MİRAS & VEFA';
      case DramaticCategory.gamble:
        return 'KUMAR & ŞANS';
    }
  }

  String _getSeverityLabel(DramaticSeverity severity) {
    switch (severity) {
      case DramaticSeverity.low:
        return 'DÜŞÜK RİSK';
      case DramaticSeverity.medium:
        return 'ORTA RİSK';
      case DramaticSeverity.high:
        return 'YÜKSEK RİSK';
      case DramaticSeverity.extreme:
        return 'EKSTREM RİSK';
    }
  }

  void _onChoiceSelected(DramaticChoiceModel choice) {
    final state = ref.read(gameProvider);
    if (choice.upfrontCost > 0 && state.balance < choice.upfrontCost) {
      NotificationService.showError(
        context,
        'Bu seçeneği seçmek için ₺${choice.upfrontCost.toStringAsFixed(0)} nakit gereklidir.',
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
    final currentBalance = ref.watch(gameProvider).balance;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: NeoBrutalCard(
        backgroundColor: isDark ? const Color(0xFF11141E) : Colors.white,
        borderColor: isDark ? const Color(0xFF2B3346) : const Color(0xFF0F172A),
        borderWidth: 3.0,
        borderRadius: 18,
        shadowOffset: const Offset(6, 6),
        shadowColor: isDark ? Colors.black87 : const Color(0xFF0F172A),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _resolutionResult == null
                ? _buildDilemmaView(isDark, catColor, currentBalance)
                : _buildOutcomeView(isDark, catColor),
          ),
        ),
      ),
    );
  }

  Widget _buildDilemmaView(bool isDark, Color catColor, double currentBalance) {
    return Column(
      key: const ValueKey('dilemma_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NeoBrutalBadge(
              text: _getCategoryLabel(widget.card.category),
              backgroundColor: catColor,
              textColor: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            NeoBrutalBadge(
              text: _getSeverityLabel(widget.card.severity),
              backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
              textColor: isDark ? Colors.white70 : const Color(0xFF334155),
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. Character & Event Title
        Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B202E) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF3A4659) : const Color(0xFF0F172A),
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black54 : const Color(0xFF0F172A),
                    offset: const Offset(2.5, 2.5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AvatarIconWidget(
                avatar: widget.card.characterAvatar,
                size: 28,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
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
        const SizedBox(height: 16),

        // 3. Dialogue Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B26) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
              width: 2.0,
            ),
          ),
          child: Text(
            widget.card.dialogue,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 4. Foreshadowing / Intuition Note
        if (widget.card.foreshadowHint.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: catColor.withValues(alpha: 0.5), width: 2.0),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, size: 16, color: catColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.card.foreshadowHint,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),

        // 5. Choices List
        Text(
          'KARARINI VER:',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),

        ...widget.card.choices.map((choice) {
          final bool canAfford = choice.upfrontCost <= 0 || currentBalance >= choice.upfrontCost;
          final bool isPrimary = choice == widget.card.choices.first;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: _isProcessing || !canAfford ? null : () => _onChoiceSelected(choice),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: !canAfford
                      ? (isDark ? const Color(0xFF181C26) : const Color(0xFFF1F5F9))
                      : (isPrimary
                          ? catColor.withValues(alpha: isDark ? 0.22 : 0.14)
                          : (isDark ? const Color(0xFF1A202C) : const Color(0xFFF8FAFC))),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !canAfford
                        ? (isDark ? const Color(0xFF2D3748) : const Color(0xFFCBD5E1))
                        : (isPrimary
                            ? catColor
                            : (isDark ? const Color(0xFF3B4758) : const Color(0xFF94A3B8))),
                    width: isPrimary ? 2.2 : 1.6,
                  ),
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
                                  ? (isDark ? Colors.white38 : const Color(0xFF94A3B8))
                                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ),
                        ),
                        if (choice.upfrontCost > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: !canAfford ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(6),
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
                        color: isDark ? Colors.white60 : const Color(0xFF475569),
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
        // 1. Status Icon & Header
        Center(
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: outcome.isSuccess
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : const Color(0xFFEF4444).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: outcome.isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                width: 2.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              outcome.isSuccess ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
              color: outcome.isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Text(
          outcome.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // 2. Story Resolution Narrative
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B26) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF2A3444) : const Color(0xFFCBD5E1),
              width: 1.8,
            ),
          ),
          child: Text(
            outcome.message,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 3. Impact Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            if (outcome.moneyDelta != 0)
              NeoBrutalBadge(
                text: '${outcome.moneyDelta > 0 ? '+' : ''}₺${outcome.moneyDelta.toStringAsFixed(0)}',
                backgroundColor: outcome.moneyDelta > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                textColor: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            if (outcome.reputationDelta != 0)
              NeoBrutalBadge(
                text: '${outcome.reputationDelta > 0 ? '+' : ''}${outcome.reputationDelta} İTİBAR',
                backgroundColor: outcome.reputationDelta > 0 ? const Color(0xFF3B82F6) : const Color(0xFFF43F5E),
                textColor: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            if (outcome.xpReward > 0)
              NeoBrutalBadge(
                text: '+${outcome.xpReward} XP',
                backgroundColor: const Color(0xFF8B5CF6),
                textColor: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            if (outcome.loseTargetCar)
              const NeoBrutalBadge(
                text: 'ARAÇ KAYBEDİLDİ',
                backgroundColor: Color(0xFF991B1B),
                textColor: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            if (outcome.makeFamilyHeirloom)
              const NeoBrutalBadge(
                text: 'AİLE YADİGARI TESCİLLENDİ',
                backgroundColor: Color(0xFFD97706),
                textColor: Colors.white,
                fontWeight: FontWeight.w900,
              ),
          ],
        ),
        const SizedBox(height: 18),

        // 4. Continue Button
        NeoBrutalButton(
          label: 'DEVAM ET',
          fullWidth: true,
          backgroundColor: const Color(0xFF00E575),
          textColor: Colors.black,
          borderRadius: 12,
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
