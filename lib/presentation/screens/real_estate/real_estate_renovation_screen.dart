import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class RealEstateRenovationScreen extends ConsumerWidget {
  final String propertyId;

  const RealEstateRenovationScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final game = ref.watch(gameProvider);

    final propertyIndex =
        game.ownedRealEstates.indexWhere((p) => p.id == propertyId);

    if (propertyIndex == -1) {
      return Scaffold(
        appBar: NeoBrutalAppBar(
          title: context.tr('real_estate_renovation_title'),
          onLeadingPressed: () => context.pop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              context.tr('real_estate_empty_portfolio_title'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final property = game.ownedRealEstates[propertyIndex];
    final stageCost =
        (property.category.renovationBaseCost / 3).roundToDouble();
    final canAffordStage = game.balance >= stageCost;
    final isFinished = property.renovationStage >= 3 || property.isRenovated;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: context.tr('real_estate_renovation_title'),
        onLeadingPressed: () => context.pop(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NeoBrutalBadge(
              text: isFinished
                  ? context.tr('real_estate_badge_renovated')
                  : context.tr('real_estate_workshop_badge'),
              backgroundColor: isFinished
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFFEF3C7),
              textColor: Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PROPERTY OVERVIEW CARD
            _buildPropertyOverviewCard(context, theme, property, isDark),
            const SizedBox(height: 14),

            // 2. ZEIGARNIK SUSPENSE PROGRESS BAR
            _buildZeigarnikProgressCard(context, theme, property, isDark),
            const SizedBox(height: 14),

            // 3. WATER LEAK WARNING CARD (If rushed)
            if (property.hasWaterLeakRisk) ...[
              _buildWaterLeakCard(context, theme, property, game.balance, ref, isDark),
              const SizedBox(height: 14),
            ],

            // 4. THREE RENOVATION STAGE MILESTONES
            _buildStageMilestoneCard(
              context: context,
              stageNumber: 1,
              title: context.tr('real_estate_stage1_title'),
              description: context.tr('real_estate_stage1_desc'),
              cost: stageCost,
              currentStage: property.renovationStage,
              icon: Icons.plumbing_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildStageMilestoneCard(
              context: context,
              stageNumber: 2,
              title: context.tr('real_estate_stage2_title'),
              description: context.tr('real_estate_stage2_desc'),
              cost: stageCost,
              currentStage: property.renovationStage,
              icon: Icons.countertops_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            _buildStageMilestoneCard(
              context: context,
              stageNumber: 3,
              title: context.tr('real_estate_stage3_title'),
              description: context.tr('real_estate_stage3_desc'),
              cost: stageCost,
              currentStage: property.renovationStage,
              icon: Icons.format_paint_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // 5. RUSHED RENOVATION AD LORE CARD (Only visible if not finished)
            if (!isFinished) ...[
              _buildRushedRenovationCard(context, theme, property, ref, isDark),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141721) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2A3142) : Colors.black,
              width: 2,
            ),
          ),
        ),
        child: SafeArea(
          child: isFinished
              ? Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('real_estate_renovation_zeigarnik_stage3'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    NeoBrutalButton(
                      label: context.tr('real_estate_dialog_btn_cancel'),
                      onPressed: () => context.pop(),
                      backgroundColor: const Color(0xFFE2E8F0),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${property.renovationStage + 1}. AŞAMA MALİYETİ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(stageCost),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Builder(
                        builder: (context) {
                          final isWorkInProgress = property.renovationDaysRemaining > 0;
                          final canStart = canAffordStage && !isWorkInProgress;

                          return NeoBrutalButton(
                            label: isWorkInProgress
                                ? context.tr('real_estate_renovation_in_progress', {
                                    'days': '${property.renovationDaysRemaining}',
                                  })
                                : (canAffordStage
                                    ? context.tr('real_estate_stage_btn_start')
                                    : context.tr('real_estate_expand_slots_error_funds')),
                            icon: isWorkInProgress
                                ? Icons.hourglass_top_rounded
                                : Icons.handyman_rounded,
                            backgroundColor: canStart
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF94A3B8),
                            onPressed: canStart
                                ? () {
                                    HapticFeedback.mediumImpact();
                                    final success = ref
                                        .read(gameProvider.notifier)
                                        .advanceRenovationStage(property.id);
                                    if (success) {
                                      NotificationService.showSuccess(
                                        context,
                                        context.tr('real_estate_renovation_success_toast'),
                                      );
                                    }
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPropertyOverviewCard(
    BuildContext context,
    ThemeData theme,
    RealEstateModel property,
    bool isDark,
  ) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: property.category.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: property.category.accentColor, width: 2),
            ),
            child: Icon(property.category.icon,
                color: property.category.accentColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  '${property.city} • ${property.district} • ${property.squareMeters} m²',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    NeoBrutalBadge(
                      text: context.tr(property.deedType.localizationKey),
                      backgroundColor: const Color(0xFFE2E8F0),
                    ),
                    NeoBrutalBadge(
                      text: property.roomCount,
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZeigarnikProgressCard(
    BuildContext context,
    ThemeData theme,
    RealEstateModel property,
    bool isDark,
  ) {
    final percent = property.renovationPercent;
    String statusText;
    switch (property.renovationStage) {
      case 1:
        statusText = context.tr('real_estate_renovation_zeigarnik_stage1');
        break;
      case 2:
        statusText = context.tr('real_estate_renovation_zeigarnik_stage2');
        break;
      case 3:
        statusText = context.tr('real_estate_renovation_zeigarnik_stage3');
        break;
      default:
        statusText = context.tr('real_estate_renovation_zeigarnik_stage0');
        break;
    }

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: percent == 100
          ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB)),
      borderColor: percent == 100
          ? const Color(0xFF059669)
          : const Color(0xFFD97706),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    percent == 100
                        ? Icons.verified_rounded
                        : Icons.hourglass_top_rounded,
                    color: percent == 100
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ZEIGARNIK İLERLEME ENDEKSİ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: percent == 100
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
              Text(
                '%$percent',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Thick Neobrutalist Progress Track
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (percent / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: percent == 100
                      ? const Color(0xFF10B981)
                      : (percent >= 70
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFEF4444)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Headline
          Text(
            statusText,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),

          // Subtitle warning
          Text(
            context.tr('real_estate_renovation_zeigarnik_warning'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          if (property.renovationDaysRemaining > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.tr('real_estate_renovation_in_progress', {
                        'days': '${property.renovationDaysRemaining}',
                      }),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaterLeakCard(
    BuildContext context,
    ThemeData theme,
    RealEstateModel property,
    double balance,
    WidgetRef ref,
    bool isDark,
  ) {
    const repairCost = 5000.0;
    final canAffordRepair = balance >= repairCost;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2),
      borderColor: const Color(0xFFDC2626),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_damage_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('real_estate_leak_alert_title'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
              NeoBrutalBadge(
                text: context.tr('real_estate_leak_badge'),
                backgroundColor: const Color(0xFFFEE2E2),
                textColor: const Color(0xFF991B1B),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('real_estate_leak_alert_desc'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: NeoBrutalButton(
              label: '${context.tr('real_estate_leak_repair_btn')} • ${CurrencyFormatter.format(repairCost)}',
              icon: Icons.build_circle_rounded,
              backgroundColor: canAffordRepair
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF94A3B8),
              textColor: Colors.white,
              onPressed: canAffordRepair
                  ? () {
                      HapticFeedback.heavyImpact();
                      final ok = ref
                          .read(gameProvider.notifier)
                          .repairWaterLeak(property.id);
                      if (ok) {
                        NotificationService.showSuccess(
                          context,
                          'Tesisat onarıldı • Su kaçağı tehlikesi giderildi.',
                        );
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageMilestoneCard({
    required BuildContext context,
    required int stageNumber,
    required String title,
    required String description,
    required double cost,
    required int currentStage,
    required IconData icon,
    required bool isDark,
  }) {
    final isCompleted = currentStage >= stageNumber;
    final isCurrent = currentStage == stageNumber - 1;

    Color badgeBg;
    Color badgeFg;
    String badgeText;

    if (isCompleted) {
      badgeBg = const Color(0xFFD1FAE5);
      badgeFg = const Color(0xFF065F46);
      badgeText = 'TAMAMLANDI';
    } else if (isCurrent) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeFg = const Color(0xFF92400E);
      badgeText = 'SIRADAKİ';
    } else {
      badgeBg = const Color(0xFFF1F5F9);
      badgeFg = const Color(0xFF64748B);
      badgeText = 'KİLİTLİ';
    }

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isCompleted
          ? (isDark ? const Color(0xFF14241E) : const Color(0xFFF0FDF4))
          : (isDark ? const Color(0xFF1E2330) : Colors.white),
      borderColor: isCompleted
          ? const Color(0xFF10B981)
          : (isCurrent ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : const Color(0xFF64748B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF64748B),
                width: 1.5,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : icon,
              size: 20,
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$stageNumber. $title',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    NeoBrutalBadge(
                      text: badgeText,
                      backgroundColor: badgeBg,
                      textColor: badgeFg,
                      fontSize: 9,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Maliyet: ${CurrencyFormatter.format(cost)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRushedRenovationCard(
    BuildContext context,
    ThemeData theme,
    RealEstateModel property,
    WidgetRef ref,
    bool isDark,
  ) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF291B07) : const Color(0xFFFEF3C7),
      borderColor: const Color(0xFFD97706),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flash_on_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.tr('real_estate_rush_title'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              NeoBrutalBadge(
                text: context.tr('real_estate_rush_btn'),
                backgroundColor: const Color(0xFFF59E0B),
                textColor: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('real_estate_rush_desc'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: NeoBrutalButton(
              label: context.tr('real_estate_rush_btn'),
              icon: Icons.video_library_rounded,
              backgroundColor: const Color(0xFFF59E0B),
              onPressed: () {
                HapticFeedback.heavyImpact();
                ref.read(gameProvider.notifier).rushRenovation(property.id);
                NotificationService.showWarning(
                  context,
                  'Usta aceleye getirdi • Gizli su kaçağı riski doğdu!',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
