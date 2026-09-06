import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../widgets/neo_brutal_button.dart';

class NegotiationActionButtons extends StatelessWidget {
  final String? sellerResponse;
  final bool isAccepted;
  final bool isLockedOut;
  final bool isThinking;
  final bool isProcessing;
  final double offeredPrice;
  final double? agreedFinalPrice;
  final double? effectivePrice;
  final double? perkDiscount;
  final int counterOfferCount;
  final bool canAfford;
  final bool isDark;
  final VoidCallback onSendOffer;
  final VoidCallback onPayAndBuy;
  final VoidCallback onReviseOffer;

  const NegotiationActionButtons({
    super.key,
    required this.sellerResponse,
    required this.isAccepted,
    required this.isLockedOut,
    required this.isThinking,
    required this.isProcessing,
    required this.offeredPrice,
    required this.agreedFinalPrice,
    this.effectivePrice,
    this.perkDiscount,
    required this.counterOfferCount,
    required this.canAfford,
    required this.isDark,
    required this.onSendOffer,
    required this.onPayAndBuy,
    required this.onReviseOffer,
  });

  @override
  Widget build(BuildContext context) {
    final finalAgreed = agreedFinalPrice ?? offeredPrice;
    final finalEffective = effectivePrice ?? finalAgreed;
    final finalDiscount = perkDiscount ?? (finalAgreed - finalEffective);

    return Row(
      children: [
        if (sellerResponse == null)
          Expanded(
            child: NeoBrutalButton(
              label: isThinking
                  ? 'TEKLİF DEĞERLENDİRİLİYOR...'
                  : context.tr('deal_make_offer_btn', {
                      'price': CurrencyFormatter.formatShort(offeredPrice),
                    }),
              icon: isThinking
                  ? Icons.hourglass_top_rounded
                  : Icons.handshake_rounded,
              backgroundColor: const Color(0xFFFFDE59),
              textColor: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: (isProcessing || isThinking || isLockedOut)
                  ? null
                  : onSendOffer,
            ),
          )
        else if (isAccepted)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141721) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF00E575),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('neg_agreed_price'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(finalAgreed),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('neg_perk_discount'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            finalDiscount > 0
                                ? '-${CurrencyFormatter.format(finalDiscount)}'
                                : '₺0',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 12, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('neg_final_price'),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(finalEffective),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF00E575),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                NeoBrutalButton(
                  label: context.tr('deal_pay_and_buy_btn', {
                    'price': CurrencyFormatter.formatShort(finalEffective),
                  }),
                  icon: Icons.shopping_bag_rounded,
                  backgroundColor: const Color(0xFF00E575),
                  textColor: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fullWidth: true,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: (!canAfford || isProcessing) ? null : onPayAndBuy,
                ),
              ],
            ),
          )
        else if (!isLockedOut)
          Expanded(
            child: NeoBrutalButton(
              label: context.tr('deal_revise_offer_btn', {
                'count': 3 - counterOfferCount,
              }),
              icon: Icons.refresh_rounded,
              backgroundColor:
                  isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
              textColor: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: onReviseOffer,
            ),
          )
        else
          Expanded(
            child: NeoBrutalButton(
              label: context.tr('deal_leave_table_btn'),
              icon: Icons.close_rounded,
              backgroundColor: const Color(0xFFEF4444),
              textColor: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: () {
                HapticFeedback.selectionClick();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/marketplace');
                }
              },
            ),
          ),
      ],
    );
  }
}
