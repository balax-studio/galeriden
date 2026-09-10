import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

/// Modal dialog celebrating the completion of a weekly season and unlocking podium rewards.
class LeaderboardSeasonRewardDialog extends ConsumerWidget {
  final DealershipModel game;
  final bool isDark;

  const LeaderboardSeasonRewardDialog({
    super.key,
    required this.game,
    required this.isDark,
  });

  static Future<void> show(
    BuildContext context, {
    required DealershipModel game,
    required bool isDark,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LeaderboardSeasonRewardDialog(
        game: game,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rank = game.lastClaimedSeasonRank;
    final perks = game.activePodiumPerks;
    final borderColor = isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A);
    final bgColor = isDark ? const Color(0xFF131722) : Colors.white;

    Color rankColor;
    String rankTitle;
    IconData trophyIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankTitle = context.tr('podium_tier_1_title');
      trophyIcon = Icons.workspace_premium_rounded;
    } else if (rank == 2) {
      rankColor = const Color(0xFFE2E8F0);
      rankTitle = context.tr('podium_tier_2_title');
      trophyIcon = Icons.shield_rounded;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankTitle = context.tr('podium_tier_3_title');
      trophyIcon = Icons.handshake_rounded;
    } else {
      rankColor = const Color(0xFF38BDF8);
      rankTitle = context.tr('podium_tier_runner_title');
      trophyIcon = Icons.verified_rounded;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 3.0),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black : const Color(0xFF0F172A),
              offset: const Offset(5, 5),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge
            Center(
              child: NeoBrutalBadge(
                text: 'HAFTALIK SEZON TAMAMLANDI',
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                borderWidth: 2.0,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(height: 16),

            // Trophy / Medal Emblem
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: rankColor, width: 3.0),
                ),
                child: Icon(
                  trophyIcon,
                  color: rankColor,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Rank & Title
            Text(
              '$rank • $rankTitle',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('podium_dialog_congrats_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),

            // Perks Unlocked Card
            NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? const Color(0xFF1E2433) : const Color(0xFFF8FAFC),
              borderColor: borderColor,
              borderWidth: 2.0,
              borderRadius: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('podium_dialog_perks_title'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (perks?.customPlateTitle != null)
                    _buildPerkRow(
                      icon: Icons.confirmation_number_rounded,
                      title: 'Özel Plaka Tescili: ${perks!.customPlateTitle}',
                      color: AppColors.brutalCyan,
                      isDark: isDark,
                    ),

                  if (perks != null && perks.notaryDiscountRate > 0)
                    _buildPerkRow(
                      icon: Icons.gavel_rounded,
                      title: 'Noter Devir Harcı Muafiyeti: %${(perks.notaryDiscountRate * 100).round()} İndirim',
                      color: AppColors.toxicLime,
                      isDark: isDark,
                    ),

                  if (perks?.hasCustomsAuctionPass == true)
                    _buildPerkRow(
                      icon: Icons.lock_open_rounded,
                      title: 'Gümrük Tasfiye İhalesi Giriş Kartı',
                      color: const Color(0xFFFFD700),
                      isDark: isDark,
                    ),

                  if (perks?.hasGulfBuyerNetwork == true)
                    _buildPerkRow(
                      icon: Icons.currency_exchange_rounded,
                      title: 'Körfez Alıcıları Ağı: Lüks Araçlarda %15 Primli Nakit Alım',
                      color: AppColors.brutalGreen,
                      isDark: isDark,
                    ),

                  if (perks?.hasFleetLiquidationProtocol == true)
                    _buildPerkRow(
                      icon: Icons.directions_car_rounded,
                      title: 'Banka Filo Tasfiyesi Protokolü',
                      color: AppColors.brutalCyan,
                      isDark: isDark,
                    ),

                  if (perks?.hasInspectionTransparency == true)
                    _buildPerkRow(
                      icon: Icons.fact_check_rounded,
                      title: 'Ekspertiz Kusur Şeffaflığı: Gizli Arızaları Önceden Görme',
                      color: const Color(0xFF38BDF8),
                      isDark: isDark,
                    ),

                  if (perks?.hasMasterMechanicVoucher == true)
                    _buildPerkRow(
                      icon: Icons.build_rounded,
                      title: 'Sanayi Usta Başı Çeki: Ücretsiz Anında Kaporta Onarımı',
                      color: const Color(0xFFCD7F32),
                      isDark: isDark,
                    ),

                  if (perks?.hasShowcaseBoost == true)
                    _buildPerkRow(
                      icon: Icons.bolt_rounded,
                      title: 'Sarı Site Vitrin Dopingi: 2 Kat Müşteri Teklif Trafiği',
                      color: AppColors.brutalYellow,
                      isDark: isDark,
                    ),

                  if (perks != null && perks.freeNoterVouchers > 0)
                    _buildPerkRow(
                      icon: Icons.receipt_long_rounded,
                      title: '${perks.freeNoterVouchers} Adet Ücretsiz Noter Çeki',
                      color: const Color(0xFF38BDF8),
                      isDark: isDark,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Claim Button
            NeoBrutalButton(
              label: context.tr('podium_dialog_btn_claim'),
              icon: Icons.check_circle_rounded,
              backgroundColor: AppColors.brutalYellow,
              textColor: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: () {
                HapticFeedback.heavyImpact();
                ref.read(gameProvider.notifier).claimSeasonRewards();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkRow({
    required IconData icon,
    required String title,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
