import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/scrapyard_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class ScrapyardSearchZoneDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.90,
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF10131B) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.black, width: 3.0),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('scrap_zone_search_title'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      NeoBrutalBadge(
                        text: context.tr('scrap_remaining_searches_badge',
                            {'count': '${game.remainingScrapSearchesToday}'}),
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1F293D)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.brutalBlue, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.record_voice_over_rounded,
                            size: 16, color: AppColors.brutalBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ScrapyardZoneExtension.getDailySanayiRumor(
                                game.currentDay,
                                langCode:
                                    Localizations.localeOf(ctx).languageCode),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...ScrapyardZoneType.values.map((zone) {
                    final canAfford = game.balance >= zone.cost;
                    final hasRemaining = game.remainingScrapSearchesToday > 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(12),
                        backgroundColor: isDark
                            ? const Color(0xFF161B26)
                            : const Color(0xFFF8FAFC),
                        borderColor: zone.color,
                        borderWidth: 2.0,
                        borderRadius: 12,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: zone.color,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                              ),
                              child:
                                  Icon(zone.icon, color: Colors.black, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    zone.title,
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    zone.description,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            NeoBrutalButton(
                              label: CurrencyFormatter.formatShort(zone.cost),
                              backgroundColor: (canAfford && hasRemaining)
                                  ? zone.color
                                  : Colors.grey,
                              textColor: Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              onPressed: (canAfford && hasRemaining)
                                  ? () {
                                      Navigator.pop(ctx);
                                      final found = ref
                                          .read(gameProvider.notifier)
                                          .searchScrapForTreasures(zone: zone);
                                      if (found != null) {
                                        if (found > 0) {
                                          NotificationService.showSuccess(
                                            context,
                                            '${zone.title} taramasında +${CurrencyFormatter.format(found)} değerinde parça ve hazine buldun!',
                                          );
                                        } else {
                                          NotificationService.showWarning(
                                            context,
                                            '${zone.title} bölgesinde bu sefer değerli bir şey çıkmadı.',
                                          );
                                        }
                                      } else {
                                        NotificationService.showError(context,
                                            context.tr('toast_insufficient_daily_search'));
                                      }
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
