import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../domain/usecases/psychology_engine.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/pulsing_dot.dart';

class NegotiationDialogueOutcomeCard extends StatelessWidget {
  final bool isThinking;
  final String thinkingText;
  final String? sellerResponse;
  final bool isAccepted;
  final String customerName;
  final bool isNearMiss;
  final bool isLockedOut;
  final bool hasRescuedWithTea;
  final bool isDark;
  final VoidCallback onTeaRescue;

  const NegotiationDialogueOutcomeCard({
    super.key,
    required this.isThinking,
    required this.thinkingText,
    required this.sellerResponse,
    required this.isAccepted,
    required this.customerName,
    required this.isNearMiss,
    required this.isLockedOut,
    required this.hasRescuedWithTea,
    required this.isDark,
    required this.onTeaRescue,
  });

  @override
  Widget build(BuildContext context) {
    if (isThinking) {
      return Column(
        children: [
          NeoBrutalCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            backgroundColor:
                isDark ? const Color(0xFF1E2330) : const Color(0xFFFEFCE8),
            borderColor: const Color(0xFFFFDE59),
            borderWidth: 2.2,
            borderRadius: 10,
            shadowOffset: const Offset(3, 3),
            child: Row(
              children: [
                const PulsingDot(color: Color(0xFFFFDE59), size: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const NeoBrutalBadge(
                            text: 'CANLI DÜŞÜNCE RADARI',
                            backgroundColor: Color(0xFFFFDE59),
                            textColor: Colors.black,
                            borderWidth: 1.2,
                            fontSize: 8.5,
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Değerlendiriliyor...',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        thinkingText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    if (sellerResponse == null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    PsychologyEngine.getSuspenseNegotiationText(),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    return Column(
      children: [
        NeoBrutalCard(
          backgroundColor: isAccepted
              ? (isDark ? const Color(0xFF14291D) : const Color(0xFFF0FDF4))
              : (isDark ? const Color(0xFF291414) : const Color(0xFFFEF2F2)),
          borderColor: isAccepted
              ? const Color(0xFF00E575)
              : const Color(0xFFEF4444),
          borderWidth: 2.2,
          borderRadius: 12,
          shadowOffset: const Offset(3, 3),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isAccepted
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isAccepted
                        ? const Color(0xFF00E575)
                        : const Color(0xFFEF4444),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAccepted
                        ? context.tr('deal_offer_accepted')
                        : context.tr('deal_offer_rejected'),
                    style: TextStyle(
                      color: isAccepted
                          ? const Color(0xFF00E575)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$customerName: "$sellerResponse"',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              if (isNearMiss && !isAccepted && !isLockedOut) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE59).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: const Color(0xFFFFDE59), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.near_me_rounded,
                          size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.tr('deal_near_miss_desc'),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isLockedOut) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: const Color(0xFFEF4444), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.block_rounded,
                          size: 14, color: Color(0xFFEF4444)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          context.tr('deal_locked_out_desc'),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEF4444)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!hasRescuedWithTea) ...[
                  const SizedBox(height: 8),
                  NeoBrutalButton(
                    label: context.tr('deal_tea_rescue_btn'),
                    icon: Icons.local_cafe_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 11,
                    fullWidth: true,
                    onPressed: () {
                      AdService.instance.showRewardedAdWithFallback(
                        context: context,
                        customRewardTitle: context.tr('deal_tea_reward_title'),
                        onRewardEarned: () {
                          onTeaRescue();
                          NotificationService.showSuccess(
                            context,
                            context.tr('deal_tea_rescue_toast'),
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
