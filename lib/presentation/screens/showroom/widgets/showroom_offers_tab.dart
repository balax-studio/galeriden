import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../offer_evaluation_screen.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/game_sound_haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/offer_model.dart';
import '../../../../data/models/trade_in_offer_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../data/models/real_estate_model.dart';
import '../../../../data/models/real_estate_offer_model.dart';
import '../../../../data/models/real_estate_category.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/app_vector_icons.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/tutorial_pulse_target.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/neo_brutal_empty_state.dart';
import '../../../../domain/usecases/negotiation_engine.dart';
import '../../../widgets/dialogs/lucky_opportunity_dialog.dart';
import '../../../widgets/dialogs/notary_transfer_dialog.dart';

class ShowroomOffersTab extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;
  final double? bottomPadding;

  const ShowroomOffersTab({
    super.key,
    required this.game,
    required this.palette,
    this.bottomPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;

    final realEstateOffers = <({RealEstateModel property, RealEstateOfferModel offer})>[];
    for (final prop in game.ownedRealEstates) {
      for (final offer in prop.activeOffers) {
        realEstateOffers.add((property: prop, offer: offer));
      }
    }

    if (game.incomingOffers.isEmpty &&
        game.incomingTradeInOffers.isEmpty &&
        realEstateOffers.isEmpty) {
      return RefreshIndicator(
        color: Colors.black,
        backgroundColor: const Color(0xFFFFDE59),
        strokeWidth: 2.5,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 450));
          final res = ref.read(gameProvider.notifier).manualPullOrganicOffer();
          if (context.mounted) {
            if (res.hasNewOffer) {
              NotificationService.showSuccess(context, res.message);
            } else {
              NotificationService.showInfo(context, res.message);
            }
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          children: [
            const SizedBox(height: 40),
            NeoBrutalEmptyState(
              icon: Icons.local_offer_outlined,
              badgeText: context.tr('badge_awaiting_offers'),
              title: context.tr('title_no_offers_yet'),
              description: context.tr('desc_no_offers_yet'),
              actionLabel: context.tr('btn_pull_customers_refresh'),
              actionIcon: Icons.campaign_rounded,
              onActionPressed: () {
                final res =
                    ref.read(gameProvider.notifier).manualPullOrganicOffer();
                if (res.hasNewOffer) {
                  NotificationService.showSuccess(context, res.message);
                } else {
                  NotificationService.showInfo(context, res.message);
                }
              },
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: const Color(0xFFFFDE59),
      strokeWidth: 2.5,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 450));
        final res = ref.read(gameProvider.notifier).manualPullOrganicOffer();
        if (context.mounted) {
          if (res.hasNewOffer) {
            NotificationService.showSuccess(context, res.message);
          } else {
            NotificationService.showInfo(context, res.message);
          }
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        slivers: [
          // 1. Trade-in Offers Section (§4.6.2)
          if (game.incomingTradeInOffers.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sync_alt_rounded,
                            color: Color(0xFFFFDE59), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('title_trade_in_offers',
                              {'count': '${game.incomingTradeInOffers.length}'}),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    if (game.incomingTradeInOffers.length >= 2)
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(gameProvider.notifier).rejectAllTradeInOffers();
                          NotificationService.showInfo(
                              context, context.tr('toast_all_trade_ins_cleared'));
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Text(
                            context.tr('btn_reject'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => RepaintBoundary(
                    child: _buildTradeInOfferCard(
                      context,
                      ref,
                      game.incomingTradeInOffers[index],
                      isDark,
                    ),
                  ),
                  childCount: game.incomingTradeInOffers.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 2)),
          ],

          // 2. Regular Cash Offers Section
          if (game.incomingOffers.isNotEmpty) ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                14,
                game.incomingTradeInOffers.isNotEmpty ? 2 : 12,
                14,
                8,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined,
                            color: Color(0xFF00E575), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('title_cash_offers',
                              {'count': '${game.incomingOffers.length}'}),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    if (game.incomingOffers.length >= 2)
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(gameProvider.notifier).rejectAllOffers();
                          NotificationService.showInfo(
                              context, context.tr('toast_all_cash_offers_cleared'));
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          child: Text(
                            context.tr('btn_reject'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final offer = game.incomingOffers[index];
                    return RepaintBoundary(
                      child: _buildCashOfferCard(context, ref, offer, index, isDark),
                    );
                  },
                  childCount: game.incomingOffers.length,
                ),
              ),
            ),
          ],

          // 3. Real Estate Offers Section (Sales & Rentals)
          if (realEstateOffers.isNotEmpty) ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                14,
                (game.incomingTradeInOffers.isNotEmpty ||
                        game.incomingOffers.isNotEmpty)
                    ? 14
                    : 12,
                14,
                8,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.home_work_rounded,
                            color: Color(0xFF3B82F6), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('title_real_estate_offers',
                              {'count': '${realEstateOffers.length}'}),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = realEstateOffers[index];
                    return RepaintBoundary(
                      child: _buildRealEstateOfferCard(
                          context, ref, item.property, item.offer, isDark),
                    );
                  },
                  childCount: realEstateOffers.length,
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: SizedBox(height: bottomPadding ?? 24),
          ),
        ],
      ),
    );
  }

  Widget _buildRealEstateOfferCard(
    BuildContext context,
    WidgetRef ref,
    RealEstateModel property,
    RealEstateOfferModel offer,
    bool isDark,
  ) {
    if (offer.isRentalOffer) {
      return _buildRentalOfferCard(context, ref, property, offer, isDark);
    }
    return _buildSaleOfferCard(context, ref, property, offer, isDark);
  }

  Widget _buildRentalOfferCard(
    BuildContext context,
    WidgetRef ref,
    RealEstateModel property,
    RealEstateOfferModel offer,
    bool isDark,
  ) {
    final tenant = offer.tenant;
    final grade = tenant?.reliabilityGrade ?? 'A';
    Color gradeColor;
    switch (grade) {
      case 'A+':
        gradeColor = const Color(0xFF10B981);
        break;
      case 'A':
        gradeColor = const Color(0xFF3B82F6);
        break;
      case 'B':
        gradeColor = const Color(0xFFF59E0B);
        break;
      default:
        gradeColor = const Color(0xFFEF4444);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/emlak-ilan/${property.id}');
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                    ),
                    child: const Icon(Icons.key_rounded, color: Color(0xFF3B82F6), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${property.city} - ${property.district} • ${context.tr('real_estate_offer_rent_subtitle')}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  NeoBrutalBadge(
                    text: '${offer.daysRemaining} ${context.tr('day')}',
                    color: const Color(0xFFFEF3C7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                GestureDetector(
                  onTap: () => context.push('/emlak-ilan/${property.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_new_rounded, size: 10, color: Color(0xFF1D4ED8)),
                        const SizedBox(width: 4),
                        Text(context.tr('real_estate_nav_listing_desk'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/emlak-kiralama'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.key_rounded, size: 10, color: Color(0xFF047857)),
                        const SizedBox(width: 4),
                        Text(context.tr('real_estate_nav_rental_desk'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
                      ],
                    ),
                  ),
                ),
                if (property.category == RealEstateCategory.land)
                  GestureDetector(
                    onTap: () => context.push('/emlak-insaat/${property.id}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF08A),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.construction_rounded, size: 10, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(context.tr('real_estate_nav_construction_site'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 18),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: gradeColor.withValues(alpha: 0.2),
                  child: Icon(Icons.person_rounded, color: gradeColor, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.buyerName,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        tenant?.profession ?? context.tr('real_estate_tenant_candidate_default'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: gradeColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black, width: 1.2),
                  ),
                  child: Text(
                    '${context.tr('real_estate_reliability_label')} • $grade',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('real_estate_monthly_offer_label'), style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w700)),
                    Text(CurrencyFormatter.format(offer.offeredAmount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('real_estate_deposit_label'), style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w700)),
                    Text(CurrencyFormatter.format(offer.depositAmount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                  ],
                ),
                if (tenant != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('real_estate_eviction_risk_label'), style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w700)),
                      Text('%${tenant.evictionRiskScore}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: tenant.evictionRiskScore > 15 ? const Color(0xFFEF4444) : null)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: NeoBrutalButton(
                    text: context.tr('real_estate_btn_lease_accept'),
                    backgroundColor: const Color(0xFF10B981),
                    textColor: Colors.white,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      final ok = ref.read(gameProvider.notifier).acceptRealEstateRentalOffer(
                            realEstateId: property.id,
                            offerId: offer.id,
                          );
                      if (ok) {
                        GameSoundHapticService.playCashSuccess();
                        NotificationService.showSuccess(
                          context,
                          context.tr('real_estate_lease_contract_success', {'buyer': offer.buyerName}),
                        );
                      } else {
                        NotificationService.showWarning(
                          context,
                          context.tr('real_estate_lease_blocked_warning'),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: NeoBrutalButton(
                    text: context.tr('real_estate_btn_negotiate'),
                    backgroundColor: const Color(0xFFF59E0B),
                    textColor: Colors.black,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push(
                        '/emlak-kiraci-pazarlik/${property.id}/${offer.tenant?.id ?? offer.id}',
                        extra: offer.tenant,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: NeoBrutalButton(
                    text: context.tr('btn_reject'),
                    backgroundColor: const Color(0xFFEF4444),
                    textColor: Colors.white,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(gameProvider.notifier).rejectRealEstateOffer(
                            realEstateId: property.id,
                            offerId: offer.id,
                          );
                      NotificationService.showInfo(context, context.tr('real_estate_rent_offer_rejected'));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleOfferCard(
    BuildContext context,
    WidgetRef ref,
    RealEstateModel property,
    RealEstateOfferModel offer,
    bool isDark,
  ) {
    final totalCost = property.currentPurchasePrice + property.deedFeePaid + property.commissionPaid;
    final netProfit = offer.offeredAmount - totalCost;
    final profitPercent = totalCost > 0 ? ((netProfit / totalCost) * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                HapticFeedback.selectionClick();
                context.push('/emlak-ilan/${property.id}');
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Color(0xFF10B981), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${property.city} - ${property.district} • ${context.tr('real_estate_offer_sale_subtitle')}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  NeoBrutalBadge(
                    text: '${offer.daysRemaining} ${context.tr('day')}',
                    color: const Color(0xFFFEF3C7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                GestureDetector(
                  onTap: () => context.push('/emlak-ilan/${property.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_new_rounded, size: 10, color: Color(0xFF1D4ED8)),
                        const SizedBox(width: 4),
                        Text(context.tr('real_estate_nav_listing_desk'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/emlak-kiralama'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.key_rounded, size: 10, color: Color(0xFF047857)),
                        const SizedBox(width: 4),
                        Text(context.tr('real_estate_nav_rental_desk'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
                      ],
                    ),
                  ),
                ),
                if (property.category == RealEstateCategory.land)
                  GestureDetector(
                    onTap: () => context.push('/emlak-insaat/${property.id}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF08A),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.construction_rounded, size: 10, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(context.tr('real_estate_nav_construction_site'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('real_estate_buyer_label'), style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w700)),
                    Text(offer.buyerName, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(context.tr('real_estate_offered_price_label'), style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w700)),
                    Text(CurrencyFormatter.format(offer.offeredAmount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                  ],
                ),
              ],
            ),
            if (offer.buyerNote.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black12, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        offer.buyerNote,
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('real_estate_net_profit_margin_label'),
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${netProfit >= 0 ? '+' : ''}${CurrencyFormatter.format(netProfit)} • %$profitPercent',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: netProfit >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: NeoBrutalButton(
                    text: context.tr('real_estate_btn_accept_sell'),
                    backgroundColor: const Color(0xFF10B981),
                    textColor: Colors.white,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      final ok = ref.read(gameProvider.notifier).acceptRealEstateOffer(
                            realEstateId: property.id,
                            offerId: offer.id,
                          );
                      if (ok) {
                        GameSoundHapticService.playCashSuccess();
                        NotificationService.showSuccess(
                          context,
                          context.tr('real_estate_sale_success_short', {'title': property.title}),
                        );
                      } else {
                        NotificationService.showWarning(
                          context,
                          context.tr('real_estate_sale_blocked_warning'),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: NeoBrutalButton(
                    text: context.tr('real_estate_btn_negotiate'),
                    backgroundColor: const Color(0xFFF59E0B),
                    textColor: Colors.black,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push('/emlak-pazarlik/${property.id}/${offer.id}');
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: NeoBrutalButton(
                    text: context.tr('btn_reject'),
                    backgroundColor: const Color(0xFFEF4444),
                    textColor: Colors.white,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(gameProvider.notifier).rejectRealEstateOffer(
                            realEstateId: property.id,
                            offerId: offer.id,
                          );
                      NotificationService.showInfo(context, context.tr('real_estate_sale_offer_rejected'));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeInOfferCard(
    BuildContext context,
    WidgetRef ref,
    TradeInOfferModel tradeOffer,
    bool isDark,
  ) {
    final targetCar = game.ownedCars.firstWhere(
      (c) => c.id == tradeOffer.targetCarId,
      orElse: () => CarModel(
        id: '',
        brand: 'Bilinmeyen',
        modelName: context.tr('showroom_vitrin_tag'),
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 0,
        currentPurchasePrice: 0,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 0,
          isMileageTampered: false,
          bodyParts: {},
        ),
      ),
    );

    final isCashGivenToPlayer = tradeOffer.cashDifference >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
        borderColor: const Color(0xFFFFDE59),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE59),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      size: 18, color: Colors.black),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('trade_offer_title',
                            {'customer': tradeOffer.customerName}),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        context.tr('trade_requested_car',
                            {'car': targetCar.modelName}),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: isCashGivenToPlayer
                      ? '+${CurrencyFormatter.format(tradeOffer.cashDifference)}'
                      : '-${CurrencyFormatter.format(-tradeOffer.cashDifference)}',
                  backgroundColor: isCashGivenToPlayer
                      ? const Color(0xFF00E575)
                      : const Color(0xFFFF9F1C),
                  textColor: Colors.black,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dialog speech bubble
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF262C3D)
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Text(
                '"${tradeOffer.dialogText}"',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Offered Car Summary Box
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('offered_car_title'),
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B)),
                      ),
                      Text(
                        tradeOffer.offeredCar.modelName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${tradeOffer.offeredCar.modelYear} • ${tradeOffer.offeredCar.expertise.mileage} km • ${context.tr('engine_condition')}: %${tradeOffer.offeredCar.expertise.engineCondition.round()}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    NeoBrutalButton(
                      label: context.tr('btn_reject'),
                      backgroundColor: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0),
                      textColor:
                          isDark ? Colors.white70 : const Color(0xFF64748B),
                      onPressed: () {
                        ref
                            .read(gameProvider.notifier)
                            .rejectTradeInOffer(tradeOffer.id);
                        NotificationService.showInfo(
                            context, context.tr('toast_trade_in_rejected'));
                      },
                    ),
                    const SizedBox(width: 8),
                    NeoBrutalButton(
                      label: context.tr('btn_accept_trade'),
                      icon: Icons.check_circle_outline_rounded,
                      backgroundColor: const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      onPressed: () {
                        final success = ref
                            .read(gameProvider.notifier)
                            .acceptTradeInOffer(tradeOffer);
                        if (success) {
                          NotificationService.showSuccess(
                            context,
                            context.tr('toast_trade_in_success',
                                {'car': targetCar.modelName}),
                          );
                        } else {
                          NotificationService.showWarning(context,
                              context.tr('toast_trade_in_insufficient_funds'));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashOfferCard(
    BuildContext context,
    WidgetRef ref,
    OfferModel offer,
    int index,
    bool isDark,
  ) {
    final car = game.ownedCars.firstWhere(
      (c) => c.id == offer.carId,
      orElse: () => CarModel(
        id: '',
        brand: 'Bilinmeyen',
        modelName: context.tr('car_label'),
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 0,
        currentPurchasePrice: 0,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 0,
          isMileageTampered: false,
          bodyParts: {},
        ),
      ),
    );

    final isCountered = offer.status == OfferStatus.countered;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key('offer_${offer.id}_$index'),
        direction: DismissDirection.horizontal,
        background: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF00E575),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.black, size: 26),
              const SizedBox(width: 8),
              Text(
                context.tr('swipe_accept_sell'),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                context.tr('swipe_reject_delete'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.delete_forever_rounded,
                  color: Colors.white, size: 26),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          final isExpired =
              offer.isExpiredForDay(game.currentDay) || offer.status == OfferStatus.expired;
          if (isExpired) {
            ref.read(gameProvider.notifier).dismissOffer(offer.id);
            return true;
          }
          if (direction == DismissDirection.startToEnd) {
            _processOfferAcceptWithNotary(context, ref, offer, car);
            return true;
          } else {
            ref.read(gameProvider.notifier).rejectOffer(offer.id);
            if (context.mounted) {
              NotificationService.showWarning(
                  context,
                  context
                      .tr('toast_offer_rejected', {'buyer': offer.buyerName}));
            }
            return true;
          }
        },
        child: Builder(
          builder: (context) {
            final isExpired =
                offer.isExpiredForDay(game.currentDay) || offer.status == OfferStatus.expired;

            return NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark
                  ? (isExpired
                      ? const Color(0xFF161922)
                      : const Color(0xFF141721))
                  : (isExpired ? const Color(0xFFF8FAFC) : Colors.white),
              borderColor: isExpired
                  ? const Color(0xFFEF4444)
                  : (isCountered
                      ? const Color(0xFFFFDE59)
                      : (isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFF0F172A))),
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${car.brand} ${car.modelName}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isExpired) ...[
                              const SizedBox(width: 8),
                              NeoBrutalBadge(
                                text: context.tr('badge_buyer_left_timeout'),
                                backgroundColor: const Color(0xFFDC2626),
                                textColor: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ] else if (offer.expiresOnDay > 0) ...[
                              const SizedBox(width: 8),
                              NeoBrutalBadge(
                                text: context.tr('badge_offer_days_left', {
                                  'days': (offer.expiresOnDay - game.currentDay + 1).clamp(1, 999),
                                }),
                                backgroundColor: (offer.expiresOnDay - game.currentDay <= 0)
                                    ? const Color(0xFFEA580C)
                                    : const Color(0xFF0284C7),
                                textColor: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                          child: Text(
                        CurrencyFormatter.format(offer.offeredAmount),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isExpired
                              ? const Color(0xFF94A3B8)
                              : (isDark
                                  ? const Color(0xFF00E575)
                                  : const Color(0xFF15803D)),
                          decoration:
                              isExpired ? TextDecoration.lineThrough : null,
                        ),
                      )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        context.tr('market_val_short', {
                          'val': CurrencyFormatter.formatShort(
                              car.estimatedRealValue)
                        }),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      )),
                      Expanded(
                          child: Text(
                        context.tr('listing_price_short', {
                          'val': CurrencyFormatter.formatShort(
                              car.listingPrice > 0
                                  ? car.listingPrice
                                  : car.estimatedRealValue)
                        }),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        context
                            .tr('buyer_name_label', {'buyer': offer.buyerName}),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      if (offer.buyerCustomer != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDE59),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 1.8,
                            ),
                          ),
                          child: Text(
                            offer.buyerCustomer!.archetypeTitle,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      if (offer.offerType != OfferType.cash)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: offer.offerType == OfferType.installment
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFFA855F7),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 1.8,
                            ),
                          ),
                          child: Text(
                            offer.offerType == OfferType.installment
                                ? context.tr('installment_badge_text', {
                                    'months':
                                        offer.installmentMonths.toString(),
                                    'risk': offer.riskLevel
                                  })
                                : context.tr('cheque_offer_badge'),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (offer.requestedTestDrive &&
                      offer.testDriveResult != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F291E)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF00E575),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.speed_rounded,
                              size: 14, color: Color(0xFF00E575)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              offer.testDriveResult!,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isExpired) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF7F1D1D)
                              : const Color(0xFFFCA5A5),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '"${context.tr('buyer_timeout_message')}"',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFEF4444),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else if (offer.buyerMessage.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '"${offer.buyerMessage}"',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? palette.primaryColor
                              : const Color(0xFF0F172A),
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Actions
                  if (isExpired)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          context.tr('offer_expired_label'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF4444),
                          ),
                        )),
                        NeoBrutalButton(
                          label: context.tr('btn_clear_offer'),
                          icon: Icons.delete_outline_rounded,
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFF1F5F9),
                          textColor: isDark
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFDC2626),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          onPressed: () {
                            ref
                                .read(gameProvider.notifier)
                                .dismissOffer(offer.id);
                          },
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeoBrutalButton(
                          label: context.tr('btn_reject'),
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          textColor: isDark
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFDC2626),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          onPressed: () {
                            ref
                                .read(gameProvider.notifier)
                                .rejectOffer(offer.id);
                          },
                        ),
                        Row(
                          children: [
                            NeoBrutalButton(
                              label: context.tr('btn_counter_offer'),
                              backgroundColor: const Color(0xFFFFDE59),
                              textColor: Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              onPressed: () {
                                context.push(
                                  '/offer-evaluation',
                                  extra: OfferEvaluationArgs(car: car, offer: offer),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            TutorialPulseTarget(
                              isEnabled: !game.tutorialCompleted &&
                                  offer.carId == 'car_heritage_dede',
                              pulseColor: const Color(0xFF00E575),
                              child: NeoBrutalButton(
                                label: context.tr('btn_accept_and_sell'),
                                icon: Icons.check_circle_rounded,
                                backgroundColor: const Color(0xFF00E575),
                                textColor: Colors.black,
                                fontSize: 11,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                onPressed: () {
                                  _processOfferAcceptWithNotary(
                                      context, ref, offer, car);
                                },
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
    );
  }

  void _processOfferAcceptWithNotary(
    BuildContext context,
    WidgetRef ref,
    OfferModel offer,
    CarModel car,
  ) {
    GameSoundHapticService.playNotarySignature();
    final customer =
        offer.buyerCustomer ?? CustomerModel.generateRandomCustomer();
    final fraudResult = NegotiationEngine.evaluatePlayerFraudInspection(
        car: car, customer: customer);

    if (fraudResult.caughtFraud) {
      ref
          .read(gameProvider.notifier)
          .acceptOfferWithFraudCheck(offer, customer);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 18),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(18),
              backgroundColor:
                  palette.isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: palette.errorColor,
              borderRadius: 12,
              borderWidth: 2.5,
              shadowOffset: const Offset(4, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VectorIconWidget(
                          type: 'error', color: palette.errorColor, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fraudResult.title,
                          style: TextStyle(
                            color: palette.errorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${fraudResult.description}\n\n'
                    '${context.tr('fine_penalty_label', {
                          'amount': CurrencyFormatter.formatShort(
                              fraudResult.fineAmount)
                        })}\n'
                    '${context.tr('reputation_loss_label', {
                          'points': fraudResult.reputationPenalty.toString()
                        })}',
                    style: AppTypography.bodyMedium(palette.isDark),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: NeoBrutalButton(
                      label: context.tr('ok_button'),
                      backgroundColor: AppColors.errorRed,
                      textColor: Colors.white,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return;
    }

    final notaryResult =
        ref.read(gameProvider.notifier).processNotarySale(offer, customer);

    if (context.mounted) {
      NotaryTransferDialog.show(
        context: context,
        car: car,
        buyerName: offer.buyerName,
        sellerName: '${game.dealershipName} • ${game.playerName}',
        salePrice: offer.offeredAmount,
        isBuying: false,
        eventResult: notaryResult,
        onComplete: () {
          if (!notaryResult.isCancelled) {
            GameSoundHapticService.playCashSuccess();
            NotificationService.showSuccess(
              context,
              context.tr('notary_sale_success_toast', {
                'dealership': game.dealershipName,
                'amount': CurrencyFormatter.format(offer.offeredAmount),
              }),
            );
            final luckyOpp =
                ref.read(gameProvider.notifier).checkAndRollLuckyOpportunity();
            if (luckyOpp != null && context.mounted) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  LuckyOpportunityDialog.show(context, luckyOpp);
                }
              });
            }
          } else {
            NotificationService.showWarning(
              context,
              context.tr('notary_sale_cancelled_toast', {
                'car': '${car.brand} ${car.modelName}',
              }),
            );
          }
        },
      );
    }
  }
}
