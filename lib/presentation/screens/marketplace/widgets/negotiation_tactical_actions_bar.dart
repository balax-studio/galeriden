import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/usecases/negotiation_engine.dart';

class NegotiationTacticalActionsBar extends StatelessWidget {
  final List<EsnafTactic> dynamicTactics;
  final Set<String> usedTacticIds;
  final int tacticUsageCount;
  final TacticRollOutcome? lastTacticOutcome;
  final bool isDark;
  final bool isLocked;
  final ValueChanged<EsnafTactic> onExecuteTactic;

  const NegotiationTacticalActionsBar({
    super.key,
    required this.dynamicTactics,
    required this.usedTacticIds,
    required this.tacticUsageCount,
    required this.lastTacticOutcome,
    required this.isDark,
    required this.isLocked,
    required this.onExecuteTactic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.tr('negotiation_tactics_header'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tacticUsageCount >= 3
                    ? (isDark
                        ? const Color(0xFF7F1D1D)
                        : const Color(0xFFFEE2E8))
                    : (isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: tacticUsageCount >= 3
                      ? AppColors.errorRed
                      : (isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFFCBD5E1)),
                  width: 1.2,
                ),
              ),
              child: Text(
                '$tacticUsageCount / 3 KOZ KULLANILDI',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: tacticUsageCount >= 3
                      ? AppColors.errorRed
                      : (isDark ? Colors.white70 : const Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Last Tactic Outcome Banner
        if (lastTacticOutcome != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: lastTacticOutcome!.isSuccess
                  ? (isDark
                      ? const Color(0xFF064E3B)
                      : const Color(0xFFD1FAE5))
                  : (lastTacticOutcome!.isWalkaway
                      ? (isDark
                          ? const Color(0xFF7F1D1D)
                          : const Color(0xFFFEE2E2))
                      : (isDark
                          ? const Color(0xFF78350F)
                          : const Color(0xFFFEF3C7))),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: lastTacticOutcome!.isSuccess
                    ? AppColors.brutalGreen
                    : (lastTacticOutcome!.isWalkaway
                        ? AppColors.errorRed
                        : AppColors.brutalYellow),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  lastTacticOutcome!.isSuccess
                      ? Icons.casino_rounded
                      : (lastTacticOutcome!.isWalkaway
                          ? Icons.cancel_rounded
                          : Icons.casino_outlined),
                  size: 16,
                  color: lastTacticOutcome!.isSuccess
                      ? AppColors.brutalGreen
                      : (lastTacticOutcome!.isWalkaway
                          ? AppColors.errorRed
                          : AppColors.brutalYellow),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Zar: ${lastTacticOutcome!.diceRoll} / ${lastTacticOutcome!.threshold} • ${lastTacticOutcome!.isSuccess ? "Başarılı +%${lastTacticOutcome!.bonusChance}" : (lastTacticOutcome!.isWalkaway ? "Masadan Kalkıldı" : "Direnç ${lastTacticOutcome!.bonusChance}%")}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        Row(
          children: dynamicTactics.map((tactic) {
            final isUsed = usedTacticIds.contains(tactic.id);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _buildTacticalCard(
                  context: context,
                  title: isUsed
                      ? context.tr('negotiation_toast_tactic_used')
                      : tactic.title,
                  badgeText: tactic.badgeText,
                  icon: _getTacticIcon(tactic.iconKey),
                  activeBgColor: tactic.accentColor,
                  accentColor: tactic.accentColor,
                  isUsed: isUsed,
                  onTap: () => onExecuteTactic(tactic),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTacticalCard({
    required BuildContext context,
    required String title,
    required String badgeText,
    required IconData icon,
    required Color activeBgColor,
    required Color accentColor,
    required bool isUsed,
    required VoidCallback onTap,
  }) {
    final isCardDisabled = isUsed || isLocked;

    return InkWell(
      onTap: isCardDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isUsed
              ? (isDark ? const Color(0xFF141721) : const Color(0xFFE2E8F0))
              : (isDark ? const Color(0xFF1E2330) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isUsed
                ? (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1))
                : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
            width: 2.0,
          ),
          boxShadow: isCardDisabled
              ? null
              : [
                  BoxShadow(
                    color: isDark ? Colors.black : const Color(0xFF0F172A),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isUsed
                    ? (isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFFCBD5E1))
                    : activeBgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isUsed ? Colors.white38 : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: isUsed
                    ? (isDark ? Colors.white38 : Colors.black38)
                    : (isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: isUsed
                    ? (isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFFCBD5E1))
                    : (isDark
                        ? accentColor.withValues(alpha: 0.20)
                        : accentColor.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isUsed ? Colors.transparent : accentColor,
                  width: 1.0,
                ),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: isUsed
                      ? (isDark ? Colors.white30 : Colors.black38)
                      : (isDark ? accentColor : const Color(0xFF0F172A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTacticIcon(String iconKey) {
    switch (iconKey) {
      case 'expert':
        return Icons.search_rounded;
      case 'defect':
        return Icons.car_crash_rounded;
      case 'cash':
        return Icons.payments_rounded;
      case 'market':
        return Icons.trending_down_rounded;
      case 'partner':
        return Icons.phone_in_talk_rounded;
      case 'tea':
        return Icons.local_cafe_rounded;
      case 'smoke':
        return Icons.smoking_rooms_rounded;
      case 'mechanic':
        return Icons.build_rounded;
      case 'urgent':
        return Icons.alarm_on_rounded;
      case 'pristine':
        return Icons.auto_awesome_rounded;
      case 'notary':
        return Icons.drive_file_rename_outline_rounded;
      case 'tok_seller':
        return Icons.work_rounded;
      case 'speed':
        return Icons.bolt_rounded;
      case 'handshake':
        return Icons.handshake_rounded;
      case 'shield':
        return Icons.security_rounded;
      case 'key':
        return Icons.key_rounded;
      case 'diamond':
        return Icons.diamond_rounded;
      case 'garage':
        return Icons.garage_rounded;
      case 'strike':
        return Icons.front_hand_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.handshake_rounded;
    }
  }
}
