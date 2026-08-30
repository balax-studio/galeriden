import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme_extension.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/usecases/weekly_event_engine.dart';
import '../providers/game_provider.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';

class DailyBulletinDialog extends ConsumerWidget {
  const DailyBulletinDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const DailyBulletinDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final weeklyEvent = WeeklyEventEngine.getEventForDay(game.currentDay);
    final dayNames = [
      context.tr('day_monday'),
      context.tr('day_tuesday'),
      context.tr('day_wednesday'),
      context.tr('day_thursday'),
      context.tr('day_friday'),
      context.tr('day_saturday'),
      context.tr('day_sunday'),
    ];
    final currentDayName = dayNames[(weeklyEvent.dayOfWeek - 1).clamp(0, 6)];
    final season = WeeklyEventEngine.getCurrentSeasonName(game.currentDay);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(18),
        backgroundColor:
            isDark ? const Color(0xFF141721) : const Color(0xFFFFFBEB),
        borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
        borderWidth: 2.5,
        borderRadius: 16,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Newspaper Masthead (§1.2 / Q4)
              Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr(
                            'bulletin_day_header', {'day': game.currentDay}),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        context.tr('bulletin_issue_number'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('bulletin_masthead_title'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('bulletin_season_info',
                        {'day': currentDayName, 'season': season}),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Active Weekly Micro-Event Box
            NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? const Color(0xFF1E2330) : Colors.white,
              borderColor: const Color(0xFFFF7A00),
              borderWidth: 1.5,
              borderRadius: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.newspaper_rounded,
                              size: 16, color: Color(0xFFFF7A00)),
                          const SizedBox(width: 6),
                          Text(
                            weeklyEvent.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      NeoBrutalBadge(
                        text: context.tr('bulletin_headline_badge'),
                        backgroundColor: const Color(0xFFFFDE59),
                        textColor: Colors.black,
                        fontSize: 9,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    weeklyEvent.description,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Season & Economy Summary
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A1F2C)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFFCBD5E1),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('bulletin_vault_status'),
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B)),
                        ),
                        Text(
                          CurrencyFormatter.formatShort(game.balance),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1A1F2C)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFFCBD5E1),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('bulletin_reputation_status'),
                          style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B)),
                        ),
                        Text(
                          context.tr('bulletin_reputation_pts',
                              {'score': game.reputation}),
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00E575)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Close & Start Day Button
            NeoBrutalButton(
              label: context.tr('bulletin_close_btn'),
              icon: Icons.check_circle_rounded,
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
