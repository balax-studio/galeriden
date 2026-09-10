import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

/// Interactive Neo-Brutalist Time & Calendar Fast Forward Sheet.
/// Allows the player to inspect the active day cycle and advance the game calendar
/// by 1 in-game day via a rewarded ad.
class GameDayTimeControlSheet extends ConsumerWidget {
  final bool isDark;

  const GameDayTimeControlSheet({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final theme = Theme.of(context);
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFF0F172A);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black : const Color(0xFF0F172A),
              offset: const Offset(0, -4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Day Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 2.0),
                  ),
                  child: const Icon(
                    Icons.access_time_filled_rounded,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('hud_time_control_title'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('hud_time_control_desc'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: '${game.currentDay}. ${context.tr('hud_day')}',
                  backgroundColor: const Color(0xFF3B82F6),
                  textColor: Colors.white,
                  fontSize: 11,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Live Calendar Summary Card
            NeoBrutalCard(
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('construction_time_equivalence_hint'),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Primary Button: Fast Forward 1 Game Day via Rewarded Ad
            NeoBrutalButton(
              label: context.tr('hud_time_fast_forward_btn'),
              icon: Icons.fast_forward_rounded,
              backgroundColor: const Color(0xFFF59E0B),
              textColor: Colors.black,
              fontSize: 13,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.of(context).pop();
                AdService.instance.showRewardedAdWithFallback(
                  context: context,
                  customRewardTitle: context.tr('hud_time_fast_forward_btn'),
                  onRewardEarned: () {
                    final ok = ref.read(gameProvider.notifier).fastForwardGameDay(days: 1);
                    if (ok) {
                      NotificationService.showSuccess(
                        context,
                        context.tr('hud_time_fast_forward_toast'),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 10),

            // Secondary Button: Open Sales & Ledger History
            NeoBrutalButton(
              label: context.tr('hud_time_view_history_btn'),
              icon: Icons.history_edu_rounded,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              textColor: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 12.5,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
                context.push('/history');
              },
            ),
          ],
        ),
      ),
    );
  }
}
