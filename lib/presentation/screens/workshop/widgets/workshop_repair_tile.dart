import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isRepaired ? const Color(0xFF00E575) : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
      borderRadius: 12,
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
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                    NeoBrutalBadge(
                      text: isRepaired ? 'KUSURSUZ' : bonusText,
                      backgroundColor: isRepaired ? const Color(0xFF00E575) : badgeColor,
                      textColor: Colors.black,
                      fontSize: 9,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  isRepaired ? 'Onarım Gerekmiyor' : 'Onarım Bedeli: ${CurrencyFormatter.format(cost)}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: isRepaired ? const Color(0xFF00E575) : const Color(0xFFFF7A00),
                  ),
                ),
                if (!isRepaired && netRoiText != null && netRoiText!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    netRoiText!,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF00C853)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          NeoBrutalButton(
            label: isRepaired ? (disabledLabel ?? 'ONARILDI') : 'ONAR',
            icon: isRepaired ? Icons.check_circle_rounded : Icons.build_circle_rounded,
            backgroundColor: isRepaired
                ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                : AppColors.brutalYellow,
            textColor: isRepaired ? (isDark ? Colors.white54 : Colors.black54) : Colors.black,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: isRepaired ? null : onRepair,
          ),
        ],
      ),
    );
  }
}
