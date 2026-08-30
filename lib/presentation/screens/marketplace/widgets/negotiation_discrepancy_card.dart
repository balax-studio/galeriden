import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/models/listing_model.dart';
import '../../../../domain/usecases/negotiation_engine.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class NegotiationDiscrepancyCard extends StatelessWidget {
  final ListingModel listing;
  final CustomerModel customer;
  final int negotiationSkillLevel;
  final bool hasUsedHonestDiscount;
  final bool isDark;
  final bool isLocked;
  final VoidCallback onUseHonestDiscount;
  final void Function(bool isSuccess, double targetDiscPrice, String response)
      onBluffResult;
  final void Function(double targetDiscPrice, String response)
      onDefectStrikeResult;

  const NegotiationDiscrepancyCard({
    super.key,
    required this.listing,
    required this.customer,
    required this.negotiationSkillLevel,
    required this.hasUsedHonestDiscount,
    required this.isDark,
    required this.isLocked,
    required this.onUseHonestDiscount,
    required this.onBluffResult,
    required this.onDefectStrikeResult,
  });

  @override
  Widget build(BuildContext context) {
    final disc = NegotiationEngine.detectExpertiseDiscrepancy(listing.car);

    if (!disc.hasDiscrepancy) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor:
              isDark ? const Color(0xFF0F291E) : const Color(0xFFECFDF5),
          borderColor: const Color(0xFF10B981),
          borderWidth: 2,
          borderRadius: 12,
          shadowOffset: const Offset(3, 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_rounded,
                      color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.tr('deal_honest_seller_title'),
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('deal_honest_seller_desc'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: hasUsedHonestDiscount
                          ? context.tr('deal_friendly_discount_used')
                          : context.tr('deal_friendly_discount_btn'),
                      icon: Icons.handshake_rounded,
                      backgroundColor: hasUsedHonestDiscount
                          ? const Color(0xFF059669)
                          : const Color(0xFF10B981),
                      textColor: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: (hasUsedHonestDiscount || isLocked)
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              onUseHonestDiscount();
                              NotificationService.showSuccess(
                                context,
                                context.tr('deal_honest_bonus_toast'),
                              );
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('deal_bluff_btn'),
                      icon: Icons.psychology_alt_rounded,
                      backgroundColor: isDark
                          ? const Color(0xFF24142B)
                          : const Color(0xFFFAF5FF),
                      textColor: const Color(0xFFA855F7),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: isLocked ? null : () => _executeBluff(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor:
            isDark ? const Color(0xFF2E1E0E) : const Color(0xFFFEF3C7),
        borderColor: const Color(0xFFD97706),
        borderWidth: 2,
        borderRadius: 12,
        shadowOffset: const Offset(3, 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.report_problem_rounded,
                    color: Color(0xFFD97706), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.tr('deal_discrepancy_title', {'title': disc.title}),
                    style: const TextStyle(
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              disc.description,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFFDE68A)
                    : const Color(0xFF451A03),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            NeoBrutalButton(
              label: context.tr('deal_strike_defect_btn', {
                'percent': (disc.extraDiscountPercent * 100).toInt(),
              }),
              icon: Icons.gavel_rounded,
              backgroundColor: const Color(0xFFD97706),
              textColor: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 10),
              onPressed: isLocked
                  ? null
                  : () => _executeDefectStrike(context, disc.extraDiscountPercent),
            ),
          ],
        ),
      ),
    );
  }

  void _executeBluff(BuildContext context) {
    final roll = Random().nextInt(100);
    final bluffChance = negotiationSkillLevel * 5;
    final asking = listing.askingPrice;

    if (roll < bluffChance) {
      final targetDiscPrice = (asking * 0.85).roundToDouble();
      String response;
      switch (customer.archetype) {
        case CustomerArchetype.skepticalOfficial:
          response = context.tr('deal_skeptical_bluff_win', {
            'price': CurrencyFormatter.formatShort(targetDiscPrice),
          });
          break;
        case CustomerArchetype.impatientYouth:
          response = context.tr('deal_impatient_bluff_win', {
            'price': CurrencyFormatter.formatShort(targetDiscPrice),
          });
          break;
        case CustomerArchetype.greedyFlipper:
          response = context.tr('deal_greedy_bluff_win', {
            'price': CurrencyFormatter.formatShort(targetDiscPrice),
          });
          break;
        case CustomerArchetype.familyMan:
          response = context.tr('deal_family_bluff_win', {
            'price': CurrencyFormatter.formatShort(targetDiscPrice),
          });
          break;
      }
      onBluffResult(true, targetDiscPrice, response);
    } else {
      String response;
      switch (customer.archetype) {
        case CustomerArchetype.skepticalOfficial:
          response = context.tr('deal_skeptical_bluff_fail');
          break;
        case CustomerArchetype.impatientYouth:
          response = context.tr('deal_impatient_bluff_fail');
          break;
        case CustomerArchetype.greedyFlipper:
          response = context.tr('deal_greedy_bluff_fail');
          break;
        case CustomerArchetype.familyMan:
          response = context.tr('deal_family_bluff_fail');
          break;
      }
      onBluffResult(false, 0, response);
    }
  }

  void _executeDefectStrike(BuildContext context, double extraDiscountPercent) {
    final asking = listing.askingPrice;
    final targetDiscPrice =
        (asking * (1.0 - extraDiscountPercent)).roundToDouble();
    String response;
    switch (customer.archetype) {
      case CustomerArchetype.skepticalOfficial:
        response = context.tr('deal_skeptical_defect_accept', {
          'price': CurrencyFormatter.formatShort(targetDiscPrice),
        });
        break;
      case CustomerArchetype.impatientYouth:
        response = context.tr('deal_impatient_defect_accept', {
          'price': CurrencyFormatter.formatShort(targetDiscPrice),
        });
        break;
      case CustomerArchetype.greedyFlipper:
        response = context.tr('deal_greedy_defect_accept', {
          'price': CurrencyFormatter.formatShort(targetDiscPrice),
        });
        break;
      case CustomerArchetype.familyMan:
        response = context.tr('deal_family_defect_accept', {
          'price': CurrencyFormatter.formatShort(targetDiscPrice),
        });
        break;
    }
    onDefectStrikeResult(targetDiscPrice, response);
  }
}
