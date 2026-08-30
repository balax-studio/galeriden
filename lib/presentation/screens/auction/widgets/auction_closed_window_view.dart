import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/usecases/auction_engine.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class AuctionClosedWindowView extends StatelessWidget {
  final bool isDark;
  final int closedCountdown;
  final bool isOfficerConsulted;
  final String? officerSpeech;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onConsultOfficer;

  const AuctionClosedWindowView({
    super.key,
    required this.isDark,
    required this.closedCountdown,
    required this.isOfficerConsulted,
    required this.officerSpeech,
    required this.onRefresh,
    required this.onConsultOfficer,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = closedCountdown ~/ 60;
    final seconds = closedCountdown % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: AppColors.brutalYellow,
      strokeWidth: 2.5,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(22),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_clock_rounded,
                    color: AppColors.brutalOrange,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('auction_closed_title'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('auction_closed_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isOfficerConsulted) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F1118)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.brutalYellow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.tr('auction_ask_officer_desc'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeoBrutalButton(
                    label: context.tr('auction_ask_officer_btn'),
                    icon: Icons.forum_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final speech =
                          AuctionEngine.getRandomOfficerDialogue(timeStr);
                      onConsultOfficer(speech);
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.brutalYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.brutalYellow,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.badge_rounded,
                              color: AppColors.brutalYellow,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('auction_officer_label'),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          officerSpeech ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.tr(
                            'auction_remaining_est_time',
                            {'time': timeStr},
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brutalGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeoBrutalButton(
                    label: context.tr('auction_reask_officer_btn'),
                    backgroundColor: isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      final speech =
                          AuctionEngine.getRandomOfficerDialogue(timeStr);
                      onConsultOfficer(speech);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
