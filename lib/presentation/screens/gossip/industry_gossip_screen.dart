import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/gossip_item_model.dart';
import '../../../domain/usecases/gossip_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/ads/neo_brutal_native_ad_card.dart';

class IndustryGossipScreen extends ConsumerWidget {
  const IndustryGossipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/gossip')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('gossip_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/gossip',
          featureTitle: context.tr('gossip_screen_title'),
          icon: Icons.campaign_rounded,
        ),
      );
    }

    final gossips = game.activeGossips.isNotEmpty
        ? game.activeGossips
        : GossipEngine.generateDailyGossips(game.currentDay);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('gossip_screen_title'),
        subtitle: context.tr('gossip_slug'),
        headerAnimation: NeoBrutalHeaderAnimation.radioGlitch,
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // Header Info Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor:
                isDark ? const Color(0xFF1E1E2E) : const Color(0xFFFFFBEB),
            borderColor: AppColors.brutalYellow,
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.record_voice_over_rounded,
                      color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('gossip_banner_title'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('gossip_banner_desc'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Market Whisperer: Piyasaya Dedikodu Salma Aksiyon Kartı
          _buildMarketWhispererCard(context, ref, isDark, game),
          const SizedBox(height: 14),

          // Sektör Bülteni Native Ad / Fallback
          const NeoBrutalNativeAdCard(
            contextType: NativeAdContextType.gossip,
            margin: EdgeInsets.only(bottom: 14),
          ),

          if (gossips.isEmpty)
            NeoBrutalEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: context.tr('gossip_empty_title'),
              description: context.tr('gossip_empty_desc'),
            )
          else ...[
            Text(
              context.tr('gossip_active_count', {'count': '${gossips.length}'}),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),
            ...gossips.map(
                (gossip) => _buildGossipCard(context, ref, gossip, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildGossipCard(
    BuildContext context,
    WidgetRef ref,
    GossipItemModel gossip,
    bool isDark,
  ) {
    final game = ref.watch(gameProvider);
    final canAfford = game.balance >= gossip.cost;

    Color sourceColor = AppColors.brutalYellow;
    IconData sourceIcon = Icons.local_cafe_rounded;

    if (gossip.sourceNpcName.contains('Berk')) {
      sourceColor = AppColors.brutalCyan;
      sourceIcon = Icons.videocam_rounded;
    } else if (gossip.sourceNpcName.contains('İbo')) {
      sourceColor = AppColors.brutalOrange;
      sourceIcon = Icons.build_circle_rounded;
    } else if (gossip.sourceNpcName.contains('Selim')) {
      sourceColor = AppColors.brutalGreen;
      sourceIcon = Icons.engineering_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
        borderColor: gossip.isPurchased
            ? AppColors.brutalGreen
            : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NPC Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: sourceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(sourceIcon, size: 18, color: Colors.black),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gossip.sourceNpcName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        gossip.sourceTitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: context.tr('gossip_badge_trust',
                      {'trust': '${(gossip.accuracyRate * 100).round()}'}),
                  backgroundColor: gossip.accuracyRate >= 0.85
                      ? AppColors.brutalGreen
                      : (gossip.accuracyRate >= 0.70
                          ? AppColors.brutalYellow
                          : AppColors.brutalOrange),
                  textColor: Colors.black,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Teaser / Content Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF262C3D)
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        gossip.isPurchased
                            ? Icons.lock_open_rounded
                            : Icons.lock_outline_rounded,
                        size: 14,
                        color: gossip.isPurchased
                            ? AppColors.brutalGreen
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        gossip.isPurchased
                            ? context.tr('gossip_unlocked_title')
                            : context.tr('gossip_teaser_title'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: gossip.isPurchased
                              ? AppColors.brutalGreen
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    gossip.isPurchased ? gossip.fullContent : gossip.teaserText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: gossip.isPurchased
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontStyle: gossip.isPurchased
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action / Cost Row
            if (gossip.isPurchased)
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.brutalGreen, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    context.tr('gossip_purchased_label'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brutalGreen,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('gossip_cost_label'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.format(
                              (game.hasHighNpcTrust(
                                      gossip.sourceNpc == 'cayci_necati'
                                          ? 'necati'
                                          : gossip.sourceNpc))
                                  ? (gossip.cost * 0.50).roundToDouble()
                                  : gossip.cost,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: canAfford
                                  ? AppColors.brutalGreen
                                  : AppColors.errorRed,
                            ),
                          ),
                          if (game.hasHighNpcTrust(
                              gossip.sourceNpc == 'cayci_necati'
                                  ? 'necati'
                                  : gossip.sourceNpc)) ...[
                            const SizedBox(width: 6),
                            NeoBrutalBadge(
                              text: context
                                  .tr('gossip_friend_discount', {'pct': '50'}),
                              backgroundColor: AppColors.brutalGreen,
                              textColor: Colors.black,
                              fontSize: 9,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  NeoBrutalButton(
                    label: context.tr('gossip_btn_buy'),
                    backgroundColor: canAfford
                        ? AppColors.brutalYellow
                        : const Color(0xFF64748B),
                    textColor: Colors.black,
                    onPressed: canAfford
                        ? () {
                            final success = ref
                                .read(gameProvider.notifier)
                                .buyGossipItem(gossip);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                context.tr('gossip_toast_intel_received'),
                              );
                            }
                          }
                        : () {
                            NotificationService.showWarning(
                                context, context.tr('insufficient_balance'));
                          },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketWhispererCard(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    dynamic game,
  ) {
    final alreadySpreadToday = game.lastGossipSpreadDay >= game.currentDay;
    final canAfford = game.balance >= 2500.0;
    final activeRumors = game.playerSpreadGossips
        .where((r) => !r.isExpired(game.currentDay))
        .toList();

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor:
          isDark ? const Color(0xFF16202E) : const Color(0xFFEFF6FF),
      borderColor: AppColors.brutalCyan,
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brutalCyan,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
                child: const Icon(Icons.campaign_rounded,
                    color: Colors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('gossip_whisperer_card_title'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      context.tr('gossip_whisperer_card_subtitle'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('gossip_whisperer_card_desc'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.35,
              color: isDark
                  ? const Color(0xFFCBD5E1)
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (activeRumors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.brutalCyan.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('gossip_active_rumors_heading'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark
                          ? AppColors.brutalCyan
                          : const Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...activeRumors.map((rumor) {
                    final remainingDays = rumor.expiresDay - game.currentDay;
                    return Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 13, color: AppColors.brutalGreen),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              context.tr('gossip_rumor_active_pill', {
                                'segment': rumor.targetSegment,
                                'days': '$remainingDays',
                              }),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: alreadySpreadToday
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.tr('gossip_whisperer_already_spread'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  )
                : NeoBrutalButton(
                    label: context.tr('gossip_whisperer_btn_action'),
                    icon: Icons.local_cafe_rounded,
                    backgroundColor: canAfford
                        ? AppColors.brutalCyan
                        : const Color(0xFF64748B),
                    textColor: Colors.black,
                    onPressed: canAfford
                        ? () => _showSpreadRumorSheet(
                            context, ref, isDark, game)
                        : () {
                            NotificationService.showWarning(
                                context, context.tr('insufficient_balance'));
                          },
                  ),
          ),
        ],
      ),
    );
  }

  void _showSpreadRumorSheet(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    dynamic game,
  ) {
    const segments = [
      ('Sedan', Icons.directions_car_rounded, AppColors.brutalBlue),
      ('Hatchback', Icons.directions_car_filled_rounded, AppColors.brutalGreen),
      ('SUV', Icons.airport_shuttle_rounded, AppColors.brutalOrange),
      ('Spor', Icons.speed_rounded, AppColors.brutalRed),
      ('Klasik', Icons.radio_rounded, AppColors.brutalPurple),
      ('Ticari', Icons.local_shipping_rounded, AppColors.brutalYellow),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? const Color(0xFF161922) : const Color(0xFFF8FAFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('gossip_modal_pick_segment_title'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  context.tr('gossip_modal_pick_segment_desc'),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: segments.map((item) {
                    final segName = item.$1;
                    final segIcon = item.$2;
                    final segColor = item.$3;
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.pop(ctx);
                        final success = ref
                            .read(gameProvider.notifier)
                            .spreadMarketRumor(segName, 2500.0);
                        if (success) {
                          NotificationService.showSuccess(
                            context,
                            context.tr('gossip_whisperer_success_toast',
                                {'segment': segName}),
                          );
                        } else {
                          NotificationService.showWarning(
                            context,
                            context.tr('insufficient_balance'),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2330)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: segColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(segIcon,
                                  size: 16, color: Colors.black),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              segName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
