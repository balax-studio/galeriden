import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/casino_game_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_card.dart';
import 'widgets/valet_baccarat_modal.dart';
import 'widgets/street_craps_modal.dart';
import 'widgets/hilo_vites_modal.dart';
import 'widgets/plinko_modal.dart';
import 'widgets/lucky_wheel_modal.dart';
import 'widgets/scratch_card_modal.dart';
import 'widgets/double_or_nothing_modal.dart';
import 'widgets/aviator_crash_modal.dart';
import 'widgets/sanayi_barbutu_modal.dart';

class CasinoHubScreen extends ConsumerStatefulWidget {
  const CasinoHubScreen({super.key});

  @override
  ConsumerState<CasinoHubScreen> createState() => _CasinoHubScreenState();
}

class _CasinoHubScreenState extends ConsumerState<CasinoHubScreen> {
  void _openGameModal(Widget modal) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => modal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final stats = game.casinoStats;
    final branchTier = game.currentBranchTier;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D111A) : const Color(0xFFF4F6F9),
      appBar: NeoBrutalAppBar(
        title: context.tr('casino_hub_title'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brutalYellow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0F172A), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    size: 16, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  _formatCurrency(game.balance),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // VIP Casino Club Stats Card
          _buildStatsCard(context, stats, isDark),

          const SizedBox(height: 18),

          // Pink Slip Notice Banner
          _buildPinkSlipNotice(context),

          const SizedBox(height: 20),

          // TIER 1 SECTION
          _buildSectionHeader(
            context,
            title: context.tr('casino_tier1_title'),
            subtitle: context.tr('casino_tier1_subtitle'),
            isUnlocked: branchTier >= 5,
            tierBadge: 'T5 • VIP',
          ),
          const SizedBox(height: 10),
          _buildGameCard(
            context,
            title: context.tr('casino_baccarat_title'),
            desc: context.tr('casino_baccarat_desc'),
            icon: Icons.style_rounded,
            color: const Color(0xFF38BDF8),
            badgeText: 'PUNTO BANCO • 8x',
            isLocked: branchTier < 5,
            onTap: () => _openGameModal(const ValetBaccaratModal()),
          ),
          const SizedBox(height: 12),
          _buildGameCard(
            context,
            title: context.tr('casino_craps_title'),
            desc: context.tr('casino_craps_desc'),
            icon: Icons.casino_rounded,
            color: const Color(0xFFFF7A00),
            badgeText: 'PASS LINE • 2x',
            isLocked: branchTier < 5,
            onTap: () => _openGameModal(const StreetCrapsModal()),
          ),
          const SizedBox(height: 12),
          _buildGameCard(
            context,
            title: context.tr('casino_hilo_title'),
            desc: context.tr('casino_hilo_desc'),
            icon: Icons.speed_rounded,
            color: const Color(0xFFA855F7),
            badgeText: 'HI-LO • 30x',
            isLocked: branchTier < 5,
            onTap: () => _openGameModal(const HiLoVitesModal()),
          ),
          const SizedBox(height: 12),
          _buildGameCard(
            context,
            title: context.tr('casino_barbut_title'),
            desc: context.tr('casino_barbut_desc'),
            icon: Icons.casino_rounded,
            color: const Color(0xFFFF7A00),
            badgeText: 'DÜŞEŞ • 5x',
            isLocked: branchTier < 5,
            onTap: () => _openGameModal(const SanayiBarbutuModal()),
          ),

          const SizedBox(height: 24),

          // TIER 2 SECTION
          _buildSectionHeader(
            context,
            title: context.tr('casino_tier2_title'),
            subtitle: context.tr('casino_tier2_subtitle'),
            isUnlocked: branchTier >= 6,
            tierBadge: 'T6 • HIGH ROLLER',
          ),
          const SizedBox(height: 10),
          _buildGameCard(
            context,
            title: context.tr('casino_aviator_title'),
            desc: context.tr('casino_aviator_desc'),
            icon: Icons.rocket_launch_rounded,
            color: const Color(0xFFFF3366),
            badgeText: 'CRASH • 75x',
            isLocked: branchTier < 6,
            onTap: () => _openGameModal(const AviatorCrashModal()),
          ),
          const SizedBox(height: 12),
          _buildGameCard(
            context,
            title: context.tr('casino_plinko_title'),
            desc: context.tr('casino_plinko_desc'),
            vectorIconType: 'piston',
            color: const Color(0xFF00E575),
            badgeText: 'PEG BOARD • 1000x',
            isLocked: branchTier < 6,
            onTap: () => _openGameModal(const PlinkoModal()),
          ),
          const SizedBox(height: 12),
          _buildGameCard(
            context,
            title: context.tr('casino_wheel_title'),
            desc: context.tr('casino_wheel_desc'),
            icon: Icons.stars_rounded,
            color: const Color(0xFFFFDE59),
            badgeText: 'JACKPOT WHEEL • 10x',
            isLocked: branchTier < 6,
            onTap: () => _openGameModal(const LuckyWheelModal()),
          ),

          const SizedBox(height: 24),

          // TIER 3 SECTION
          _buildSectionHeader(
            context,
            title: context.tr('casino_tier3_title'),
            subtitle: context.tr('casino_tier3_subtitle'),
            isUnlocked: branchTier >= 7,
            tierBadge: 'T7 • ROYALE',
          ),
          const SizedBox(height: 10),
          _buildGameCard(
            context,
            title: context.tr('casino_scratch_title'),
            desc: context.tr('casino_scratch_desc'),
            icon: Icons.touch_app_rounded,
            color: const Color(0xFFEC4899),
            badgeText: 'LUCKY 777 • 50x',
            isLocked: branchTier < 7,
            onTap: () => _openGameModal(const ScratchCardModal()),
          ),
          const SizedBox(height: 12),
          _buildGameCard(
            context,
            title: context.tr('casino_double_or_nothing_title'),
            desc: context.tr('casino_double_desc'),
            icon: Icons.monetization_on_rounded,
            color: const Color(0xFFF59E0B),
            badgeText: 'DOUBLE UP • 2x',
            isLocked: branchTier < 7,
            onTap: () => _openGameModal(
                const DoubleOrNothingModal(baseProfit: 100000.0)),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
      BuildContext context, CasinoStatsModel stats, bool isDark) {
    final netProfit = stats.totalWonAmount - stats.totalLostAmount;
    final isProfit = netProfit >= 0;

    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF161C2C) : Colors.white,
      borderColor: const Color(0xFF0F172A),
      borderWidth: 3.0,
      borderRadius: 12.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.query_stats_rounded,
                      color: AppColors.brutalYellow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('casino_stats_header'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
              NeoBrutalBadge(
                label:
                    '${stats.totalGamesPlayed} ${context.tr('casino_games_played_badge')}',
                color: const Color(0xFF38BDF8),
                textColor: Colors.black,
              ),
            ],
          ),
          const Divider(color: Color(0xFF0F172A), height: 20, thickness: 1.5),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  title: context.tr('casino_net_profit_label'),
                  value: (isProfit ? '+' : '') + _formatCurrency(netProfit),
                  valueColor:
                      isProfit ? AppColors.brutalGreen : AppColors.brutalRed,
                ),
              ),
              Container(width: 1.5, height: 36, color: const Color(0xFF0F172A)),
              Expanded(
                child: _buildStatItem(
                  context,
                  title: context.tr('casino_record_mult_label'),
                  value: '${stats.biggestMultiplierRecord}x',
                  valueColor: const Color(0xFFFFDE59),
                ),
              ),
              Container(width: 1.5, height: 36, color: const Color(0xFF0F172A)),
              Expanded(
                child: _buildStatItem(
                  context,
                  title: context.tr('casino_pink_slip_stats'),
                  value:
                      '+${stats.vehiclesWonCount} / -${stats.vehiclesLostCount}',
                  valueColor: const Color(0xFFA855F7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context,
      {required String title,
      required String value,
      required Color valueColor}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white60),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w900, color: valueColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPinkSlipNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF6B21A8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0F172A), width: 2.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0xFF0F172A), offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.key_rounded,
              color: AppColors.brutalYellow, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr('casino_pink_slip_banner_desc'),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isUnlocked,
    required String tierBadge,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
        NeoBrutalBadge(
          label: tierBadge,
          color: isUnlocked ? AppColors.brutalGreen : const Color(0xFF64748B),
          textColor: isUnlocked ? Colors.black : Colors.white,
        ),
      ],
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String desc,
    IconData? icon,
    String? vectorIconType,
    required Color color,
    required String badgeText,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeoBrutalCard(
      backgroundColor: isLocked
          ? (isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB))
          : (isDark ? const Color(0xFF1A2234) : Colors.white),
      borderColor: const Color(0xFF0F172A),
      borderWidth: 2.5,
      borderRadius: 10.0,
      padding: const EdgeInsets.all(14),
      onTap: isLocked ? null : onTap,
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isLocked ? const Color(0xFF4B5563) : color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF0F172A), width: 2),
            ),
            child: isLocked
                ? const Icon(Icons.lock_rounded,
                    color: Colors.white70, size: 26)
                : (vectorIconType != null
                    ? Center(
                        child: VectorIconWidget(
                          type: vectorIconType,
                          color: Colors.black,
                          size: 28,
                        ),
                      )
                    : Icon(
                        icon ?? Icons.casino_rounded,
                        color: Colors.black,
                        size: 26,
                      )),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: isLocked
                              ? Colors.white54
                              : (isDark ? Colors.white : Colors.black),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    NeoBrutalBadge(
                      label: badgeText,
                      color: isLocked ? const Color(0xFF6B7280) : color,
                      textColor: isLocked ? Colors.white : Colors.black,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLocked
                        ? Colors.white38
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          Icon(
            Icons.chevron_right_rounded,
            color: isLocked
                ? Colors.white24
                : (isDark ? Colors.white70 : Colors.black87),
            size: 24,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double val) {
    if (val >= 1000000) {
      return '₺${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '₺${(val / 1000).toStringAsFixed(0)}K';
    }
    return '₺${val.toStringAsFixed(0)}';
  }
}
