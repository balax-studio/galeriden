import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/game_sound_haptic_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/real_estate_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class RealEstateOffersSheet extends ConsumerWidget {
  final RealEstateModel property;

  const RealEstateOffersSheet({
    super.key,
    required this.property,
  });

  static Future<void> show({
    required BuildContext context,
    required RealEstateModel property,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RealEstateOffersSheet(property: property),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final game = ref.watch(gameProvider);
    // Refresh property from state
    final currentProp = game.ownedRealEstates.firstWhere(
      (p) => p.id == property.id,
      orElse: () => property,
    );

    final offers = currentProp.activeOffers;
    final askingPrice = currentProp.customListingPrice ?? currentProp.estimatedRealValue;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentProp.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currentProp.city} • ${currentProp.district} • ${context.tr('real_estate_listing_price_label', {'price': CurrencyFormatter.format(askingPrice)})}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Offers List
          if (offers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 40, color: Colors.black45),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('real_estate_no_offers_title'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('real_estate_no_offers_desc'),
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 340),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: offers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final offer = offers[index];
                  final diffPercent = ((offer.offeredAmount - askingPrice) / askingPrice) * 100;
                  final isHigher = diffPercent >= 0;

                  return NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              offer.buyerName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            NeoBrutalBadge(
                              text: context.tr('real_estate_badge_remaining', {'days': offer.daysRemaining}),
                              backgroundColor: const Color(0xFFFEF3C7),
                              textColor: const Color(0xFF92400E),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.buyerNote,
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  CurrencyFormatter.format(offer.offeredAmount),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${isHigher ? '+' : ''}%${diffPercent.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isHigher
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    ref.read(gameProvider.notifier).rejectRealEstateOffer(
                                          realEstateId: currentProp.id,
                                          offerId: offer.id,
                                        );
                                    NotificationService.showInfo(
                                      context,
                                      context.tr('real_estate_offer_rejected_toast'),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(color: Colors.black, width: 1.5),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  child: Text(
                                    context.tr('real_estate_offer_btn_reject'),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    HapticFeedback.heavyImpact();
                                    GameSoundHapticService.playCashSuccess();
                                    final ok = ref.read(gameProvider.notifier).acceptRealEstateOffer(
                                          realEstateId: currentProp.id,
                                          offerId: offer.id,
                                        );
                                    if (ok) {
                                      NotificationService.showSuccess(
                                        context,
                                        context.tr('real_estate_offer_accepted_toast'),
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    side: const BorderSide(color: Colors.black, width: 1.5),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                  child: Text(
                                    context.tr('real_estate_offer_btn_accept'),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 14),

          // Unlist Button
          NeoBrutalButton(
            label: context.tr('real_estate_btn_unlist_showcase'),
            icon: Icons.cancel_outlined,
            backgroundColor: const Color(0xFFF1F5F9),
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(gameProvider.notifier).unlistRealEstate(currentProp.id);
              NotificationService.showInfo(
                context,
                context.tr('real_estate_unlist_success_toast'),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
