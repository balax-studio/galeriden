import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

/// Neo-Brutalist Generic Confirmation Dialog for Rushing Multi-Day Operations via In-Universe Lore
class GenericRushJobDialog extends ConsumerStatefulWidget {
  final String titleBadge;
  final String targetTitle;
  final String targetSubtitle;
  final String loreDescription;
  final IconData icon;
  final Color badgeColor;
  final String actionButtonLabel;
  final IconData actionButtonIcon;
  final VoidCallback onRushSuccess;
  final double? rushCashCost;
  final VoidCallback? onRushWithCash;

  const GenericRushJobDialog({
    super.key,
    required this.titleBadge,
    required this.targetTitle,
    required this.targetSubtitle,
    required this.loreDescription,
    this.icon = Icons.bolt_rounded,
    this.badgeColor = AppColors.brutalYellow,
    required this.actionButtonLabel,
    this.actionButtonIcon = Icons.card_membership_rounded,
    required this.onRushSuccess,
    this.rushCashCost,
    this.onRushWithCash,
  });

  /// Displays the in-universe confirmation dialog modally
  static Future<void> show(
    BuildContext context, {
    required String titleBadge,
    required String targetTitle,
    required String targetSubtitle,
    required String loreDescription,
    IconData icon = Icons.bolt_rounded,
    Color badgeColor = AppColors.brutalYellow,
    required String actionButtonLabel,
    IconData actionButtonIcon = Icons.card_membership_rounded,
    required VoidCallback onRushSuccess,
    double? rushCashCost,
    VoidCallback? onRushWithCash,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => GenericRushJobDialog(
        titleBadge: titleBadge,
        targetTitle: targetTitle,
        targetSubtitle: targetSubtitle,
        loreDescription: loreDescription,
        icon: icon,
        badgeColor: badgeColor,
        actionButtonLabel: actionButtonLabel,
        actionButtonIcon: actionButtonIcon,
        onRushSuccess: onRushSuccess,
        rushCashCost: rushCashCost,
        onRushWithCash: onRushWithCash,
      ),
    );
  }

  @override
  ConsumerState<GenericRushJobDialog> createState() =>
      _GenericRushJobDialogState();
}

class _GenericRushJobDialogState extends ConsumerState<GenericRushJobDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: NeoBrutalCard(
        backgroundColor: isDark ? const Color(0xFF131620) : Colors.white,
        borderColor:
            isDark ? const Color(0xFF2E3748) : const Color(0xFF0F172A),
        borderWidth: 2.8,
        borderRadius: 18,
        shadowOffset: const Offset(5, 5),
        shadowColor: isDark ? Colors.black87 : const Color(0xFF0F172A),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Bar with Category Badge & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: NeoBrutalBadge(
                        text: widget.titleBadge,
                        backgroundColor: widget.badgeColor,
                        textColor: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Target Information Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.badgeColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.badgeColor,
                          width: 1.8,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          color: widget.badgeColor == Colors.white
                              ? (isDark ? Colors.white : Colors.black)
                              : widget.badgeColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.targetTitle,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.targetSubtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Explanatory In-Universe Lore Message
              Text(
                widget.loreDescription,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 18),

              // 4. Action Buttons (Cancel / Optional Cash Rush / Sponsor Grant Rush)
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('cancel'),
                      icon: Icons.arrow_back_rounded,
                      backgroundColor: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: NeoBrutalButton(
                      label: widget.actionButtonLabel,
                      icon: widget.actionButtonIcon,
                      backgroundColor: widget.badgeColor,
                      textColor: Colors.black,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      onPressed: _isProcessing
                          ? null
                          : () {
                              setState(() => _isProcessing = true);
                              final rootContext =
                                  Navigator.of(context, rootNavigator: true)
                                      .context;
                              final onReward = widget.onRushSuccess;
                              Navigator.of(context).pop();

                              AdService.instance.showRewardedAdWithFallback(
                                context: rootContext,
                                customRewardTitle: widget.titleBadge,
                                onRewardEarned: () {
                                  onReward();
                                },
                              );
                            },
                    ),
                  ),
                ],
              ),

              // Optional Direct Cash Payment Button
              if (widget.rushCashCost != null &&
                  widget.onRushWithCash != null) ...[
                const SizedBox(height: 8),
                NeoBrutalButton(
                  label:
                      '₺${widget.rushCashCost!.toStringAsFixed(0)} • ${context.tr('rush_lore_btn_instant_cash')}',
                  icon: Icons.payments_rounded,
                  backgroundColor: const Color(0xFF38BDF8),
                  textColor: Colors.black,
                  fontSize: 10.5,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onPressed: () {
                    final onCash = widget.onRushWithCash!;
                    Navigator.of(context).pop();
                    onCash();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
