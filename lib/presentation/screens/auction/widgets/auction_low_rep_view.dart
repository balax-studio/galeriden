import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class AuctionLowReputationView extends StatelessWidget {
  final bool isDark;
  final int reputationScore;

  const AuctionLowReputationView({
    super.key,
    required this.isDark,
    required this.reputationScore,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(24),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: AppColors.brutalOrange,
          borderRadius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brutalOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brutalOrange, width: 2),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 42,
                  color: AppColors.brutalOrange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('auction_hall_locked'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  'auction_hall_locked_desc',
                  {'rep': reputationScore},
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              NeoBrutalButton(
                label: context.tr('auction_goto_market_rep_btn'),
                icon: Icons.storefront_rounded,
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 11.5,
                onPressed: () => context.push('/marketplace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
