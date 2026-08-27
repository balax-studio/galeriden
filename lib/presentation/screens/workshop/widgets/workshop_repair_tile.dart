import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/animated_rolling_counter.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/pulsing_dot.dart';

class WorkshopRepairTile extends StatelessWidget {
  final String title;
  final String description;
  final double cost;
  final String bonusText;
  final String? netRoiText;
  final Color badgeColor;
  final bool isDark;
  final bool isRepaired;
  final String? disabledLabel;
  final VoidCallback onRepair;
  final VoidCallback? onAdRepair;

  const WorkshopRepairTile({
    super.key,
    required this.title,
    required this.description,
    required this.cost,
    required this.bonusText,
    this.netRoiText,
    required this.badgeColor,
    required this.isDark,
    this.isRepaired = false,
    this.disabledLabel,
    required this.onRepair,
    this.onAdRepair,
  });

  @override
  Widget build(BuildContext context) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isRepaired
          ? const Color(0xFF00E575)
          : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
      borderRadius: 8,
      borderWidth: 2.5,
      shadowOffset: const Offset(3.5, 3.5),
      showDotGrid: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                    NeoBrutalBadge(
                      text: isRepaired
                          ? context.tr('workshop_repaired_badge')
                          : bonusText,
                      backgroundColor:
                          isRepaired ? const Color(0xFF00E575) : badgeColor,
                      textColor: Colors.black,
                      fontSize: 9,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                if (isRepaired)
                  Text(
                    context.tr('workshop_no_repair_needed'),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00E575),
                    ),
                  )
                else
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PulsingDot(color: Color(0xFFFF7A00), size: 5.5),
                        const SizedBox(width: 5),
                        Text(
                          context.tr('workshop_repair_cost_label'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF7A00),
                          ),
                        ),
                        AnimatedRollingCounter(
                          value: cost,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF7A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!isRepaired &&
                    netRoiText != null &&
                    netRoiText!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    netRoiText!,
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00C853)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeoBrutalButton(
                label: isRepaired
                    ? (disabledLabel ?? context.tr('tuning_btn_applied'))
                    : context.tr('workshop_btn_repair'),
                icon: isRepaired
                    ? Icons.check_circle_rounded
                    : Icons.build_circle_rounded,
                backgroundColor: isRepaired
                    ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                    : AppColors.brutalYellow,
                textColor: isRepaired
                    ? (isDark ? Colors.white54 : Colors.black54)
                    : Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onPressed: isRepaired ? null : onRepair,
              ),
              if (!isRepaired && onAdRepair != null) ...[
                const SizedBox(height: 6),
                NeoBrutalButton(
                  label: 'ÜCRETSİZ', // Free
                  icon: Icons.play_circle_filled_rounded,
                  backgroundColor: const Color(0xFFA855F7),
                  textColor: Colors.white,
                  fontSize: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  onPressed: onAdRepair,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
