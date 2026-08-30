import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/auction_model.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class AuctionTrunkLootDialog extends StatelessWidget {
  final TrunkLoot loot;
  final VoidCallback onClaim;

  const AuctionTrunkLootDialog({
    super.key,
    required this.loot,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(20),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: AppColors.brutalYellow,
        borderWidth: 2.5,
        borderRadius: 12,
        shadowOffset: const Offset(4, 4),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brutalYellow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.black,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('auction_trunk_surprise'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loot.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brutalGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                loot.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              NeoBrutalBadge(
                text: context.tr('auction_earned_value', {
                  'val': CurrencyFormatter.format(loot.value),
                }),
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 12,
              ),
              const SizedBox(height: 18),
              NeoBrutalButton(
                label: context.tr('auction_loot_claim_btn'),
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fullWidth: true,
                onPressed: onClaim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
