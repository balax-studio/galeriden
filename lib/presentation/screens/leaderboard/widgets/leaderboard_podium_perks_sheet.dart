import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

/// Neo-brutalist modal sheet detailing weekly leaderboard podium rewards and perks.
class LeaderboardPodiumPerksSheet extends StatelessWidget {
  final bool isDark;

  const LeaderboardPodiumPerksSheet({
    super.key,
    required this.isDark,
  });

  static void show(BuildContext context, {required bool isDark}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LeaderboardPodiumPerksSheet(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF0F121C) : const Color(0xFFF9F9F6);
    final borderColor = isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, -4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 2.0),
                  ),
                  child: const Icon(
                    Icons.military_tech_rounded,
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
                        context.tr('podium_sheet_header_title'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('podium_sheet_header_subtitle'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 12, thickness: 1.5),

          // Scrollable content
          Flexible(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Rank 1 Card
                _buildTierCard(
                  context,
                  rankBadge: '1 • KÜRSI ZİRVESİ',
                  title: context.tr('podium_tier_1_title'),
                  badgeColor: const Color(0xFFFFD700),
                  accentColor: const Color(0xFFFFF9DB),
                  trophyTitle: context.tr('podium_trophy_gold'),
                  plateText: '34 KRAL 01',
                  perks: [
                    context.tr('podium_tier_1_perk_1'),
                    context.tr('podium_tier_1_perk_2'),
                    context.tr('podium_tier_1_perk_3'),
                  ],
                  icon: Icons.workspace_premium_rounded,
                  isDark: isDark,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),

                // Rank 2 Card
                _buildTierCard(
                  context,
                  rankBadge: '2 • İKİNCİLİK',
                  title: context.tr('podium_tier_2_title'),
                  badgeColor: const Color(0xFFE2E8F0),
                  accentColor: const Color(0xFFF1F5F9),
                  trophyTitle: context.tr('podium_trophy_silver'),
                  plateText: '06 USTA 02',
                  perks: [
                    context.tr('podium_tier_2_perk_1'),
                    context.tr('podium_tier_2_perk_2'),
                    context.tr('podium_tier_2_perk_3'),
                  ],
                  icon: Icons.shield_rounded,
                  isDark: isDark,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),

                // Rank 3 Card
                _buildTierCard(
                  context,
                  rankBadge: '3 • ÜÇÜNCÜLÜK',
                  title: context.tr('podium_tier_3_title'),
                  badgeColor: const Color(0xFFCD7F32),
                  accentColor: const Color(0xFFFFEDD5),
                  trophyTitle: context.tr('podium_trophy_bronze'),
                  plateText: '35 ESNAF 03',
                  perks: [
                    context.tr('podium_tier_3_perk_1'),
                    context.tr('podium_tier_3_perk_2'),
                    context.tr('podium_tier_3_perk_3'),
                  ],
                  icon: Icons.handshake_rounded,
                  isDark: isDark,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),

                // Rank 4-10 Card
                _buildTierCard(
                  context,
                  rankBadge: '4 - 10 • İLK ON KULÜBÜ',
                  title: context.tr('podium_tier_runner_title'),
                  badgeColor: const Color(0xFF38BDF8),
                  accentColor: const Color(0xFFE0F2FE),
                  trophyTitle: null,
                  plateText: null,
                  perks: [
                    context.tr('podium_tier_runner_perk_1'),
                    context.tr('podium_tier_runner_perk_2'),
                  ],
                  icon: Icons.verified_rounded,
                  isDark: isDark,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Close Action
          Padding(
            padding: const EdgeInsets.all(16),
            child: NeoBrutalButton(
              label: context.tr('btn_close'),
              icon: Icons.check_circle_outline_rounded,
              backgroundColor: AppColors.brutalYellow,
              textColor: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context, {
    required String rankBadge,
    required String title,
    required Color badgeColor,
    required Color accentColor,
    required String? trophyTitle,
    required String? plateText,
    required List<String> perks,
    required IconData icon,
    required bool isDark,
    required Color borderColor,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF161B28) : Colors.white,
      borderColor: borderColor,
      borderWidth: 2.2,
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeoBrutalBadge(
                text: rankBadge,
                backgroundColor: badgeColor,
                textColor: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
              const Spacer(),
              if (plateText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'TR',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        plateText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(icon, color: badgeColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),

          if (trophyTitle != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: badgeColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  trophyTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),
          const Divider(height: 8, thickness: 1.0),
          const SizedBox(height: 6),

          ...perks.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3, right: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.0),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
