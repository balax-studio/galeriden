import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/pr_campaign_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class MediaAgencyScreen extends ConsumerStatefulWidget {
  const MediaAgencyScreen({super.key});

  @override
  ConsumerState<MediaAgencyScreen> createState() => _MediaAgencyScreenState();
}

class _MediaAgencyScreenState extends ConsumerState<MediaAgencyScreen> {
  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);
    final activePr = game.activePrCampaign;
    final isCampaignRunning =
        activePr != null && activePr.isActive(game.currentDay);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('media_agency_title'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: NeoBrutalBadge(
                text: CurrencyFormatter.formatShort(game.balance),
                backgroundColor: const Color(0xFFFFDE59),
                textColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // Active Campaign Status Banner
          if (isCampaignRunning) ...[
            NeoBrutalCard(
              borderColor: const Color(0xFF38BDF8),
              borderWidth: 2.5,
              backgroundColor:
                  isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F9FF),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded,
                          color: Color(0xFF38BDF8), size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr('media_active_pr_title'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF38BDF8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      NeoBrutalBadge(
                        text: context.tr('media_duration_badge', {
                          'days': '${activePr.remainingDays(game.currentDay)}'
                        }),
                        backgroundColor: const Color(0xFF38BDF8),
                        textColor: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activePr.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFBAE6FD),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                            context.tr('media_stat_customer_flow'),
                            '+%${((activePr.customerFlowMultiplier - 1) * 100).toInt()}',
                            const Color(0xFF10B981),
                            isDark),
                        _buildStatItem(
                            context.tr('media_stat_offer_price'),
                            '+%${(activePr.offerPriceBoost * 100).toInt()}',
                            const Color(0xFFFFDE59),
                            isDark),
                        _buildStatItem(
                            context.tr('media_stat_negotiation_ease'),
                            '-%${(activePr.negotiationResistanceReduction * 100).toInt()}',
                            const Color(0xFF38BDF8),
                            isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            NeoBrutalCard(
              borderColor:
                  isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderWidth: 2,
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFF0F172A),
                          width: 1.5),
                    ),
                    child: const Icon(Icons.campaign_rounded,
                        color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.tr('media_info_card_text'),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          Text(
            context.tr('media_agency_title'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          // Campaign Cards
          ...PrCampaignModel.campaigns.map((campaign) {
            final canAfford = game.balance >= campaign.cost;
            final isCurrent =
                activePr?.campaignId == campaign.id && isCampaignRunning;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                borderColor: isCurrent
                    ? const Color(0xFF38BDF8)
                    : (isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFF0F172A)),
                borderWidth: isCurrent ? 2.5 : 2,
                backgroundColor: isCurrent
                    ? (isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF0F9FF))
                    : (isDark ? const Color(0xFF141721) : Colors.white),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getCampaignIconBg(campaign.id, isDark),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF0F172A),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getCampaignIcon(campaign.id),
                            color: _getCampaignIconColor(campaign.id),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campaign.title,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  NeoBrutalBadge(
                                    text: context.tr('media_duration_badge',
                                        {'days': campaign.durationDays}),
                                    backgroundColor: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0),
                                    textColor:
                                        isDark ? Colors.white : Colors.black,
                                    fontSize: 10,
                                  ),
                                  const SizedBox(width: 6),
                                  NeoBrutalBadge(
                                    text: context.tr('media_reputation_badge',
                                        {'points': campaign.reputationReward}),
                                    backgroundColor: const Color(0xFFFFDE59),
                                    textColor: Colors.black,
                                    fontSize: 10,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      campaign.description,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Perks Badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildPerkChip(
                            context.tr('media_chip_customer_flow', {
                              'percent':
                                  ((campaign.customerFlowMultiplier - 1) * 100)
                                      .toInt()
                            }),
                            const Color(0xFF10B981),
                            isDark),
                        _buildPerkChip(
                            context.tr('media_chip_offer_value', {
                              'percent':
                                  (campaign.offerPriceBoost * 100).toInt()
                            }),
                            const Color(0xFFFFDE59),
                            isDark),
                        _buildPerkChip(
                            context.tr('media_chip_negotiation_ease', {
                              'percent':
                                  (campaign.negotiationResistanceReduction *
                                          100)
                                      .toInt()
                            }),
                            const Color(0xFF38BDF8),
                            isDark),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyFormatter.formatShort(campaign.cost),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: canAfford
                                    ? (isDark
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFF0284C7))
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                        NeoBrutalButton(
                          label: isCurrent
                              ? context.tr('media_btn_campaign_active')
                              : context.tr('media_btn_start_campaign'),
                          backgroundColor: isCurrent
                              ? const Color(0xFF10B981)
                              : (canAfford && !isCampaignRunning
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF64748B)),
                          textColor:
                              isCurrent || (canAfford && !isCampaignRunning)
                                  ? Colors.black
                                  : Colors.white,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          onPressed: canAfford && !isCampaignRunning
                              ? () => _startCampaign(campaign)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPerkChip(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withAlpha(40) : color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(120), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
    );
  }

  IconData _getCampaignIcon(String campaignId) {
    switch (campaignId) {
      case 'pr_youtube_influencer':
        return Icons.smart_display_rounded;
      case 'pr_tv_sponsor':
        return Icons.live_tv_rounded;
      case 'pr_billboards':
        return Icons.view_carousel_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  Color _getCampaignIconColor(String campaignId) {
    switch (campaignId) {
      case 'pr_youtube_influencer':
        return const Color(0xFFEF4444);
      case 'pr_tv_sponsor':
        return const Color(0xFF38BDF8);
      case 'pr_billboards':
        return const Color(0xFFFFDE59);
      default:
        return Colors.black;
    }
  }

  Color _getCampaignIconBg(String campaignId, bool isDark) {
    switch (campaignId) {
      case 'pr_youtube_influencer':
        return isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
      case 'pr_tv_sponsor':
        return isDark ? const Color(0xFF082F49) : const Color(0xFFE0F2FE);
      case 'pr_billboards':
        return isDark ? const Color(0xFF422006) : const Color(0xFFFEF08A);
      default:
        return isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    }
  }

  void _startCampaign(PrCampaignModel campaign) {
    final success = ref.read(gameProvider.notifier).startPrCampaign(campaign);
    if (success) {
      NotificationService.showSuccess(
        context,
        context.tr('media_start_success_toast', {'agency': campaign.title}),
      );
    } else {
      NotificationService.showError(
        context,
        context.tr('media_insufficient_funds_toast', {
          'cost': CurrencyFormatter.format(campaign.cost),
          'agency': campaign.title
        }),
      );
    }
  }
}
