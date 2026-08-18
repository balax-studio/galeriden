import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/gossip_item_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

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
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'SANAYİ DEDİKODU HATTI'),
        body: const NeoBrutalLockedFeatureView(
          route: '/gossip',
          featureTitle: 'SANAYİ DEDİKODU HATTI',
          icon: Icons.campaign_rounded,
        ),
      );
    }

    final gossips = game.activeGossips;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'SANAYİ DEDİKODU HATTI',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // Header Info Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFFFFBEB),
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
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.record_voice_over_rounded, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KULAKTAN KULAĞA İSTİHBARAT',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sanayi çaycısından YouTube vloggerına kadar herkesin bir duyumu var. Bilgiyi erkenden satın al, piyasayı önden kokla!',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (gossips.isEmpty)
            const NeoBrutalEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'BUGÜN DEDİKODU YOK',
              description: 'Sanayide bugün sular durgun. Yeni dedikodular ve kulis bilgileri için yeni güne geç.',
            )
          else ...[
            Text(
              'GÜNCEL DUYUMLAR • ${gossips.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),
            ...gossips.map((gossip) => _buildGossipCard(context, ref, gossip, isDark)),
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
        borderColor: gossip.isPurchased ? AppColors.brutalGreen : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
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
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
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
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        gossip.sourceTitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: '%${(gossip.accuracyRate * 100).round()} GÜVEN',
                  backgroundColor: gossip.accuracyRate >= 0.85
                      ? AppColors.brutalGreen
                      : (gossip.accuracyRate >= 0.70 ? AppColors.brutalYellow : AppColors.brutalOrange),
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
                color: isDark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        gossip.isPurchased ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                        size: 14,
                        color: gossip.isPurchased ? AppColors.brutalGreen : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        gossip.isPurchased ? 'AÇILAN İSTİHBARAT' : 'KULİS FISILTISI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: gossip.isPurchased ? AppColors.brutalGreen : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    gossip.isPurchased ? gossip.fullContent : gossip.teaserText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: gossip.isPurchased ? FontWeight.w700 : FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontStyle: gossip.isPurchased ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action / Cost Row
            if (gossip.isPurchased)
              Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: AppColors.brutalGreen, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'İstihbarat Satın Alındı & Değerlendirildi',
                    style: TextStyle(
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
                      const Text(
                        'İSTİHBARAT ÜCRETİ',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.format(
                              (game.hasHighNpcTrust(gossip.sourceNpc == 'cayci_necati' ? 'necati' : gossip.sourceNpc))
                                  ? (gossip.cost * 0.50).roundToDouble()
                                  : gossip.cost,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: canAfford ? AppColors.brutalGreen : AppColors.errorRed,
                            ),
                          ),
                          if (game.hasHighNpcTrust(gossip.sourceNpc == 'cayci_necati' ? 'necati' : gossip.sourceNpc)) ...[
                            const SizedBox(width: 6),
                            const NeoBrutalBadge(
                              text: '-%50 DOST İNDİRİMİ',
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
                    label: 'BİLGİYİ SATIN AL',
                    backgroundColor: canAfford ? AppColors.brutalYellow : const Color(0xFF64748B),
                    textColor: Colors.black,
                    onPressed: canAfford
                        ? () {
                            final success = ref.read(gameProvider.notifier).buyGossipItem(gossip);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                '${gossip.sourceNpcName} istihbaratı verdi! İpuçlarını kontrol et.',
                              );
                            }
                          }
                        : () {
                            NotificationService.showWarning(context, 'Yeterli paranız yok.');
                          },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
