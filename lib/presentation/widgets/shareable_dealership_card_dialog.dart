import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/notification_service.dart';
import '../providers/game_provider.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';

class ShareableDealershipCardDialog extends ConsumerWidget {
  const ShareableDealershipCardDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ShareableDealershipCardDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final bestCar = game.ownedCars.isNotEmpty
        ? (game.ownedCars.toList()
              ..sort((a, b) =>
                  b.estimatedRealValue.compareTo(a.estimatedRealValue)))
            .first
        : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          child: RepaintBoundary(
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor:
                  isDark ? const Color(0xFF161922) : const Color(0xFFFFFBEB),
              borderColor: AppColors.brutalYellow,
              borderRadius: 20,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeoBrutalBadge(
                        text: context.tr('dealership_certificate_title'),
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 10,
                      ),
                      Text(
                        context.tr(
                            'dealership_day_badge', {'day': game.currentDay}),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dealership Emblem & Title
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.brutalYellow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        width: 2.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.storefront_rounded,
                              color: AppColors.brutalYellow, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.dealershipName.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                game.rpgTitle.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          title: context.tr('label_total_profit'),
                          value:
                              CurrencyFormatter.formatShort(game.totalProfit),
                          color: AppColors.brutalGreen,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          title: context.tr('label_sold_cars'),
                          value: context
                              .tr('label_sold_count', {'count': game.carsSold}),
                          color: AppColors.brutalYellow,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          title: context.tr('label_reputation_pts'),
                          value: '${game.reputationScore} / 100',
                          color: AppColors.brutalCyan,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          title: context.tr('label_garage_value'),
                          value: CurrencyFormatter.formatShort(
                            game.ownedCars.fold<double>(
                                0, (sum, c) => sum + c.estimatedRealValue),
                          ),
                          color: AppColors.brutalOrange,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Best Car Showcase Highlight
                  if (bestCar != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F1117) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF262C3D)
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.diamond_rounded,
                              color: AppColors.brutalYellow, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('label_showcase_star'),
                                  style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textSecondaryLight),
                                ),
                                Text(
                                  bestCar.modelName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatShort(
                                bestCar.estimatedRealValue),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Share Buttons
                  Row(
                    children: [
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('btn_close'),
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          textColor:
                              isDark ? Colors.white70 : const Color(0xFF64748B),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('btn_copy_text'),
                          icon: Icons.copy_rounded,
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          onPressed: () {
                            final shareText =
                                '${game.dealershipName} • ${game.rpgTitle}\n${context.tr('label_total_profit')}: ${CurrencyFormatter.format(game.totalProfit)}\n${context.tr('label_sold_cars')}: ${context.tr('label_sold_count', {
                                  'count': game.carsSold
                                })}\n${context.tr('label_reputation_pts')}: ${game.reputationScore}\n${context.tr('app_name')}!';
                            Clipboard.setData(ClipboardData(text: shareText));
                            NotificationService.showSuccess(
                                context, context.tr('toast_card_copied'));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStatBox({
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1117) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
